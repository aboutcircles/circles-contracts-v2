// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../setup/TimeCirclesSetup.sol";
import "../utils/Approximation.sol";
import "./MockDemurrage.sol";

contract DemurrageTest is Test, TimeCirclesSetup, Approximation {
    // State variables

    MockDemurrage public demurrage;

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();

        demurrage = new MockDemurrage();
    }

    // Tests

    function testDemurrageFactor() public {
        for (uint256 i = 0; i <= demurrage.rLength(); i++) {
            assertTrue(
                relativeApproximatelyEqual(
                    uint256(int256(Math64x64.pow(demurrage.gamma_64x64(), i))), uint256(int256(demurrage.r(i))), DUST
                )
            );
        }
    }
}
