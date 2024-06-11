# MasterCopyNonUpgradable
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/proxy/MasterCopyNonUpgradable.sol)


## State Variables
### reservedStorageSlotForProxy
*This storage variable *MUST* be the first storage element
for this contract.
A contract acting as a master copy for a proxy contract
inherits from this contract. In inherited contracts list, this
contract *MUST* be the first one. This would assure that
the storage variable is always the first storage element for
the inherited contract.
The proxy is applied to save gas during deployment, and importantly
the proxy is not upgradable.*


```solidity
address internal reservedStorageSlotForProxy;
```


