// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../hub/IHub.sol";
import "./BatchedDemurrage.sol";

contract InflationaryCirclesOperator is BatchedDemurrage {
    // Storage

    IHubV2 public hub;

    // Errors

    error InflationaryCirclesOperatorOnlyActOnBalancesOfSender(address sender, address from);

    // Modifier

    modifier OnlyActOnBalancesOfSender(address _from) {
        if (_from != msg.sender) {
            // only accept requests that act on the balances of msg.sender
            revert InflationaryCirclesOperatorOnlyActOnBalancesOfSender(msg.sender, _from);
        }
        _;
    }

    // Constructor

    constructor(IHubV2 _hub) {
        hub = _hub;
        // read inflation day zero from hub
        inflationDayZero = hub.inflationDayZero();
    }

    // Public functions

    /**
     * Inflationary balance of an account for a Circles identifier. Careful,
     * calculating the inflationary balance can introduce numerical errors
     * in the least significant digits (order of few attoCircles).
     * @param _account Address for which the balance is queried.
     * @param _id Circles identifier for which the balance is queried.
     */
    function inflationaryBalanceOf(address _account, uint256 _id) public view returns (uint256) {
        return _inflationaryBalanceOf(_account, _id);
    }

    /**
     * @notice safeInflationaryTransferFrom transfers Circles from one address to another by specifying inflationary units.
     * @param _from Address from which the Circles are transferred.
     * @param _to Address to which the Circles are transferred.
     * @param _id Circles indentifier for which the Circles are transferred.
     * @param _inflationaryValue Inflationary value of the Circles transferred.
     * @param _data Data to pass to the receiver.
     */
    function safeInflationaryTransferFrom(
        address _from,
        address _to,
        uint256 _id,
        uint256 _inflationaryValue,
        bytes memory _data
    ) public OnlyActOnBalancesOfSender(_from) {
        // convert inflationary value to todays demurrage value
        uint256 value = convertInflationaryToDemurrageValue(_inflationaryValue, day(block.timestamp));
        // if from has this operator authorized, it can call ERC1155:safeTransferFrom
        hub.safeTransferFrom(_from, _to, _id, value, _data);
    }

    /**
     * @notice safeInflationaryBatchTransferFrom transfers Circles from one address to another by specifying inflationary units.
     * @param _from Address from which the Circles are transferred.
     * @param _to Address to which the Circles are transferred.
     * @param _ids Batch of Circles identifiers for which the Circles are transferred.
     * @param _inflationaryValues Batch of inflationary values of the Circles transferred.
     * @param _data Data to pass to the receiver.
     */
    function safeInflationaryBatchTransferFrom(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _inflationaryValues,
        bytes memory _data
    ) public OnlyActOnBalancesOfSender(_from) {
        uint256[] memory values = convertBatchInflationaryToDemurrageValues(_inflationaryValues, day(block.timestamp));
        hub.safeBatchTransferFrom(_from, _to, _ids, values, _data);
    }

    // Internal functions

    /**
     * @dev Calculate the inflationary balance of a discounted balance
     * @param _account Address of the account to calculate the balance of
     * @param _id Circles identifier for which to calculate the balance
     */
    function _inflationaryBalanceOf(address _account, uint256 _id) internal view returns (uint256) {
        // retrieve the balance in demurrage units (of today)
        uint256 balance = hub.balanceOf(_account, _id);
        return convertDemurrageToInflationaryValue(balance, day(block.timestamp));
    }
}
