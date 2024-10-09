// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../errors/Errors.sol";
import "../hub/IHub.sol";

contract BaseOperator is ICirclesErrors, ICirclesCompactErrors {
    // State variables

    IHubV2 public hub;

    // Constructor

    constructor(IHubV2 _hub) {
        if (address(_hub) == address(0)) {
            // Must not be the zero address.
            // revert CirclesAddressCannotBeZero(0);
            revert CirclesErrorNoArgs(0x12);
        }

        hub = _hub;
    }
}
