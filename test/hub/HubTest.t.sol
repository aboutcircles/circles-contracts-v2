// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import "../../src/hub/Hub.sol";
import "../../src/hub/TypeDefinitions.sol";
import "../hub/MockHub.sol";
import "../hub/MockDeployment.sol";

contract HubTest is Test {
    MockHub public hub;
    MockDeployment public deployment;

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

        // Generate random addresses
        alice = address(uint160(uint256(keccak256(abi.encodePacked("alice")))));
        bob = address(uint160(uint256(keccak256(abi.encodePacked("bob")))));
        charlie = address(
            uint160(uint256(keccak256(abi.encodePacked("charlie"))))
        );
        david = address(uint160(uint256(keccak256(abi.encodePacked("david")))));
        eve = address(uint160(uint256(keccak256(abi.encodePacked("eve")))));
        frank = address(uint160(uint256(keccak256(abi.encodePacked("frank")))));

        // Register some humans if not already registered
        registerHumanIfNotExists(alice);
        registerHumanIfNotExists(bob);
        registerHumanIfNotExists(charlie);
        registerHumanIfNotExists(david);
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

    function testInviteHuman() public {
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

        // Alice invites Frank (who is not registered)
        vm.startPrank(alice);
        hub.inviteHuman(frank);
        vm.stopPrank();

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

    function testRegisterGroup() public {
        vm.startPrank(alice);
        hub.registerGroup(address(this), "Test Group", "TST", bytes32(0));
        bool isGroup = hub.isGroup(alice);
        vm.stopPrank();
        assertTrue(isGroup, "Alice should be registered as a group");
    }

    function testSetTrust() public {
        vm.startPrank(alice);
        hub.trust(bob, uint96(block.timestamp + 1 days));
        bool isTrusted = hub.isTrusted(alice, bob);
        vm.stopPrank();
        assertTrue(isTrusted, "Alice should trust Bob");
    }

    function testStopMinting() public {
        vm.startPrank(alice);
        hub.stop();
        bool isStopped = hub.stopped(alice);
        vm.stopPrank();
        assertTrue(isStopped, "Alice's minting should be stopped");
    }

    function testOperateFlowMatrixConsentedFlow() public {
        // Setup trust relationships
        setTrust(alice, bob);
        setTrust(bob, charlie);
        setTrust(charlie, david);

        // Setup flow matrix
        address[] memory flowVertices = new address[](4);
        flowVertices[0] = alice;
        flowVertices[1] = bob;
        flowVertices[2] = charlie;
        flowVertices[3] = david;

        TypeDefinitions.FlowEdge[] memory flow = new TypeDefinitions.FlowEdge[](
            3
        );
        flow[0] = TypeDefinitions.FlowEdge(5000, 0);
        flow[1] = TypeDefinitions.FlowEdge(5000, 0);
        flow[2] = TypeDefinitions.FlowEdge(5000, 1);

        uint16[] memory coordinates = new uint16[](9);
        coordinates[0] = 0; // Alice -> Bob
        coordinates[1] = 0;
        coordinates[2] = 1;
        coordinates[3] = 1; // Bob -> Charlie
        coordinates[4] = 1;
        coordinates[5] = 2;
        coordinates[6] = 2; // Charlie -> David
        coordinates[7] = 2;
        coordinates[8] = 3;

        TypeDefinitions.Stream[] memory streams = new TypeDefinitions.Stream[](
            1
        );
        streams[0] = TypeDefinitions.Stream(0, new uint16[](1), new bytes(0));
        streams[0].flowEdgeIds[0] = 2;

        bytes memory packedCoordinates = packCoordinates(coordinates);

        // Set approvals for each address in the flow
        setApproval(alice, alice);
        setApproval(bob, alice);
        setApproval(charlie, alice);
        setApproval(david, alice);

        vm.startPrank(alice);
        hub.operateFlowMatrix(flowVertices, flow, streams, packedCoordinates);
        vm.stopPrank();
    }

    function setTrust(address from, address to) internal {
        vm.startPrank(from);
        hub.trust(to, uint96(block.timestamp + 1 days));
        vm.stopPrank();
    }

    function setApproval(address owner, address operator) internal {
        vm.startPrank(owner);
        hub.setApprovalForAll(operator, true);
        vm.stopPrank();
    }

    function packCoordinates(
        uint16[] memory _coordinates
    ) private pure returns (bytes memory packedData_) {
        packedData_ = new bytes(_coordinates.length * 2);
        for (uint256 i = 0; i < _coordinates.length; i++) {
            packedData_[2 * i] = bytes1(uint8(_coordinates[i] >> 8)); // High byte
            packedData_[2 * i + 1] = bytes1(uint8(_coordinates[i] & 0xFF)); // Low byte
        }
    }

    function skipTime(uint256 _duration) public {
        uint256 afterSkip = block.timestamp + _duration;
        vm.warp(afterSkip);
    }
}
