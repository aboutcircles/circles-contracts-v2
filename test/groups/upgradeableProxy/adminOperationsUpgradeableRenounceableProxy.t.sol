// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {console2, Test} from "forge-std/Test.sol";
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
    bytes32 internal constant IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

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

    function testGetImplementation(address anyCaller) public {
        address implementation = proxy.implementation();
        assertEq(implementation, mintPolicy);
        assertEq(implementation, _readImplementationSlot());

        // static call is hardcoded in the proxy, this means that function with the same
        // selector in any implementation is unreachable (selector clashes)

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        vm.prank(anyCaller);
        implementation = proxy.implementation();
        // should not return the mockPolicy value
        assertTrue(implementation != address(0xff));
        // should return the current implementation
        assertEq(implementation, mockMintPolicyWithSelectorClashes);
        assertEq(implementation, _readImplementationSlot());
    }

    /* todo: - test getting admin from proxy (DONE)
     *       - test admin cannot be changed
     *       - test noone else can call upgradeToAndCall
     *       - test upgradeToAndCall with call data
     *       - test renouncing admin (DONE)
     *       - test accessibility of interface functions from non-Admin callers (DONE)
     */

    // External upgradeToAndCall(address,bytes)

    function testAdminUpgradeToAndCall() public {
        address originalImplementation = proxy.implementation();
        assertEq(originalImplementation, mintPolicy);

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        // should upgrade the proxy to the new implementation as called by admin
        // despite the fact that current implementation has upgradeToAndCall function with different logic
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

    // External renounceUpgradeability()

    function testAdminRenounceUpgradeability() public {
        // current admin
        address admin = _readProxyAdminSlot();
        assertEq(admin, group);

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        // should renounce admin as called by admin
        // despite the fact that current implementation has renounceUpgradeability function with different logic
        vm.prank(group);
        proxy.renounceUpgradeability();

        // renounced admin
        admin = _readProxyAdminSlot();
        assertEq(admin, address(0x1));
    }

    function testNonAdminRenounceUpgradeability(address nonAdmin) public {
        vm.assume(nonAdmin != group);

        vm.prank(nonAdmin);
        // should revert as proxy fallback after checking that caller is not admin
        // redirects call to implementation, which doesn't have related selector
        vm.expectRevert();
        proxy.renounceUpgradeability();

        // let's upgrade to implementation with selector clashes
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        vm.prank(nonAdmin);
        bool returnedBool = IMockMintPolicyWithSelectorClashes(address(proxy)).renounceUpgradeability();
        // should not call proxy native renounceUpgradeability as fallback must redirect call to the implementation,
        // however should find a selector match inside the implementation and execute the implementation logic
        assertTrue(returnedBool);
        // admin shouldn't be renounced
        address admin = _readProxyAdminSlot();
        assertEq(admin, group);
    }

    function testRenouncedAdminEqualNonAdmin() public {
        // todo: update forge-std
        uint256 snapshot = vm.snapshot();

        // admin should experience same behaviour as non admin after renounced upgradeability

        // default implementation
        vm.startPrank(group);
        proxy.renounceUpgradeability();
        vm.expectRevert();
        proxy.renounceUpgradeability();
        vm.expectRevert();
        proxy.upgradeToAndCall(address(0xdead), "");
        vm.stopPrank();

        // let's revert to initial state to upgrade to implementation with selector clashes
        vm.revertTo(snapshot);
        _upgradeToAndCall(mockMintPolicyWithSelectorClashes, "");

        // implementation with selector clashes
        vm.startPrank(group);
        proxy.renounceUpgradeability();
        bool returnedBool = IMockMintPolicyWithSelectorClashes(address(proxy)).renounceUpgradeability();
        assertTrue(returnedBool);
        (address returnedAddress, bytes memory returnedBytes) =
            IMockMintPolicyWithSelectorClashes(address(proxy)).upgradeToAndCall(newMintPolicy, "newMintPolicy");
        assertEq(returnedAddress, newMintPolicy);
        assertEq(keccak256(returnedBytes), keccak256("newMintPolicy"));
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

    function _readProxyAdminSlot() internal view returns (address admin) {
        admin = address(uint160(uint256(vm.load(address(proxy), ADMIN_SLOT))));
    }

    function _readImplementationSlot() internal view returns (address implementation) {
        implementation = address(uint160(uint256(vm.load(address(proxy), IMPLEMENTATION_SLOT))));
    }
}
