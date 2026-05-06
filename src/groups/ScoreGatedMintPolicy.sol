// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "./BaseMintPolicy.sol";

/**
 * @notice Minimal interface to the off-chain score verifier
 * (e.g. NewMockScore — sparse Merkle tree of trust scores).
 *
 * `verifyScore` is a pure-storage view: given an address, a claimed score
 * and an SMT proof, it returns true iff the proof reconstructs to the
 * latest published root.
 */
interface IScoreVerifier {
    function verifyScore(address user, uint256 score, bytes calldata proof) external view returns (bool);
}

/**
 * @notice Mint policy gated by an off-chain trust score.
 *
 * Mint is allowed iff:
 *   1. the caller-provided `score` is >= `scoreThreshold`, and
 *   2. the SMT proof verifies against the latest published root in `verifier`.
 *
 * The score and proof are passed through `_data` as
 * `abi.encode(uint256 score, bytes proof)`. The `_group` argument is ignored
 * because the current verifier (NewMockScore) is single-group; a future
 * multi-group verifier would key roots by group inside `verifyScore`.
 *
 * Other policy hooks (`beforeRedeemPolicy`, `beforeBurnPolicy`) inherit base
 * behavior — redeem returns the requested collateral, burn always returns true.
 */
contract ScoreGatedMintPolicy is MintPolicy {
    IScoreVerifier public immutable verifier;
    uint256 public immutable scoreThreshold;

    error ScoreBelowThreshold(uint256 score, uint256 threshold);
    error ProofVerificationFailed(address minter, uint256 score);

    constructor(IScoreVerifier _verifier, uint256 _scoreThreshold) {
        verifier = _verifier;
        scoreThreshold = _scoreThreshold;
    }

    function beforeMintPolicy(
        address _minter,
        address, /*_group*/
        uint256[] calldata, /*_collateral*/
        uint256[] calldata, /*_amounts*/
        bytes calldata _data
    ) external view override returns (bool) {
        (uint256 score, bytes memory proof) = abi.decode(_data, (uint256, bytes));
        if (score < scoreThreshold) revert ScoreBelowThreshold(score, scoreThreshold);
        if (!verifier.verifyScore(_minter, score, proof)) revert ProofVerificationFailed(_minter, score);
        return true;
    }
}
