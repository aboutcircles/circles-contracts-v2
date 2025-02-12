// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {DiscountedBalances} from "src/circles/DiscountedBalances.sol";

interface IDiscountedBalances {
    event DiscountCost(address indexed account, uint256 indexed id, uint256 discountCost);
}

contract MockDiscountedBalances is DiscountedBalances {
    // Constructor

    constructor(uint256 _inflationDayZero) DiscountedBalances(_inflationDayZero) {}

    // External functions

    function maxBalance() external pure returns (uint256) {
        return MAX_VALUE;
    }

    function getAvatarBalanceValue(uint256 id, address avatar) external view returns (uint192) {
        return discountedBalances[id][avatar].balance;
    }

    function getAvatarLastUpdatedDayValue(uint256 id, address avatar) external view returns (uint64) {
        return discountedBalances[id][avatar].lastUpdatedDay;
    }

    function getTotalSupplyBalanceValue(uint256 id) external view returns (uint192) {
        return discountedTotalSupplies[id].balance;
    }

    function getTotalSupplyLastUpdatedDayValue(uint256 id) external view returns (uint64) {
        return discountedTotalSupplies[id].lastUpdatedDay;
    }

    function updateBalance(address avatar, uint256 id, uint256 newBalance, uint64 newDay) external {
        _updateBalance(avatar, id, newBalance, newDay);
    }

    function discountAndAddToBalance(address avatar, uint256 id, uint256 addedValue, uint64 newDay) external {
        _discountAndAddToBalance(avatar, id, addedValue, newDay);
    }

    function updateTotalSupply(uint256 id, uint192 _balance, uint64 _day) external {
        discountedTotalSupplies[id] = DiscountedBalance({balance: _balance, lastUpdatedDay: _day});
    }
}
