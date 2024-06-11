# DiscountedBalances
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/circles/DiscountedBalances.sol)

**Inherits:**
[Demurrage](/src/circles/Demurrage.sol/contract.Demurrage.md)


## State Variables
### discountedBalances
*stores the discounted balances of the accounts privately.
Mapping from Circles identifiers to accounts to the discounted balance.*


```solidity
mapping(uint256 => mapping(address => DiscountedBalance)) internal discountedBalances;
```


### discountedTotalSupplies
*stores the total supply for each Circles identifier*


```solidity
mapping(uint256 => DiscountedBalance) internal discountedTotalSupplies;
```


## Functions
### constructor

*Constructor to set the start of the global inflationary curve.*


```solidity
constructor(uint256 _inflation_day_zero);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_inflation_day_zero`|`uint256`|Timestamp of midgnight day zero for the global inflationary curve.|


### balanceOfOnDay

Balance of a Circles identifier for a given account on a (future) day.


```solidity
function balanceOfOnDay(address _account, uint256 _id, uint64 _day)
    public
    view
    returns (uint256 balanceOnDay_, uint256 discountCost_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address of the account to calculate the balance of|
|`_id`|`uint256`|Circles identifier for which to calculate the balance|
|`_day`|`uint64`|Day since inflation_day_zero to calculate the balance for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`balanceOnDay_`|`uint256`|The discounted balance of the account for the Circles identifier on specified day|
|`discountCost_`|`uint256`|The discount cost of the demurrage of the balance since the last update|


### totalSupply

Total supply of a Circles identifier.


```solidity
function totalSupply(uint256 _id) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Circles identifier for which to calculate the total supply|


### _inflationaryBalanceOf

*Calculate the inflationary balance of a discounted balance*


```solidity
function _inflationaryBalanceOf(address _account, uint256 _id) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address of the account to calculate the balance of|
|`_id`|`uint256`|Circles identifier for which to calculate the balance|


### _updateBalance

*Update the balance of an account for a given Circles identifier*


```solidity
function _updateBalance(address _account, uint256 _id, uint256 _balance, uint64 _day) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address of the account to update the balance of|
|`_id`|`uint256`|Circles identifier for which to update the balance|
|`_balance`|`uint256`|New balance to set|
|`_day`|`uint64`|Day since inflation_day_zero to set as last updated day|


### _discountAndAddToBalance

*Discount to the given day and add to the balance of an account for a given Circles identifier*


```solidity
function _discountAndAddToBalance(address _account, uint256 _id, uint256 _value, uint64 _day) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address of the account to update the balance of|
|`_id`|`uint256`|Circles identifier for which to update the balance|
|`_value`|`uint256`|Value to add to the discounted balance|
|`_day`|`uint64`|Day since inflation_day_zero to discount the balance to|


