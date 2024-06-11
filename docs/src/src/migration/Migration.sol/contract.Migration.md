# Migration
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/migration/Migration.sol)

**Inherits:**
[ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### ACCURACY

```solidity
uint256 private constant ACCURACY = uint256(10 ** 8);
```


### hubV1
*The address of the v1 hub contract.*


```solidity
IHubV1 public immutable hubV1;
```


### hubV2

```solidity
IHubV2 public hubV2;
```


### inflationDayZero

```solidity
uint256 public immutable inflationDayZero;
```


### period
*Inflationary period of Hub v1 contract*


```solidity
uint256 public immutable period;
```


## Functions
### constructor


```solidity
constructor(IHubV1 _hubV1, IHubV2 _hubV2, uint256 _inflationDayZero);
```

### migrate

Migrates the given amounts of v1 Circles to v2 Circles.


```solidity
function migrate(address[] calldata _avatars, uint256[] calldata _amounts) external returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatars`|`address[]`|The avatars to migrate.|
|`_amounts`|`uint256[]`|The amounts in inflationary v1 units to migrate.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256[]`|convertedAmounts The converted amounts of v2 Circles.|


### convertFromV1ToDemurrage

Converts an amount of v1 Circles to demurrage Circles.


```solidity
function convertFromV1ToDemurrage(uint256 _amount) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_amount`|`uint256`|The amount of v1 Circles to convert.|


