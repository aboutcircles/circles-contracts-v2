// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "../../src/hub/Hub.sol";
import "./MockHubV1impl.sol"; // Use the mock HubV1 contract
import "../../src/hub/TypeDefinitions.sol";
import "../../src/names/NameRegistry.sol";
import "../../src/treasury/StandardTreasury.sol";
import "../../src/treasury/StandardVault.sol";
import "../../src/lift/ERC20Lift.sol";
import "../../src/migration/Migration.sol";
import "../../src/groups/BaseMintPolicy.sol";

contract HubTest is Test {
    Hub public hub;
    NameRegistry public nameRegistry;
    StandardTreasury public standardTreasury;
    ERC20Lift public liftERC20;
    MockHubV1 public hubV1; // Reference to the MockHubV1 contract
    Migration public migration;
    MintPolicy public baseMintPolicy;

    uint256 private constant INVITATION_COST = 100 * 1e18;

    address alice;
    address bob;
    address charlie;
    address david;
    address eve;
    address frank;

    address public mastercopyStandardVault; // Declare a variable for the mastercopyStandardVault address

    // Declare avatars and amounts in the global scope
    address[] public avatars;
    uint256[] public amounts;

    function predictAddress(address deployer, uint256 nonce) internal pure returns (address) {
        return address(
            uint160(uint256(keccak256(abi.encodePacked(bytes1(0xd6), bytes1(0x94), deployer, bytes1(uint8(nonce))))))
        );
    }

    function setUp() public {
        address deployer = address(this); // Deployer is the test contract itself
        uint256 nonce = vm.getNonce(deployer); // Get the current nonce of the deployer

        emit log("Starting setUp...");
        emit log_named_uint("Deployer nonce", nonce);

        // Predict addresses for future contract deployments
        address predictedHubAddress = predictAddress(deployer, nonce + 4);
        address predictedMigrationAddress = predictAddress(deployer, nonce + 3);

        emit log_address(predictedHubAddress); // Log the predicted Hub address
        emit log_address(predictedMigrationAddress); // Log the predicted Migration address

        emit log("Deploying MockHubV1...");
        // Deploy the MockHubV1 contract
        hubV1 = new MockHubV1();
        emit log_address(address(hubV1)); // Log the HubV1 address

        emit log("Deploying StandardVault...");
        // Deploy the StandardVault contract
        StandardVault standardVault = new StandardVault();
        mastercopyStandardVault = address(standardVault);
        emit log_address(mastercopyStandardVault); // Log the vault address

        emit log("Deploying NameRegistry...");
        // Deploy the NameRegistry contract using the predicted Hub address
        nameRegistry = new NameRegistry(IHubV2(predictedHubAddress)); // Pass the predicted Hub address
        emit log_address(address(nameRegistry)); // Log the NameRegistry address

        emit log("Deploying StandardTreasury...");
        // Deploy the StandardTreasury contract using the predicted address
        standardTreasury = new StandardTreasury(
            IHubV2(predictedHubAddress), // Pass the predicted Hub address
            mastercopyStandardVault
        );
        emit log_address(address(standardTreasury)); // Log the StandardTreasury address

        emit log("Deploying Migration...");
        // Deploy the Migration contract using the predicted Hub address
        migration = new Migration(
            IHubV1(address(hubV1)),
            IHubV2(predictedHubAddress), // Pass the predicted Hub address
            block.timestamp
        );
        emit log_address(address(migration)); // Log the Migration address

        emit log("Deploying Hub...");
        // Deploy the Hub contract using the predicted Hub address
        hub = new Hub(
            IHubV1(address(hubV1)), // Pass the HubV1 address
            INameRegistry(address(nameRegistry)),
            address(migration), // Pass the migration contract address
            IERC20Lift(address(liftERC20)),
            address(standardTreasury), // Pass the StandardTreasury address
            block.timestamp, // Start of inflation day zero
            365 days, // Bootstrap time
            "https://gateway.aboutcircles.com/v2/circles/{id}.json" // Gateway URL
        );
        emit log_address(address(hub)); // Log the actual deployed Hub address

        // Assert that the predicted Hub address matches the actual deployed Hub address
        assertEq(address(hub), predictedHubAddress, "Deployed Hub address should match the predicted address");

        // Assert the hub address is correctly set in NameRegistry
        assertEq(address(nameRegistry.hub()), address(hub), "Hub address should be correctly set in NameRegistry");

        emit log("Deploying BaseMintPolicy...");
        // Deploy the BaseMintPolicy contract
        baseMintPolicy = new MintPolicy();
        emit log_address(address(baseMintPolicy)); // Log the BaseMintPolicy address

        emit log("Checking if vault is already initialized...");
        bool vaultInitialized = (standardVault.hub() != IHubV2(address(0))); // Check if hub is initialized in vault

        if (!vaultInitialized) {
            emit log("Setting up vault for the first time...");
            standardVault.setup(IHubV2(address(hub)));
            emit log("Vault setup complete");
        } else {
            emit log("Vault is already initialized, skipping setup...");
        }

        // Initialize the avatars and amounts arrays
        avatars.push(address(0)); // Placeholder to initialize the array with a dummy value
        amounts.push(0);

        // Generate random addresses for testing
        alice = address(uint160(uint256(keccak256(abi.encodePacked("alice")))));
        bob = address(uint160(uint256(keccak256(abi.encodePacked("bob")))));
        charlie = address(uint160(uint256(keccak256(abi.encodePacked("charlie")))));
        david = address(uint160(uint256(keccak256(abi.encodePacked("david")))));
        eve = address(uint160(uint256(keccak256(abi.encodePacked("eve")))));
        frank = address(uint160(uint256(keccak256(abi.encodePacked("frank")))));

        avatars.push(alice);
        avatars.push(bob);
        avatars.push(charlie);
        avatars.push(david);
        avatars.push(eve);
        avatars.push(frank);

        // Final checks for key addresses
        require(address(hub) != address(0), "Hub address is zero");
        require(address(migration) != address(0), "Migration address is zero");
        require(address(standardTreasury) != address(0), "StandardTreasury address is zero");
        require(address(nameRegistry) != address(0), "NameRegistry address is zero");
        require(mastercopyStandardVault != address(0), "MastercopyStandardVault address is zero");

        emit log("Setup completed successfully");
    }

    function registerHumanIfNotExists(address human) internal {
        if (!hub.isHuman(human)) {
            vm.startPrank(human);
            hub.registerHuman(bytes32(0));
            vm.stopPrank();
        }
    }

    function testRegisterHuman() public {
        // Sign up Eve in V1 and stop her V1 Circles contract
        ITokenV1 eveV1Token = signupInV1(eve);

        // Stop minting in V1 (this is needed before registration in HubV2)
        vm.startPrank(eve);
        eveV1Token.stop();
        vm.stopPrank();

        // Now, try to register Eve in HubV2
        vm.startPrank(eve);
        hub.registerHuman(bytes32(0)); // Passing empty metadata digest for simplicity
        vm.stopPrank();

        // Check that Eve is now registered as a human in HubV2
        bool isHuman = hub.isHuman(eve);
        assertTrue(isHuman, "Eve should be registered as a human in HubV2");
    }

    function testMigrate() public {
        // Register Alice in V1 and stop her V1 Circles contract
        ITokenV1 aliceV1Token = signupInV1(alice);

        // Stop Alice's V1 minting
        vm.startPrank(alice);
        aliceV1Token.stop();
        vm.stopPrank();

        // Register Alice in Hub V2 if not already registered
        registerHumanIfNotExists(alice);

        // Declare and initialize arrays specifically for Alice's migration
        address[] memory singleAvatar = new address[](1);
        uint256[] memory singleAmount = new uint256[](1);

        // Assign values to the arrays
        singleAvatar[0] = alice;
        singleAmount[0] = 1000 * 1e18; // arbitrary amount for migration

        // Perform the migration for Alice only
        vm.startPrank(address(migration));
        hub.migrate(alice, singleAvatar, singleAmount);
        vm.stopPrank();

        // Check Alice's balance after migration
        uint256 aliceBalance = hub.balanceOf(alice, hub.toTokenId(alice));
        assertEq(aliceBalance, 1000 * 1e18, "Alice's balance should be 1000 Circles after migration");
    }

    function testInviteHuman() public {
        // Register Alice in V1 and stop her V1 Circles contract
        ITokenV1 aliceV1Token = signupInV1(alice);

        // Stop Alice's V1 minting
        vm.startPrank(alice);
        aliceV1Token.stop();
        vm.stopPrank();

        // Register Alice in Hub V2 if not already registered
        registerHumanIfNotExists(alice);

        skipTime(2 weeks);

        // Alice must mint some Circles before inviting Frank
        vm.startPrank(alice);
        hub.personalMint();
        vm.stopPrank();

        // Mint enough Circles for Alice to cover the INVITATION_COST
        vm.startPrank(alice);
        hub.personalMint();
        vm.stopPrank();

        // Check Alice's balance
        uint256 aliceBalance = hub.balanceOf(alice, hub.toTokenId(alice));
        require(aliceBalance >= INVITATION_COST, "Alice should have enough balance to invite");

        // Log Alice's balance before inviting
        emit log_named_uint("Alice balance before inviting", aliceBalance);

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
        hub.registerCustomGroup(customMint, customTreasury, groupName, groupSymbol, metadataDigest);
        vm.stopPrank();

        // Check if the group is registered
        bool isGroup = hub.isGroup(david);
        assertTrue(isGroup, "David should be registered as a custom group");

        // Check if the custom treasury and mint policy are correctly set
        address treasury = hub.treasuries(david);
        address mintPolicy = hub.mintPolicies(david);
        assertEq(treasury, customTreasury, "Custom treasury should be correctly set");
        assertEq(mintPolicy, customMint, "Custom mint policy should be correctly set");
    }

    function testRegisterGroup() public {
        // Use a new address for the group registration (e.g., david or another unregistered address)
        address groupAddress = david;

        // Ensure the group address is not already registered as a human or group
        if (hub.isHuman(groupAddress) || hub.isGroup(groupAddress)) {
            revert("Address is already registered as a human or group");
        }

        // Group parameters
        address mint = address(baseMintPolicy); // Use the deployed baseMintPolicy
        string memory groupName = "Test Group";
        string memory groupSymbol = "TST";
        bytes32 metadataDigest = 0x0000000000000000000000000000000000000000000000000000000000000000;

        // Start prank to simulate that the group address is calling registerGroup
        vm.startPrank(groupAddress);
        hub.registerGroup(mint, groupName, groupSymbol, metadataDigest);
        vm.stopPrank();

        // Check if the group is registered
        bool isGroup = hub.isGroup(groupAddress);
        assertTrue(isGroup, "The address should be registered as a group");

        // Check if the mint policy is correctly set
        address mintPolicy = hub.mintPolicies(groupAddress);
        assertEq(mintPolicy, mint, "Mint policy should be correctly set");
    }

    function skipTime(uint256 time) internal {
        vm.warp(block.timestamp + time);
    }

    // Private functions

    function signupInV1(address _user) private returns (ITokenV1) {
        vm.prank(_user);
        hubV1.signup();
        ITokenV1 token = ITokenV1(hubV1.userToToken(_user));
        require(address(token) != address(0), "Token not minted");
        require(token.owner() == _user, "Token not owned by user");
        return token;
    }
}
