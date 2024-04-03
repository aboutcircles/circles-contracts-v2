// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../setup/TimeCirclesSetup.sol";
import "../setup/HumanRegistration.sol";
import "../hub/MockPathTransferHub.sol";

contract ERC20LiftTest is Test, TimeCirclesSetup, HumanRegistration {
    // State variables

    MockPathTransferHub public mockHub;

    // Constructor

    constructor() HumanRegistration(2) {}

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();
    }
}
