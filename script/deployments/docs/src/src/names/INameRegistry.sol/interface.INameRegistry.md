# INameRegistry
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/names/INameRegistry.sol)


## Functions
### setMetadataDigest


```solidity
function setMetadataDigest(address avatar, bytes32 metadataDigest) external;
```

### registerCustomName


```solidity
function registerCustomName(address avatar, string calldata name) external;
```

### registerCustomSymbol


```solidity
function registerCustomSymbol(address avatar, string calldata symbol) external;
```

### name


```solidity
function name(address avatar) external view returns (string memory);
```

### symbol


```solidity
function symbol(address avatar) external view returns (string memory);
```

### getMetadataDigest


```solidity
function getMetadataDigest(address _avatar) external view returns (bytes32);
```

### isValidName


```solidity
function isValidName(string calldata name) external pure returns (bool);
```

### isValidSymbol


```solidity
function isValidSymbol(string calldata symbol) external pure returns (bool);
```

