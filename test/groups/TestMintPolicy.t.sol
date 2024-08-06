// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "./../../src/groups/BaseMintPolicy.sol";
import "./../../src/groups/Definitions.sol";

contract MintPolicyTest is Test {
    MintPolicy public mintPolicy;

    function setUp() public {
        mintPolicy = new MintPolicy();
    }

    function testBeforeRedeemPolicy() public {
        // Define test redemption policy data
        uint256[] memory redemptionIds = new uint256[](2);
        redemptionIds[0] = 1;
        redemptionIds[1] = 2;

        uint256[] memory redemptionValues = new uint256[](2);
        redemptionValues[0] = 100;
        redemptionValues[1] = 200;

        BaseMintPolicyDefinitions.BaseRedemptionPolicy memory redemptionPolicy = BaseMintPolicyDefinitions
            .BaseRedemptionPolicy({redemptionIds: redemptionIds, redemptionValues: redemptionValues});

        bytes memory data = abi.encode(redemptionPolicy);

        // Call beforeRedeemPolicy
        (
            uint256[] memory returnedIds,
            uint256[] memory returnedValues,
            uint256[] memory burnIds,
            uint256[] memory burnValues
        ) = mintPolicy.beforeRedeemPolicy(address(this), address(this), address(this), 100, data);

        // Check returned values
        assertEq(returnedIds.length, redemptionIds.length, "Returned ids length mismatch");
        assertEq(returnedValues.length, redemptionValues.length, "Returned values length mismatch");
        for (uint256 i = 0; i < returnedIds.length; i++) {
            assertEq(returnedIds[i], redemptionIds[i], "Returned id mismatch");
            assertEq(returnedValues[i], redemptionValues[i], "Returned value mismatch");
        }

        // Check burn values (should be empty)
        assertEq(burnIds.length, 0, "Burn ids length should be zero");
        assertEq(burnValues.length, 0, "Burn values length should be zero");
    }

    function testBeforeRedeemPolicyEmptyData() public {
        bytes memory data = "";

        // Expect revert when calling beforeRedeemPolicy with empty data
        vm.expectRevert();
        mintPolicy.beforeRedeemPolicy(address(this), address(this), address(this), 100, data);
    }

    function testBeforeRedeemPolicyInvalidData() public {
        bytes memory data = abi.encode("invalid data");

        // Expect revert when decoding invalid data
        vm.expectRevert();
        mintPolicy.beforeRedeemPolicy(address(this), address(this), address(this), 100, data);
    }
}
