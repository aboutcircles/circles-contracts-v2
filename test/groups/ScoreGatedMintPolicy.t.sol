// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {Test} from "forge-std/Test.sol";
import "../../src/groups/ScoreGatedMintPolicy.sol";

/**
 * @notice Mock verifier — accepts a hardcoded set of (user, score, proof) tuples.
 * Used to drive the policy without needing a real SMT setup in unit tests.
 */
contract MockScoreVerifier is IScoreVerifier {
    mapping(bytes32 => bool) private _accepted;

    function accept(address user, uint256 score, bytes memory proof) external {
        _accepted[keccak256(abi.encode(user, score, proof))] = true;
    }

    function verifyScore(address user, uint256 score, bytes calldata proof) external view returns (bool) {
        return _accepted[keccak256(abi.encode(user, score, proof))];
    }
}

contract ScoreGatedMintPolicyTest is Test {
    MockScoreVerifier verifier;
    ScoreGatedMintPolicy policy;

    address constant USER = address(0x1234);
    address constant GROUP = address(0xabcd);
    uint256 constant THRESHOLD = 50;

    function setUp() public {
        verifier = new MockScoreVerifier();
        policy = new ScoreGatedMintPolicy(IScoreVerifier(address(verifier)), THRESHOLD);
    }

    function _data(uint256 score, bytes memory proof) internal pure returns (bytes memory) {
        return abi.encode(score, proof);
    }

    function _emptyArrays() internal pure returns (uint256[] memory, uint256[] memory) {
        return (new uint256[](0), new uint256[](0));
    }

    function testAllowsMintWhenScoreAtThresholdAndProofValid() public {
        bytes memory proof = hex"deadbeef";
        verifier.accept(USER, THRESHOLD, proof);

        (uint256[] memory c, uint256[] memory a) = _emptyArrays();
        bool ok = policy.beforeMintPolicy(USER, GROUP, c, a, _data(THRESHOLD, proof));
        assertTrue(ok);
    }

    function testAllowsMintWhenScoreAboveThresholdAndProofValid() public {
        bytes memory proof = hex"deadbeef";
        verifier.accept(USER, 100, proof);

        (uint256[] memory c, uint256[] memory a) = _emptyArrays();
        bool ok = policy.beforeMintPolicy(USER, GROUP, c, a, _data(100, proof));
        assertTrue(ok);
    }

    function testRevertsWhenScoreBelowThreshold() public {
        bytes memory proof = hex"deadbeef";
        verifier.accept(USER, 49, proof);

        (uint256[] memory c, uint256[] memory a) = _emptyArrays();
        vm.expectRevert(abi.encodeWithSelector(ScoreGatedMintPolicy.ScoreBelowThreshold.selector, 49, THRESHOLD));
        policy.beforeMintPolicy(USER, GROUP, c, a, _data(49, proof));
    }

    function testRevertsWhenProofDoesNotVerify() public {
        // Verifier never sees this tuple — verifyScore returns false.
        bytes memory proof = hex"deadbeef";

        (uint256[] memory c, uint256[] memory a) = _emptyArrays();
        vm.expectRevert(abi.encodeWithSelector(ScoreGatedMintPolicy.ProofVerificationFailed.selector, USER, 80));
        policy.beforeMintPolicy(USER, GROUP, c, a, _data(80, proof));
    }

    function testIgnoresGroupArgument() public {
        // Same proof works for any group (single-group verifier).
        bytes memory proof = hex"deadbeef";
        verifier.accept(USER, 80, proof);

        (uint256[] memory c, uint256[] memory a) = _emptyArrays();
        assertTrue(policy.beforeMintPolicy(USER, address(0xAAA1), c, a, _data(80, proof)));
        assertTrue(policy.beforeMintPolicy(USER, address(0xBBB2), c, a, _data(80, proof)));
    }

    function testImmutablesPersistAfterDeploy() public {
        assertEq(address(policy.verifier()), address(verifier));
        assertEq(policy.scoreThreshold(), THRESHOLD);
    }
}
