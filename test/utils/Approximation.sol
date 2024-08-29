// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {ABDKMath64x64 as Math64x64} from "lib/abdk-libraries-solidity/ABDKMath64x64.sol";

contract Approximation {
    // Constants

    int128 private constant ONE = int128(2 ** 64);

    // 1% in 64x64 fixed point: integer approximation of 2**64 / 100
    int128 internal constant ONE_PERCENT = int128(184467440737095516);

    // 0.001% in 64x64 fixed point: integer approximation of 2**64 / 10**5
    int128 internal constant ONE_IN_HUNDRED_THOUSAND = int128(184467440737096);

    // Dust in 64x64 fixed point: integer approximation of 2**64 / 10**18
    int128 internal constant DUST = int128(18);

    // Public functions

    function approximatelyEqual(uint256 _a, uint256 _b, uint256 _epsilon) public pure returns (bool) {
        return _a > _b ? _a - _b <= _epsilon : _b - _a <= _epsilon;
    }

    function relativeApproximatelyEqual(uint256 _a, uint256 _b, int128 _epsilon) public pure returns (bool) {
        require(_epsilon >= 0, "Approximation: negative epsilon");
        require(_epsilon <= ONE, "Approximation: epsilon too large");
        if (_a == _b) {
            return true;
        }
        if (_a == 0 || _b == 0) {
            return _epsilon == ONE;
        }

        // calculate the absolute difference
        uint256 diff = _a > _b ? _a - _b : _b - _a;

        // use the larger of the two values as denominator
        uint256 max = _a > _b ? _a : _b;

        // calculate the relative difference
        int128 relDiff = Math64x64.divu(diff, max);

        return relDiff <= _epsilon;
    }
}
