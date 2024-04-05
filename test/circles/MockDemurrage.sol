// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/circles/Demurrage.sol";

contract MockDemurrage is Demurrage {
    // External functions

    function setInflationDayZero(uint256 _inflationDayZero) external {
        inflationDayZero = _inflationDayZero;
    }

    function gamma_64x64() external view returns (int128) {
        return GAMMA_64x64;
    }

    function r(uint256 _i) external view returns (int128) {
        return R[_i];
    }

    function rLength() external view returns (uint256) {
        return R_TABLE_LOOKUP;
    }
}
