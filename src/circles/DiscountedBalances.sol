// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../lib/Math64x64.sol";
import "./Demurrage.sol";

contract DiscountedBalances is Demurrage {
    // State variables

    /**
     * @dev stores the discounted balances of the accounts privately.
     * Mapping from Circles identifiers to accounts to the discounted balance.
     */
    mapping(uint256 => mapping(address => DiscountedBalance)) internal discountedBalances;

    /**
     * @dev stores the total supply for each Circles identifier
     */
    mapping(uint256 => DiscountedBalance) internal discountedTotalSupplies;

    // Constructor

    /**
     * @dev Constructor to set the start of the global inflationary curve.
     * @param _inflation_day_zero Timestamp of midgnight day zero for the global inflationary curve.
     */
    constructor(uint256 _inflation_day_zero) {
        inflationDayZero = _inflation_day_zero;
    }

    // Public functions

    /**
     * @notice Balance of a Circles identifier for a given account on a (future) day.
     * @param _account Address of the account to calculate the balance of
     * @param _id Circles identifier for which to calculate the balance
     * @param _day Day since inflation_day_zero to calculate the balance for
     * @return balanceOnDay_ The discounted balance of the account for the Circles identifier on specified day
     * @return discountCost_ The discount cost of the demurrage of the balance since the last update
     */
    function balanceOfOnDay(address _account, uint256 _id, uint64 _day)
        public
        view
        returns (uint256 balanceOnDay_, uint256 discountCost_)
    {
        DiscountedBalance memory discountedBalance = discountedBalances[_id][_account];
        if (_day < discountedBalance.lastUpdatedDay) {
            // DiscountedBalances: day is before last updated day
            revert CirclesDemurrageDayBeforeLastUpdatedDay(_account, _id, _day, discountedBalance.lastUpdatedDay, 0);
        }
        uint256 dayDifference;
        unchecked {
            dayDifference = _day - discountedBalance.lastUpdatedDay;
        }
        // Calculate the discounted balance
        balanceOnDay_ = _calculateDiscountedBalance(discountedBalance.balance, dayDifference);
        // Calculate the discount cost; this can be unchecked as cost is strict positive
        unchecked {
            discountCost_ = discountedBalance.balance - balanceOnDay_;
        }
        return (balanceOnDay_, discountCost_);
    }

    /**
     * @notice Total supply of a Circles identifier.
     * @param _id Circles identifier for which to calculate the total supply
     */
    function totalSupply(uint256 _id) public view returns (uint256) {
        DiscountedBalance memory totalSupplyBalance = discountedTotalSupplies[_id];
        uint64 today = day(block.timestamp);
        return _calculateDiscountedBalance(totalSupplyBalance.balance, today - totalSupplyBalance.lastUpdatedDay);
    }

    // Internal functions

    /**
     * @dev Calculate the inflationary balance of a discounted balance
     * @param _account Address of the account to calculate the balance of
     * @param _id Circles identifier for which to calculate the balance
     */
    function _inflationaryBalanceOf(address _account, uint256 _id) internal view returns (uint256) {
        DiscountedBalance memory discountedBalance = discountedBalances[_id][_account];
        return _calculateInflationaryBalance(discountedBalance.balance, discountedBalance.lastUpdatedDay);
    }

    /**
     * @dev Update the balance of an account for a given Circles identifier
     * @param _account Address of the account to update the balance of
     * @param _id Circles identifier for which to update the balance
     * @param _balance New balance to set
     * @param _day Day since inflation_day_zero to set as last updated day
     */
    function _updateBalance(address _account, uint256 _id, uint256 _balance, uint64 _day) internal {
        if (_balance > MAX_VALUE) {
            // DiscountedBalances: balance exceeds maximum value
            revert CirclesDemurrageAmountExceedsMaxUint190(_account, _id, _balance, 0);
        }
        DiscountedBalance storage discountedBalance = discountedBalances[_id][_account];
        discountedBalance.balance = uint192(_balance);
        discountedBalance.lastUpdatedDay = _day;
    }

    /**
     * @dev Discount to the given day and add to the balance of an account for a given Circles identifier
     * @param _account Address of the account to update the balance of
     * @param _id Circles identifier for which to update the balance
     * @param _value Value to add to the discounted balance
     * @param _day Day since inflation_day_zero to discount the balance to
     */
    function _discountAndAddToBalance(address _account, uint256 _id, uint256 _value, uint64 _day) internal {
        DiscountedBalance storage discountedBalance = discountedBalances[_id][_account];
        if (_day < discountedBalance.lastUpdatedDay) {
            // DiscountedBalances: day is before last updated day
            revert CirclesDemurrageDayBeforeLastUpdatedDay(_account, _id, _day, discountedBalance.lastUpdatedDay, 1);
        }
        uint256 dayDifference;
        unchecked {
            dayDifference = _day - discountedBalance.lastUpdatedDay;
        }
        uint256 discountedBalanceOnDay = _calculateDiscountedBalance(discountedBalance.balance, dayDifference);
        // Calculate the discount cost; this can be unchecked as cost is strict positive
        unchecked {
            uint256 discountCost = discountedBalance.balance - discountedBalanceOnDay;
            if (discountCost > 0) {
                // emit DiscountCost(_account, _id, discountCost);
                emit IERC1155.TransferSingle(msg.sender, _account, address(0), _id, discountCost);
            }
        }
        uint256 updatedBalance = discountedBalanceOnDay + _value;
        if (updatedBalance > MAX_VALUE) {
            // DiscountedBalances: balance exceeds maximum value
            revert CirclesDemurrageAmountExceedsMaxUint190(_account, _id, updatedBalance, 1);
        }
        discountedBalance.balance = uint192(updatedBalance);
        discountedBalance.lastUpdatedDay = _day;
    }
}
