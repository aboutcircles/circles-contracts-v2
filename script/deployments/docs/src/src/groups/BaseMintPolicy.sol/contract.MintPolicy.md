# MintPolicy
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/groups/BaseMintPolicy.sol)

**Inherits:**
[IMintPolicy](/src/groups/IMintPolicy.sol/interface.IMintPolicy.md)


## Functions
### beforeMintPolicy

Simple mint policy that always returns true


```solidity
function beforeMintPolicy(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
    external
    virtual
    override
    returns (bool);
```

### beforeBurnPolicy

Simple burn policy that always returns true


```solidity
function beforeBurnPolicy(address, address, uint256, bytes calldata) external virtual override returns (bool);
```

### beforeRedeemPolicy

Simple redeem policy that returns the redemption ids and values as requested in the data


```solidity
function beforeRedeemPolicy(address, address, address, uint256, bytes calldata _data)
    external
    virtual
    override
    returns (uint256[] memory _ids, uint256[] memory _values, uint256[] memory _burnIds, uint256[] memory _burnValues);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`||
|`<none>`|`address`||
|`<none>`|`address`||
|`<none>`|`uint256`||
|`_data`|`bytes`|Optional data bytes passed to redeem policy|


