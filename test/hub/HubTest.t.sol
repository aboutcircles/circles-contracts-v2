// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "../../src/hub/Hub.sol";
import "../../src/hub/TypeDefinitions.sol";
import "../hub/MockHub.sol";
import "../hub/MockDeployment.sol";
import "../../src/names/NameRegistry.sol";

contract HubTest is Test {
    MockHub public hub;
    MockDeployment public deployment;
    NameRegistry public nameRegistry;

    uint256 private constant INVITATION_COST = 100 * 1e18;

    address alice;
    address bob;
    address charlie;
    address david;
    address eve;
    address frank;

    function setUp() public {
        deployment = new MockDeployment(block.timestamp, 365 days);
        hub = deployment.hub();

        nameRegistry = new NameRegistry(IHubV2(address(hub)));

        // Generate random addresses
        alice = address(uint160(uint256(keccak256(abi.encodePacked("alice")))));
        bob = address(uint160(uint256(keccak256(abi.encodePacked("bob")))));
        charlie = address(
            uint160(uint256(keccak256(abi.encodePacked("charlie"))))
        );
        david = address(uint160(uint256(keccak256(abi.encodePacked("david")))));
        eve = address(uint160(uint256(keccak256(abi.encodePacked("eve")))));
        frank = address(uint160(uint256(keccak256(abi.encodePacked("frank")))));
    }

    function registerHumanIfNotExists(address human) internal {
        if (!hub.isHuman(human)) {
            vm.startPrank(human);
            hub.registerHumanUnrestricted();
            vm.stopPrank();
        }
    }

    function testRegisterHuman() public {
        vm.startPrank(eve);
        hub.registerHumanUnrestricted();
        bool isHuman = hub.isHuman(eve);
        vm.stopPrank();
        assertTrue(isHuman, "Eve should be registered as a human");
    }

    function testMigrate() public {
        // Register Alice if not already registered
        registerHumanIfNotExists(alice);

        // Migrate Alice
        address[] memory avatars = new address[](1);
        avatars[0] = alice;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1000 * 1e18; // arbitrary amount for migration

        vm.startPrank(address(hub));
        hub.mockMigrate(alice, avatars, amounts);
        vm.stopPrank();

        // Check Alice's balance after migration
        uint256 aliceBalance = hub.balanceOf(alice, hub.toTokenId(alice));
        assertEq(
            aliceBalance,
            1000 * 1e18,
            "Alice's balance should be 1000 Circles after migration"
        );
    }

    function testInviteHuman() public {
        // Register Alice if not already registered
        registerHumanIfNotExists(alice);

        // Migrate Alice
        address[] memory avatars = new address[](1);
        avatars[0] = alice;
        uint256[] memory amounts = new uint256[](1);
        amounts[0] = 1000 * 1e18; // arbitrary amount for migration

        vm.startPrank(address(hub));
        hub.mockMigrate(alice, avatars, amounts);
        vm.stopPrank();

        // Skip time for 2 weeks before minting
        skipTime(2 weeks);

        // Ensure frank is not registered
        assertFalse(hub.isHuman(frank), "Frank should not be registered");

        // Alice must mint some Circles before inviting Frank
        vm.startPrank(alice);
        hub.personalMintWithoutV1Check();
        vm.stopPrank();

        // Mint enough Circles for Alice to cover the INVITATION_COST
        vm.startPrank(alice);
        hub.personalMintWithoutV1Check();
        vm.stopPrank();

        // Check Alice's balance
        uint256 aliceBalance = hub.balanceOf(alice, hub.toTokenId(alice));
        require(
            aliceBalance >= INVITATION_COST,
            "Alice should have enough balance to invite"
        );

        // Log Alice's balance before inviting
        emit log_named_uint("Alice balance before inviting", aliceBalance);

        // Log current block timestamp and invitationOnlyTime
        emit log_named_uint("Current block timestamp", block.timestamp);
        emit log_named_uint("invitationOnlyTime", hub.getInvitationOnlyTime());

        // Alice invites Frank (who is not registered)
        vm.startPrank(alice);
        try hub.inviteHuman(frank) {
            vm.stopPrank();
        } catch (bytes memory reason) {
            vm.stopPrank();
            emit log_named_bytes("inviteHuman failed with reason", reason);
            revert("inviteHuman failed");
        }

        // Check if Frank is now registered as a human
        bool isHuman = hub.isHuman(frank);
        assertTrue(isHuman, "Frank should be registered as a human");

        // Log Frank's registration status
        emit log_named_string(
            "Frank's registration status",
            isHuman ? "registered" : "not registered"
        );

        // Log Alice's balance after inviting
        aliceBalance = hub.balanceOf(alice, hub.toTokenId(alice));
        emit log_named_uint("Alice balance after inviting", aliceBalance);
    }

    function testRegisterCustomGroup() public {
        // Ensure David is not registered as a human
        if (hub.isHuman(david)) {
            revert("David is already registered as a human");
        }

        // Custom group parameters
        address customMint = address(this);
        address customTreasury = address(0x12345);
        string memory groupName = "Custom Group";
        string memory groupSymbol = "CG";
        bytes32 metadataDigest = 0x0000000000000000000000000000000000000000000000000000000000abcdef;

        vm.startPrank(david);
        hub.registerCustomGroup(
            customMint,
            customTreasury,
            groupName,
            groupSymbol,
            metadataDigest
        );
        vm.stopPrank();

        // Check if the group is registered
        bool isGroup = hub.isGroup(david);
        assertTrue(isGroup, "David should be registered as a custom group");

        // Check if the custom treasury and mint policy are correctly set
        address treasury = hub.treasuries(david);
        address mintPolicy = hub.mintPolicies(david);
        assertEq(
            treasury,
            customTreasury,
            "Custom treasury should be correctly set"
        );
        assertEq(
            mintPolicy,
            customMint,
            "Custom mint policy should be correctly set"
        );

        // Check if the name and symbol are correctly set
        // string memory name = nameRegistry.name(david);
        // string memory symbol = nameRegistry.symbol(david);
        // assertEq(name, groupName, "Group name should be correctly set");
        // assertEq(symbol, groupSymbol, "Group symbol should be correctly set");

        // Emit log to check details
        emit log_named_address("Group treasury", treasury);
        emit log_named_address("Group mint policy", mintPolicy);
        // emit log_named_string("Group name", name);
        // emit log_named_string("Group symbol", symbol);
    }

    function testRegisterGroup() public {
        // Ensure Eve is not registered as a human
        if (hub.isHuman(eve)) {
            revert("Eve is already registered as a human");
        }

        // Group parameters
        address mint = address(this);
        string memory groupName = "Test Group";
        string memory groupSymbol = "TST";
        bytes32 metadataDigest = 0x0000000000000000000000000000000000000000000000000000000000000000;

        vm.startPrank(eve);
        hub.registerGroup(mint, groupName, groupSymbol, metadataDigest);
        vm.stopPrank();

        // Check if the group is registered
        bool isGroup = hub.isGroup(eve);
        assertTrue(isGroup, "Eve should be registered as a group");

        // Check if the mint policy is correctly set
        address mintPolicy = hub.mintPolicies(eve);
        assertEq(mintPolicy, mint, "Mint policy should be correctly set");

        // Check if the name and symbol are correctly set
        // string memory name = nameRegistry.name(eve);
        // string memory symbol = nameRegistry.symbol(eve);
        // assertEq(name, groupName, "Group name should be correctly set");
        // assertEq(symbol, groupSymbol, "Group symbol should be correctly set");

        // Emit log to check details
        emit log_named_address("Group mint policy", mintPolicy);
        // emit log_named_string("Group name", name);
        // emit log_named_string("Group symbol", symbol);
    }

    function skipTime(uint256 time) internal {
        vm.warp(block.timestamp + time);
    }
}
