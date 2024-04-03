// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
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
        // register Alice
        vm.prank(addresses[0]);
        hub.registerHumanUnrestricted();

        // skip time and mint
        skipTime(14 days);
        vm.prank(addresses[0]);
        hub.personalMintWithoutV1Check();

        // test the master contracts in Lift
        ERC20Lift lift = mockDeployment.erc20Lift();
        DemurrageCircles demurrage = mockDeployment.mastercopyDemurrageCircles();
        address demurrageMasterCopy = lift.masterCopyERC20Wrapper(uint256(CirclesType.Demurrage));
        assertEq(demurrageMasterCopy, address(demurrage));

        console.log("hub address: ", address(hub));

        DemurrageCircles proxyERC20D = DemurrageCircles(lift.ensureERC20(addresses[0], CirclesType.Demurrage));
        console.log("proxyERC20D address: ", address(proxyERC20D));
        assertEq(IProxy(payable(address(proxyERC20D))).masterCopy(), address(demurrage));

        // wrap some into demurrage ERC20
        // vm.prank(addresses[0]);
        // hub.wrap(addresses[0], 10 * CRC, CirclesType.Demurrage);
    }
}
