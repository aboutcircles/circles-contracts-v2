# NameRegistry
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/names/NameRegistry.sol)

**Inherits:**
[Base58Converter](/src/names/Base58Converter.sol/contract.Base58Converter.md), [INameRegistry](/src/names/INameRegistry.sol/interface.INameRegistry.md), [INameRegistryErrors](/src/errors/Errors.sol/interface.INameRegistryErrors.md), [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### MAX_SHORT_NAME
The last ("biggest") short name that can be assigned is "zzzzzzzzzzzz",
which is 1449225352009601191935 in decimal when converted from base58


```solidity
uint72 public constant MAX_SHORT_NAME = uint72(1449225352009601191935);
```


### DEFAULT_CIRCLES_NAME_PREFIX
The default name prefix for Circles

*to test pre-release codes, we use a toy name prefix
so that we can easily identify the test Circles*


```solidity
string public constant DEFAULT_CIRCLES_NAME_PREFIX = "Rings-";
```


### DEFAULT_CIRCLES_SYMBOL
The default symbol for Circles


```solidity
string public constant DEFAULT_CIRCLES_SYMBOL = "RING";
```


### hub
The address of the hub contract where the address must have registered first


```solidity
IHubV2 public hub;
```


### shortNames
a mapping from the avatar address to the assigned name

*9 bytes or uint72 fit 12 characters in base58 encoding*


```solidity
mapping(address => uint72) public shortNames;
```


### shortNameToAvatar
a mapping from the short name to the address


```solidity
mapping(uint72 => address) public shortNameToAvatar;
```


### customNames

```solidity
mapping(address => string) public customNames;
```


### customSymbols

```solidity
mapping(address => string) public customSymbols;
```


### avatarToMetaDataDigest
avatarToMetaDataDigest is a mapping of avatar to the sha256 digest
of their latest ERC1155 metadata.


```solidity
mapping(address => bytes32) public avatarToMetaDataDigest;
```


## Functions
### mustBeRegistered


```solidity
modifier mustBeRegistered(address _avatar, uint8 _code);
```

### onlyHub


```solidity
modifier onlyHub(uint8 _code);
```

### constructor


```solidity
constructor(IHubV2 _hub);
```

### registerShortName

Register a short name for the avatar


```solidity
function registerShortName() external mustBeRegistered(msg.sender, 0);
```

### registerShortNameWithNonce

Registers a short name for the avatar using a specific nonce if the short name is available


```solidity
function registerShortNameWithNonce(uint256 _nonce) external mustBeRegistered(msg.sender, 1);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_nonce`|`uint256`|nonce to be used in the calculation|


### setMetadataDigest


```solidity
function setMetadataDigest(address _avatar, bytes32 _metadataDigest) external onlyHub(0);
```

### updateMetadataDigest


```solidity
function updateMetadataDigest(bytes32 _metadataDigest) external mustBeRegistered(msg.sender, 2);
```

### registerCustomName


```solidity
function registerCustomName(address _avatar, string calldata _name) external onlyHub(1);
```

### registerCustomSymbol


```solidity
function registerCustomSymbol(address _avatar, string calldata _symbol) external onlyHub(2);
```

### name


```solidity
function name(address _avatar) external view mustBeRegistered(_avatar, 3) returns (string memory);
```

### symbol


```solidity
function symbol(address _avatar) external view mustBeRegistered(_avatar, 4) returns (string memory);
```

### getMetadataDigest


```solidity
function getMetadataDigest(address _avatar) external view returns (bytes32);
```

### searchShortName

Search for the first available short name for the avatar and return the short name and nonce


```solidity
function searchShortName(address _avatar) public view returns (uint72 shortName_, uint256 nonce_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|address for which the name is to be calculated|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`shortName_`|`uint72`|short name that can be assigned to the avatar|
|`nonce_`|`uint256`|nonce for which this name can be assigned|


### calculateShortNameWithNonce

Calculates a short name for the avatar using a nonce


```solidity
function calculateShortNameWithNonce(address _avatar, uint256 _nonce) public pure returns (uint72 shortName_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|address for which the short name is to be calculated|
|`_nonce`|`uint256`|nonce to be used in the calculation|


### isValidName

*checks whether string is a valid name by checking
the length as max 32 bytes and the allowed characters: 0-9, A-Z, a-z, space,
hyphen, underscore, period, parentheses, apostrophe,
ampersand, plus and hash.
This restricts the contract name to a subset of ASCII characters,
and excludes unicode characters for other alphabets and emoticons.
Instead the default ERC1155 metadata read from the IPFS CID registry,
should provide the full display name with unicode characters.
Names are not checked for uniqueness.*


```solidity
function isValidName(string calldata _name) public pure returns (bool);
```

### isValidSymbol

*checks whether string is a valid symbol by checking
the length as max 16 bytes and the allowed characters: 0-9, A-Z, a-z,
hyphen, underscore.*


```solidity
function isValidSymbol(string calldata _symbol) public pure returns (bool);
```

### _registerShortName


```solidity
function _registerShortName() internal;
```

### _registerShortNameWithNonce


```solidity
function _registerShortNameWithNonce(uint256 _nonce) internal;
```

### _storeShortName


```solidity
function _storeShortName(address _avatar, uint72 _shortName, uint256 _nonce) internal;
```

### _getShortOrLongName


```solidity
function _getShortOrLongName(address _avatar) internal view returns (string memory);
```

### _setMetadataDigest


```solidity
function _setMetadataDigest(address _avatar, bytes32 _metadataDigest) internal;
```

## Events
### RegisterShortName

```solidity
event RegisterShortName(address indexed avatar, uint72 shortName, uint256 nonce);
```

### UpdateMetadataDigest

```solidity
event UpdateMetadataDigest(address indexed avatar, bytes32 metadataDigest);
```

