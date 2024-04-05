// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../../src/circles/Demurrage.sol";
import "../setup/TimeCirclesSetup.sol";
import "../setup/HumanRegistration.sol";
import "../hub/MockDeployment.sol";
import "../hub/MockHub.sol";

contract ERC20LiftTest is Test, TimeCirclesSetup, HumanRegistration {
    // State variables

    MockDeployment public mockDeployment;
    MockHub public hub;

    // Constructor

    constructor() HumanRegistration(2) {}

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();

        // Mock deployment
        mockDeployment = new MockDeployment(INFLATION_DAY_ZERO, 365 days);
        hub = mockDeployment.hub();
    }

    // Tests

    function testERC20Wrap() public {
        // register Alice and Bob
        vm.prank(addresses[0]);
        hub.registerHumanUnrestricted();
        vm.prank(addresses[1]);
        hub.registerHumanUnrestricted();

        // Alice registers short name
        vm.startPrank(addresses[0]);
        mockDeployment.nameRegistry().registerShortName();
        vm.stopPrank();

        // skip time and mint
        skipTime(14 days);
        vm.prank(addresses[0]);
        hub.personalMintWithoutV1Check();
        vm.prank(addresses[1]);
        hub.personalMintWithoutV1Check();

        uint256 aliceBalance = hub.balanceOf(addresses[0], uint256(uint160(addresses[0])));
        console.log("Alice balance: ", aliceBalance);

        // test the master contracts in Lift
        // ERC20Lift lift = mockDeployment.erc20Lift();
        // DemurrageCircles demurrage = mockDeployment.mastercopyDemurrageCircles();
        // address demurrageMasterCopy = lift.masterCopyERC20Wrapper(uint256(CirclesType.Demurrage));
        // assertEq(demurrageMasterCopy, address(demurrage));

        // console.log("hub address: ", address(hub));

        // DemurrageCircles proxyERC20D = DemurrageCircles(lift.ensureERC20(addresses[0], CirclesType.Demurrage));
        // console.log("proxyERC20D address: ", address(proxyERC20D));
        // assertEq(IProxy(payable(address(proxyERC20D))).masterCopy(), address(demurrage));

        // wrap some into demurrage ERC20 of Alice by Alice
        vm.prank(addresses[0]);
        DemurrageCircles aliceERC20 = DemurrageCircles(hub.wrap(addresses[0], 10 * CRC, CirclesType.Demurrage));
        assertEq(aliceERC20.balanceOf(addresses[0]), 10 * CRC);

        // Give Bob some Alice CRC, so he can wrap them too
        vm.prank(addresses[0]);
        hub.safeTransferFrom(addresses[0], addresses[1], uint256(uint160(addresses[0])), 5 * CRC, "");
        vm.prank(addresses[1]);
        hub.wrap(addresses[0], 5 * CRC, CirclesType.Demurrage);
        // assert Bob has 5 CRC in Alice's ERC20
        assertEq(aliceERC20.balanceOf(addresses[1]), 5 * CRC);

        // now test wrapping by simply sending ERC1155 to the ERC20 wrapper
        vm.prank(addresses[0]);
        hub.safeTransferFrom(addresses[0], address(aliceERC20), uint256(uint160(addresses[0])), 5 * CRC, "");
        // assert Alice has 10 + 5 = 15 CRC in her ERC20
        assertEq(aliceERC20.balanceOf(addresses[0]), 15 * CRC);
        // Alice wrapped 15 CRC, and gave 5 CRC to Bob
        assertEq(hub.balanceOf(addresses[0], uint256(uint160(addresses[0]))), aliceBalance - 20 * CRC);

        // somewhat cheekily test here that the demurrage works in ERC20 too
        // todo: split this out into proper unit tests, rather than stories

        (uint192 balance, uint64 lastUpdatedDay) = aliceERC20.discountedBalances(addresses[0]);
        console.log("ERC1155 balance: ", hub.balanceOf(addresses[0], uint256(uint160(addresses[0]))));
        console.log("balance: ", balance);
        console.log("lastUpdatedDay: ", lastUpdatedDay);

        // skip time
        skipTime(2 days);
        // assert Alice has 15 CRC in her ERC20
        // 2 days, 15 * (0.9998013320086...)^2 = 14.994040552292530832 (rounded down)
        assertEq(aliceERC20.balanceOf(addresses[0]), 14994040552292530832);
    }
}
