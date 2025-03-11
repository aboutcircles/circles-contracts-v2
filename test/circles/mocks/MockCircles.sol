// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Circles} from "src/circles/Circles.sol";

/**
 * @title MockCircles
 * @notice A mock implementation of the Circles contract, exposing
 *         certain internal variables and functions for testing purposes.
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
    // Getters for Circles' constants
    // -------------------------------------------------------------------------

    /**
     * @notice Returns the maximum claim duration constant, in seconds.
     * @return The maximum claim duration (2 weeks).
     */
    function getMAX_CLAIM_DURATION() external pure returns (uint256) {
        return MAX_CLAIM_DURATION;
    }

    /**
     * @notice Returns the special address that indicates
     *         the associated v1 Circles contract has been stopped.
     * @return The address(0x1) constant.
     */
    function getCIRCLES_STOPPED_V1() external pure returns (address) {
        return CIRCLES_STOPPED_V1;
    }

    /**
     * @notice Returns the constant used to represent an indefinite future time.
     * @return The maximum value of uint96.
     */
    function getINDEFINITE_FUTURE() external pure returns (uint96) {
        return INDEFINITE_FUTURE;
    }

    // -------------------------------------------------------------------------
    // Getter and Setter for the mintTimes mapping
    // -------------------------------------------------------------------------

    /**
     * @notice Returns the `mintV1Status` and `lastMintTime` for a given avatar.
     * @param _human The address of the avatar for which to retrieve mint info.
     * @return mintV1Status The status of the v1 Circles minting for `_human`.
     * @return lastMintTime The last recorded mint timestamp for `_human`.
     */
    function getMintTime(address _human) external view returns (address mintV1Status, uint96 lastMintTime) {
        MintTime memory mt = mintTimes[_human];
        return (mt.mintV1Status, mt.lastMintTime);
    }

    /**
     * @notice Sets the `mintV1Status` and `lastMintTime` for a given avatar.
     * @dev Be cautious when directly modifying `mintTimes`, as it can affect
     *      the claim issuance logic if used incorrectly in tests.
     * @param _human The address of the avatar for which to set mint info.
     * @param _mintV1Status The new v1 Circles minting status.
     * @param _lastMintTime The new last mint timestamp.
     */
    function setMintTime(address _human, address _mintV1Status, uint96 _lastMintTime) external {
        mintTimes[_human].mintV1Status = _mintV1Status;
        mintTimes[_human].lastMintTime = _lastMintTime;
    }

    // -------------------------------------------------------------------------
    // Wrapped internal functions to enable testing
    // -------------------------------------------------------------------------

    /**
     * @notice Public wrapper for the internal `_calculateIssuance` function.
     * @dev This function calculates the amount of Circles a given avatar can claim,
     *      along with the start and end of the claimable period.
     * @param _human The address of the avatar/human to calculate issuance for.
     * @return issuance The claimable Circles in attoCircles.
     * @return startPeriod The timestamp marking the start of the claimable period.
     * @return endPeriod The timestamp marking the end of the claimable period.
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
