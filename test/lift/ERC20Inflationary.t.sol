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
import "../utils/Approximation.sol";

contract ERC20LiftTest is Test, TimeCirclesSetup, HumanRegistration, Approximation {
    // State variables

    MockDeployment public mockDeployment;
    MockHub public hub;

    mapping(address => InflationaryCircles) public erc20s;

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

        // lift some CRC into respective inflationary ERC20's
        for (uint256 i = 0; i < 2; i++) {
            vm.prank(addresses[i]);
            hub.wrap(addresses[i], 100 * CRC, CirclesType.Inflation);
        }

        // get ERC20's
        for (uint256 i = 0; i < 2; i++) {
            erc20s[addresses[i]] =
                InflationaryCircles(mockDeployment.erc20Lift().erc20Circles(CirclesType.Inflation, addresses[i]));
        }
    }

    // Tests

    function testWrapAndUnwrapInflationaryERC20() public {
        InflationaryCircles aliceERC20 = erc20s[addresses[0]];
        uint256 aliceId = hub.toTokenId(addresses[0]);

        // Alice first clears her balance on the hub
        uint256 aliceBalance = hub.balanceOf(addresses[0], aliceId);
        console.log("Alice balance on hub: ", aliceBalance);
        vm.prank(addresses[0]);
        hub.burn(aliceId, aliceBalance, "");
        aliceBalance = hub.balanceOf(addresses[0], aliceId);
        console.log("Alice balance on hub after burn: ", aliceBalance);

        // Alice unwraps her 100 CRC (demurrage)
        // first get her balance in inflationary ERC20
        uint256 aliceERC20Balance = aliceERC20.balanceOf(addresses[0]);
        console.log("Alice balance in inflationary ERC20: ", aliceERC20Balance);
        vm.prank(addresses[0]);
        aliceERC20.unwrap(aliceERC20Balance);
        aliceERC20Balance = aliceERC20.balanceOf(addresses[0]);
        console.log("Alice balance in inflationary ERC20 after unwrap: ", aliceERC20Balance);

        // Alice balance on hub should be 100 CRC again
        aliceBalance = hub.balanceOf(addresses[0], aliceId);
        console.log("Alice balance on hub after unwrap: ", aliceBalance);
        assertTrue(relativeApproximatelyEqual(aliceBalance, 100 * CRC, 10 * DUST));
    }
}
