# ProxyFactory
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/proxy/ProxyFactory.sol)

**Author:**
Stefan George - <stefan@gnosis.pm>


## Functions
### _createProxy

*Allows to create new proxy contact and
execute a message call to the new proxy within one transaction.*


```solidity
function _createProxy(address masterCopy, bytes memory data) internal returns (Proxy proxy);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`masterCopy`|`address`|Address of master copy.|
|`data`|`bytes`|Payload for message call sent to new proxy contract.|


## Events
### ProxyCreation

```solidity
event ProxyCreation(Proxy proxy, address masterCopy);
```

