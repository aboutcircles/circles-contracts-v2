// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../../src/errors/Errors.sol";
import "./setup.sol";

contract CompositeMintGroupsTest is Test, GroupSetup, IHubErrors {
    // State variables
    address group0;
    address group1;
    address group2;

    // Constructor

    constructor() GroupSetup() {}

    // Setup

    function setUp() public {
        groupSetup();

        group0 = addresses[35];
        group1 = addresses[36];
        group2 = addresses[37];

        // register five groups
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(addresses[35 + i]);
            hub.registerGroup(mintPolicy, avatars[i], avatars[i], bytes32(0));
        }

        address[] memory collateral = new address[](1);
        uint256[] memory amounts = new uint256[](1);

        // G0 trusts first 5 humans, and they all mint in G0
        for (uint256 i = 0; i < 5; i++) {
            vm.prank(group0);
            hub.trust(addresses[i], INDEFINITE_FUTURE);

            collateral[0] = addresses[i];
            amounts[0] = 1 * CRC;
            vm.prank(addresses[i]);
            hub.groupMint(group0, collateral, amounts, "");
        }

        // G1 trusts all 35 humans, and they all mint in G1
        for (uint256 i = 0; i < 35; i++) {
            vm.prank(group1);
            hub.trust(addresses[i], INDEFINITE_FUTURE);

            collateral[0] = addresses[i];
            amounts[0] = 1 * CRC;
            vm.prank(addresses[i]);
            hub.groupMint(group1, collateral, amounts, "");
        }

        // G2 trusts first 15 humans, and they all mint in G2
        for (uint256 i = 0; i < 15; i++) {
            vm.prank(group2);
            hub.trust(addresses[i], INDEFINITE_FUTURE);

            collateral[0] = addresses[i];
            amounts[0] = 1 * CRC;
            vm.prank(addresses[i]);
            hub.groupMint(group2, collateral, amounts, "");
        }
    }

    // Positive Tests

    function testCompositeGroupMint() public {
        // everyone already has some group Circles
        // now let G1 trust G0
        vm.prank(addresses[36]);
        hub.trust(addresses[35], INDEFINITE_FUTURE);

        // now Alice mints with G0 as collateral for G1
        address[] memory collateral = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        collateral[0] = group0;
        amounts[0] = 1 * CRC;
        vm.prank(addresses[0]);
        hub.groupMint(group1, collateral, amounts, "");
    }
}
