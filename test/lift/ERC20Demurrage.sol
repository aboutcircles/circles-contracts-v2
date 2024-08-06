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

    mapping(address => DemurrageCircles) public erc20s;

    // Constructor

    constructor() HumanRegistration(2) {}

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();

        // Mock deployment
        mockDeployment = new MockDeployment(INFLATION_DAY_ZERO, 365 days);
        hub = mockDeployment.hub();

        // register Alice and Bob
        for (uint256 i = 0; i < 2; i++) {
            vm.startPrank(addresses[i]);
            hub.registerHumanUnrestricted();
            mockDeployment.nameRegistry().registerShortName();
            vm.stopPrank();
        }

        // skip time and mint
        skipTime(14 days);
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(addresses[i]);
            hub.personalMintWithoutV1Check();
        }

        // lift some CRC into respective demurrage ERC20's
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(addresses[i]);
            hub.wrap(addresses[i], 300 * CRC, CirclesType.Demurrage);
        }

        // get ERC20's
        for (uint256 i = 0; i < 2; i++) {
            erc20s[addresses[i]] =
                DemurrageCircles(mockDeployment.erc20Lift().erc20Circles(CirclesType.Demurrage, addresses[i]));
        }
    }

    // Tests

    function testERC20Demurrage() public {
        DemurrageCircles aliceERC20 = erc20s[addresses[0]];
        // DemurrageCircles bobERC20 = erc20s[addresses[1]];
        uint256 aliceCirclesId = uint256(uint160(addresses[0]));

        // commenting out because stack too deep; todo write test cleaner

        // uint256 aliceBalanceT1 = aliceERC20.balanceOf(addresses[0]);
        // uint256 bobBalanceT1 = aliceERC20.balanceOf(addresses[1]);
        // assertEq(aliceBalanceT1, 300 * CRC);
        // assertEq(bobBalanceT1, 0);

        skipTime(5 days);

        uint64 dayT2 = hub.day(block.timestamp);
        (uint256 aliceBalanceT2, uint256 aliceDiscountCostT2) = aliceERC20.balanceOfOnDay(addresses[0], dayT2);
        // assertEq(aliceBalanceT2 + aliceDiscountCostT2, aliceBalanceT1);

        (uint256 bobBalanceT2, uint256 bobDiscountCostT2) = aliceERC20.balanceOfOnDay(addresses[1], dayT2);
        // Bob had a zero balance, so there should be no discount cost
        assertEq(bobBalanceT2 + bobDiscountCostT2, 0);
        // assertEq(bobBalanceT2 + bobDiscountCostT2, bobBalanceT1);

        // send 50 CRC from Alice to Bob
        vm.prank(addresses[0]);
        // vm.expectEmit(true, true, false, true, address(aliceERC20));
        // emit Demurrage.DiscountCost(addresses[0], aliceCirclesId, aliceDiscountCostT2);
        aliceERC20.transfer(addresses[1], 50 * CRC);

        (uint256 aliceBalanceT3, uint256 aliceDiscountCostT3) = aliceERC20.balanceOfOnDay(addresses[0], dayT2);
        // there should not be a discount cost now that the transfer has updated her balance
        assertEq(aliceDiscountCostT3, 0);
        // total amounts should add up exactly
        // assertEq(aliceBalanceT3 + aliceDiscountCostT3 + 50 * CRC + aliceDiscountCostT2, aliceBalanceT1);

        (uint256 bobBalanceT3, uint256 bobDiscountCostT3) = aliceERC20.balanceOfOnDay(addresses[1], dayT2);
        // again, after transfer balance is up to date, so no discount cost
        assertEq(bobDiscountCostT3, 0);
        // assertEq(bobBalanceT3 + bobDiscountCostT3, bobBalanceT1 + 50 * CRC);

        skipTime(5 days);
        uint64 dayT4 = hub.day(block.timestamp);

        (uint256 aliceBalanceT4, uint256 aliceDiscountCostT4) = aliceERC20.balanceOfOnDay(addresses[0], dayT4);
        (uint256 bobBalanceT4, uint256 bobDiscountCostT4) = aliceERC20.balanceOfOnDay(addresses[1], dayT4);
        assertEq(aliceBalanceT4 + aliceDiscountCostT4, aliceBalanceT3);
        assertEq(bobBalanceT4 + bobDiscountCostT4, bobBalanceT3);

        vm.prank(addresses[0]);
        aliceERC20.transfer(addresses[1], 50 * CRC);

        (aliceBalanceT2, aliceDiscountCostT2) = aliceERC20.balanceOfOnDay(addresses[0], dayT4);
        (bobBalanceT2, bobDiscountCostT2) = aliceERC20.balanceOfOnDay(addresses[1], dayT4);
        assertEq(aliceBalanceT2 + aliceDiscountCostT2 + 50 * CRC, aliceBalanceT4);
        assertEq(bobBalanceT2 + bobDiscountCostT2 - 50 * CRC, bobBalanceT4);
    }
}
