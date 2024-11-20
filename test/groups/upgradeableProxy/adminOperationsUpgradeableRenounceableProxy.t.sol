// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import {StorageSlot} from "@openzeppelin/contracts/utils/StorageSlot.sol";
import "forge-std/console.sol";
import "src/errors/Errors.sol";
import "test/groups/groupSetup.sol";
import {
    UpgradeableRenounceableProxy, IUpgradeableRenounceableProxy
} from "src/groups/UpgradeableRenounceableProxy.sol";
import {
    MockMintPolicyWithSelectorClashes,
    IMockMintPolicyWithSelectorClashes
} from "test/groups/upgradeableProxy/mocks/MockMintPolicyWithSelectorClashes.sol";

contract adminOperationsUpgradeableRenounceableProxy is Test, GroupSetup {
    // Constants

    bytes32 internal constant ADMIN_SLOT = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    // State variables

    address public group;
    IUpgradeableRenounceableProxy public proxy;
    // copy of BaseMintPolicy
    address public newMintPolicy;
    address public mockMintPolicyWithSelectorClashes;

    // Constructor

    constructor() GroupSetup() {}

    // Setup

    function setUp() public {
        // first 35 addresses are registered as human
        // in mock deployment, with 14 days of mint
        groupSetup();

        // 36: Kevin
        group = addresses[36];

        // create a proxy deployment with the mint policy as implementation
        vm.startPrank(group);
        proxy = IUpgradeableRenounceableProxy(address(new UpgradeableRenounceableProxy(mintPolicy, "")));
        hub.registerGroup(address(proxy), "ProxyPolicyGroup", "PPG", bytes32(0));
        vm.stopPrank();

        for (uint256 i = 0; i < 5; i++) {
            vm.prank(group);
            hub.trust(addresses[i], INDEFINITE_FUTURE);
        }

        // deploy a new copy of base mint policy
        newMintPolicy = address(new MintPolicy());

        // deploy a policy mock designed to simulate proxy selector clashes
        mockMintPolicyWithSelectorClashes = address(new MockMintPolicyWithSelectorClashes());
    }

    // Tests

    // External implementation() returns(address)

    function testGetImplementation() public {
        address implementation = proxy.implementation();
        assertEq(implementation, mintPolicy);
    }

    /* todo: - test getting admin from proxy
     *       - test admin cannot be changed
     *       - test noone else can call upgradeToAndCall
     *       - test upgradeToAndCall with call data
     *       - test renouncing admin (DONE)
     *       - test accessibility of interface functions from non-Admin callers
     */

    // External upgradeToAndCall(address,bytes)

    function testAdminUpgradeToAndCall() public {
        address originalImplementation = proxy.implementation();
        assertEq(originalImplementation, mintPolicy);

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        // should upgrade the proxy to the new implementation as called by admin
        vm.prank(group);
        proxy.upgradeToAndCall(newMintPolicy, "");

        // check that the implementation has changed
        address newImplementation = proxy.implementation();
        assertEq(newImplementation, newMintPolicy);

        // test minting to group with new policy
        _testGroupMintOwnCollateral(addresses[0], group, 1 * CRC);
    }

    function testNonAdminUpgradeToAndCall(address nonAdmin) public {
        vm.assume(nonAdmin != group);

        vm.prank(nonAdmin);
        // should revert as proxy fallback after checking that caller is not admin
        // redirects call to implementation, which doesn't have related selector
        vm.expectRevert();
        proxy.upgradeToAndCall(newMintPolicy, "");

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        vm.prank(nonAdmin);
        (address returnedAddress, bytes memory returnedBytes) =
            IMockMintPolicyWithSelectorClashes(address(proxy)).upgradeToAndCall(newMintPolicy, "newMintPolicy");
        // should not call proxy native upgradeToAndCall as fallback must redirect call to the implementation,
        // however should find a selector match inside the implementation and execute the implementation logic
        assertEq(returnedAddress, newMintPolicy);
        assertEq(keccak256(returnedBytes), keccak256("newMintPolicy"));
        // implementation shouldn't be changed
        assertEq(mockMintPolicyWithSelectorClashes, proxy.implementation(), "implementation has changed");
    }

    function testRenounceAdmin() public {
        // current admin
        address admin = address(uint160(uint256(vm.load(address(proxy), ADMIN_SLOT))));
        assertEq(admin, group);

        // renounce admin
        vm.prank(group);
        proxy.renounceUpgradeability();

        // renounced admin
        admin = address(uint160(uint256(vm.load(address(proxy), ADMIN_SLOT))));
        assertEq(admin, address(0x1));

        // expect revert when trying to upgrade to implementation 0xdead
        vm.startPrank(group);
        vm.expectRevert();
        proxy.upgradeToAndCall(address(0xdead), "");
        vm.stopPrank();
    }

    // Internal functions

    // todo: this is a duplicate; test helpers can be better structured
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

    // @dev makes admin (set to group) upgradeToAndCall call until admin is not renounced
    function _upgradeToAndCall(address newImplementation, bytes memory data) internal {
        // upgrade the proxy to the new implementation
        vm.prank(group);
        proxy.upgradeToAndCall(newImplementation, data);
        // should be new implementation
        assertEq(newImplementation, proxy.implementation(), "upgrade to new implementation failed");
    }
}
