// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../../../src/groups/UpgradeableRenounceableProxy.sol";
import "../../../src/errors/Errors.sol";
import "../groupSetup.sol";

contract usePolicyUpgradeableRenounceableProxyTest is Test, GroupSetup {
    // State variables
    address public group;

    // Constructor

    constructor() GroupSetup() {}

    // Setup

    function setUp() public {
        // first 35 addresses are registered as human
        // in mock deployment, with 14 days of mint
        groupSetup();

        // 36: Kevin
        group = addresses[36];
    }

    // Tests

    function testRegisterGroupWithProxyPolicy() public {
        _createGroupWithProxyPolicy();
    }

    function testMintGroupWithProxyPolicy() public {
        _createGroupWithProxyPolicy();

        address alice = addresses[0];

        // group must trust alice
        vm.prank(group);
        hub.trust(alice, INDEFINITE_FUTURE);

        // test minting to group
        _testGroupMintOwnCollateral(alice, group, 1 * CRC);
    }

    // Internal functions

    function _createGroupWithProxyPolicy() internal returns (UpgradeableRenounceableProxy) {
        // create a proxy deployment with the mint policy as implementation
        vm.startPrank(group);
        UpgradeableRenounceableProxy proxy = new UpgradeableRenounceableProxy(mintPolicy, "");
        hub.registerGroup(address(proxy), "ProxyPolicyGroup", "PPG", bytes32(0));
        vm.stopPrank();

        return proxy;
    }

    function _testGroupMintOwnCollateral(address _minter, address _group, uint256 _amount) internal {
        uint256 tokenIdGroup = uint256(uint160(_group));

        address[] memory collateral = new address[](1);
        uint256[] memory amounts = new uint256[](1);
        collateral[0] = _minter;
        amounts[0] = _amount;

        // check balance of group before mint
        uint256 balanceBefore = hub.balanceOf(_minter, tokenIdGroup);

        vm.prank(_minter);
        hub.groupMint(_group, collateral, amounts, "");

        // check balance of group after mint
        uint256 balanceAfter = hub.balanceOf(_minter, tokenIdGroup);
        assertEq(balanceAfter, balanceBefore + _amount);
    }
}
