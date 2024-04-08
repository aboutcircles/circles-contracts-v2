// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "./setup.sol";

contract MintGroupCirclesTest is Test, GroupSetup {
    // State variables
    address group;
    
    // Constructor
    
    constructor() GroupSetup() {}

    // Setup

    function setUp() public {
        groupSetup();

        // register a group already
        group = addresses[35];
        vm.prank(group);
        hub.registerGroup(mintPolicy, "Group1", "G1", bytes32(0));

        // G1 trusts first 5 humans
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(addresses[35]);
            hub.trust(addresses[i], INDEFINITE_FUTURE);
        }
    }

    // Tests

    function testGroupMint() public {
        // mint to group
        address[] memory collateral = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        collateral[0] = addresses[0];
        amounts[0] = 1 * CRC;
        vm.prank(addresses[0]);
        hub.groupMint(group, collateral, amounts, "");
    }
}