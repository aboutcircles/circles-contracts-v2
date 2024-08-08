// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../hub/IHub.sol";
import "./Demurrage.sol";

contract InflationaryCirclesOperator is Demurrage {
    // Storage

    IHubV2 public hub;

    // Constructor

    constructor(IHubV2 _hub) {
        hub = _hub;
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

    // /**
    //  * @notice safeInflationaryTransferFrom transfers Circles from one address to another by specifying inflationary units.
    //  * @param _from Address from which the Circles are transferred.
    //  * @param _to Address to which the Circles are transferred.
    //  * @param _id Circles indentifier for which the Circles are transferred.
    //  * @param _inflationaryValue Inflationary value of the Circles transferred.
    //  * @param _data Data to pass to the receiver.
    //  */
    // function safeInflationaryTransferFrom(
    //     address _from,
    //     address _to,
    //     uint256 _id,
    //     uint256 _inflationaryValue,
    //     bytes memory _data
    // ) public {
    //     address sender = _msgSender();
    //     if (_from != sender && !isApprovedForAll(_from, sender)) {
    //         revert ERC1155MissingApprovalForAll(sender, _from);
    //     }
    //     // convert inflationary value to todays demurrage value
    //     uint256 value = convertInflationaryToDemurrageValue(_inflationaryValue, day(block.timestamp));
    //     _safeTransferFrom(_from, _to, _id, value, _data);
    // }

    // /**
    //  * @notice safeInflationaryBatchTransferFrom transfers Circles from one address to another by specifying inflationary units.
    //  * @param _from Address from which the Circles are transferred.
    //  * @param _to Address to which the Circles are transferred.
    //  * @param _ids Batch of Circles identifiers for which the Circles are transferred.
    //  * @param _inflationaryValues Batch of inflationary values of the Circles transferred.
    //  * @param _data Data to pass to the receiver.
    //  */
    // function safeInflationaryBatchTransferFrom(
    //     address _from,
    //     address _to,
    //     uint256[] memory _ids,
    //     uint256[] memory _inflationaryValues,
    //     bytes memory _data
    // ) public {
    //     address sender = _msgSender();
    //     if (_from != sender && !isApprovedForAll(_from, sender)) {
    //         revert ERC1155MissingApprovalForAll(sender, _from);
    //     }
    //     uint64 today = day(block.timestamp);
    //     uint256[] memory values = convertBatchInflationaryToDemurrageValues(_inflationaryValues, today);
    //     _safeBatchTransferFrom(_from, _to, _ids, values, _data);
    // }

    // Internal functions

    /**
     * @dev Calculate the inflationary balance of a discounted balance
     * @param _account Address of the account to calculate the balance of
     * @param _id Circles identifier for which to calculate the balance
     */
    function _inflationaryBalanceOf(address _account, uint256 _id) internal view returns (uint256) {
        // retrieve the balance in demurrage units (of today)
        uint256 balance = hub.balanceOf(_account, _id);
        return _calculateInflationaryBalance(balance, day(block.timestamp));
    }
}
