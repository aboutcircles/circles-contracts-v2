// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "./setup.sol";

contract GroupMintTest is Test, GroupSetup {
    // Constructor

    constructor() GroupSetup() {}

    // Setup

    function setUp() public {
        groupSetup();
    }

    // Tests

    function testRegisterGroup() public {
        // name our group
        address group = addresses[35];
        vm.startPrank(group);
        hub.registerGroup(mintPolicy, "Group1", "G1", bytes32(0));
    }

    // todo: write more tests on creating groups
}