# Base58Converter
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/names/Base58Converter.sol)


## State Variables
### ALPHABET

```solidity
string internal constant ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";
```


### FIXED_SHORT_NAME_LENGTH

```solidity
uint256 internal constant FIXED_SHORT_NAME_LENGTH = 12;
```


### ALPHABET_LENGTH

```solidity
uint256 internal constant ALPHABET_LENGTH = 58;
```


## Functions
### _toBase58


```solidity
function _toBase58(uint256 _data) internal pure returns (string memory);
```

### _toBase58WithPadding


```solidity
function _toBase58WithPadding(uint256 _data) internal pure returns (string memory);
```

### _reverse


```solidity
function _reverse(bytes memory _b, uint256 _len) internal pure returns (bytes memory);
```

