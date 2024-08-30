// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "./Demurrage.sol";

contract BatchedDemurrage is Demurrage {
    /**
     * @notice Converts a batch of inflationary values to demurrage values for a given day since inflation_day_zero.
     * @param _inflationaryValues Batch of inflationary values to convert to demurrage values.
     * @param _day Day since inflation_day_zero to convert the inflationary values to demurrage values.
     */
    function convertBatchInflationaryToDemurrageValues(uint256[] memory _inflationaryValues, uint64 _day)
        public
        pure
        returns (uint256[] memory)
    {
        // calculate the demurrage value by multiplying the value by GAMMA^days
        // note: same remark on precision as in convertInflationaryToDemurrageValue
        int128 r = Math64x64.pow(GAMMA_64x64, uint256(_day));
        uint256[] memory demurrageValues = new uint256[](_inflationaryValues.length);
        for (uint256 i = 0; i < _inflationaryValues.length; i++) {
            demurrageValues[i] = Math64x64.mulu(r, _inflationaryValues[i]);
        }
        return demurrageValues;
    }

    /**
     * @notice Converts a batch of demurrage values to inflationary values for a given day since inflation_day_zero.
     * @param _demurrageValues Batch of demurrage values to convert to inflationary values.
     * @param _dayUpdated Day since inflation_day_zero to convert the demurrage values to inflationary values.
     */
    function convertBatchDemurrageToInflationaryValues(uint256[] memory _demurrageValues, uint64 _dayUpdated)
        public
        pure
        returns (uint256[] memory)
    {
        // calculate the inflationary value by dividing the value by GAMMA^days
        // note: GAMMA < 1, so dividing by a power of it, returns a bigger number,
        //       so the numerical imprecision is introduced the least significant bits.
        int128 f = Math64x64.pow(BETA_64x64, uint256(_dayUpdated));
        uint256[] memory inflationaryValues = new uint256[](_demurrageValues.length);
        for (uint256 i = 0; i < _demurrageValues.length; i++) {
            inflationaryValues[i] = Math64x64.mulu(f, _demurrageValues[i]);
        }
        return inflationaryValues;
    }
}
