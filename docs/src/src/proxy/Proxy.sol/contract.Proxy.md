# Proxy
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/proxy/Proxy.sol)

**Authors:**
Stefan George - <stefan@gnosis.io>, Richard Meissner - <richard@gnosis.io>


## State Variables
### masterCopy

```solidity
address public masterCopy;
```


## Functions
### constructor

*Constructor function sets address of master copy contract.*


```solidity
constructor(address _masterCopy);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_masterCopy`|`address`|Master copy address.|


### fallback


```solidity
fallback() external payable;
```

### receive


```solidity
receive() external payable;
```

### _fallback

*Fallback function forwards all transactions and
returns all received return data.*


```solidity
function _fallback() internal;
```

