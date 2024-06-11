# StandardVault
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/treasury/StandardVault.sol)

**Inherits:**
[MasterCopyNonUpgradable](/src/proxy/MasterCopyNonUpgradable.sol/contract.MasterCopyNonUpgradable.md), ERC1155Holder, [IStandardVault](/src/treasury/IStandardVault.sol/interface.IStandardVault.md), [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### standardTreasury
Address of the standard treasury


```solidity
address public standardTreasury;
```


### hub
Address of the hub contract


```solidity
IHubV2 public hub;
```


## Functions
### onlyTreasury

Ensure the caller is the standard treasury


```solidity
modifier onlyTreasury();
```

### constructor

Constructor to create a standard vault master copy.


```solidity
constructor();
```

### setup

Setup the vault


```solidity
function setup(IHubV2 _hub) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_hub`|`IHubV2`|Address of the hub contract|


### returnCollateral

Return the collateral to the receiver can only be called by the treasury


```solidity
function returnCollateral(address _receiver, uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
    external
    onlyTreasury;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_receiver`|`address`|Receivere address of the collateral|
|`_ids`|`uint256[]`|Circles identifiers of the collateral|
|`_values`|`uint256[]`|Values of the collateral to be returned|
|`_data`|`bytes`|Optional data bytes passed to the receiver|


### burnCollateral

Burn collateral from the vault can only ve called by the treasury


```solidity
function burnCollateral(uint256[] calldata _ids, uint256[] calldata _values, bytes calldata _data)
    external
    onlyTreasury;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_ids`|`uint256[]`|Circles identifiers of the collateral|
|`_values`|`uint256[]`|Values of the collateral to be burnt|
|`_data`|`bytes`|Optional data bytes passed to the hub and policy for burning|


