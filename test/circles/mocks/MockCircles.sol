// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Circles} from "src/circles/Circles.sol";

/**
 * @title MockCircles
 * @notice A mock implementation of the Circles contract, exposing
 *         certain internal functions for testing purposes.
 */
contract MockCircles is Circles {
    /**
     * @notice Deploys the mock contract.
     * @dev Calls the parent Circles constructor to set the URI
     *      and the inflationDayZero timestamp.
     * @param _inflationDayZero The reference day (timestamp) from which inflation is calculated.
     * @param newuri The initial metadata URI.
     */
    constructor(uint256 _inflationDayZero, string memory newuri) Circles(_inflationDayZero, newuri) {}

    // -------------------------------------------------------------------------
    // Wrapped internal functions to enable testing
    // -------------------------------------------------------------------------

    /**
     * @notice Public wrapper for the internal `_calculateIssuance` function.
     * @dev This function calculates the amount of Circles a given avatar can claim,
     *      along with the start and end of the claimable period.
     * @param _human The address of the avatar/human to calculate issuance for.
     * @return issuance The claimable Circles in attoCircles.
     * @return startPeriod The timestamp that marks the start of the claimable period.
     * @return endPeriod The timestamp that marks the end of the claimable period.
     */
    function calculateIssuance(address _human)
        external
        view
        returns (uint256 issuance, uint256 startPeriod, uint256 endPeriod)
    {
        (issuance, startPeriod, endPeriod) = _calculateIssuance(_human);
    }

    /**
     * @notice External wrapper for the internal `_claimIssuance` function.
     * @dev This function claims the Circles issuance for a specified avatar/human
     *      and updates the avatar’s last mint time.
     * @param _human The address of the avatar/human claiming issuance.
     */
    function claimIssuance(address _human) external {
        _claimIssuance(_human);
    }

    /**
     * @notice External wrapper for the internal `_mintAndUpdateTotalSupply` function.
     * @dev Mints a specified value of Circles to an account for a given token ID,
     *      and updates the recorded discounted total supply.
     * @param _account The address to receive the newly minted Circles.
     * @param _id The ID of the token type to mint.
     * @param _value The amount of tokens to mint (in attoCircles).
     * @param _data Additional data that might be passed along to a receiver contract.
     * @param _doAcceptanceCheck Whether to perform the ERC1155 receiver acceptance check.
     */
    function mintAndUpdateTotalSupply(
        address _account,
        uint256 _id,
        uint256 _value,
        bytes memory _data,
        bool _doAcceptanceCheck
    ) external {
        _mintAndUpdateTotalSupply(_account, _id, _value, _data, _doAcceptanceCheck);
    }

    /**
     * @notice External wrapper for the internal `_burnAndUpdateTotalSupply` function.
     * @dev Burns a specified amount of Circles from an account for a given token ID,
     *      and updates the recorded discounted total supply.
     * @param _account The address whose tokens are being burned.
     * @param _id The ID of the token type to burn.
     * @param _value The amount of tokens to burn (in attoCircles).
     */
    function burnAndUpdateTotalSupply(address _account, uint256 _id, uint256 _value) external {
        _burnAndUpdateTotalSupply(_account, _id, _value);
    }

    /**
     * @notice Public wrapper for the internal `_max` function.
     * @dev Returns the maximum of two uint256 values.
     * @param a The first value.
     * @param b The second value.
     * @return The greater of `a` and `b`.
     */
    function max(uint256 a, uint256 b) external pure returns (uint256) {
        return _max(a, b);
    }
}
