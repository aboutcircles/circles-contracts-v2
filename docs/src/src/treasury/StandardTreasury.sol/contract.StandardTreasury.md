# StandardTreasury
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/treasury/StandardTreasury.sol)

**Inherits:**
ERC165, [ProxyFactory](/src/proxy/ProxyFactory.sol/contract.ProxyFactory.md), [TypeDefinitions](/src/hub/TypeDefinitions.sol/contract.TypeDefinitions.md), IERC1155Receiver, [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md), [IStandardTreasuryErrors](/src/errors/Errors.sol/interface.IStandardTreasuryErrors.md)


## State Variables
### STANDARD_VAULT_SETUP_CALLPREFIX
*The call prefix for the setup function on the vault contract*


```solidity
bytes4 public constant STANDARD_VAULT_SETUP_CALLPREFIX = bytes4(keccak256("setup(address)"));
```


### hub
Address of the hub contract


```solidity
IHubV2 public hub;
```


### mastercopyStandardVault
Address of the mastercopy standard vault contract


```solidity
address public immutable mastercopyStandardVault;
```


### vaults
Mapping of group address to vault address

*The vault is the contract that holds the group's collateral
todo: we could use deterministic vault addresses as to not store them
but then we still need to check whether the correct code has been deployed
so we might as well deploy and store the addresses?*


```solidity
mapping(address => IStandardVault) public vaults;
```


## Functions
### onlyHub

Ensure the caller is the hub


```solidity
modifier onlyHub();
```

### constructor

Constructor to create a standard treasury


```solidity
constructor(IHubV2 _hub, address _mastercopyStandardVault);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_hub`|`IHubV2`|Address of the hub contract|
|`_mastercopyStandardVault`|`address`|Address of the mastercopy standard vault contract|


### supportsInterface

*See [IERC165-supportsInterface](/lib/forge-std/src/interfaces/IERC165.sol/interface.IERC165.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool);
```

### onERC1155Received

*Exclusively use single received for receiving group Circles to redeem them
for collateral Circles according to the group mint policy*


```solidity
function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
    public
    override
    onlyHub
    returns (bytes4);
```

### onERC1155BatchReceived

*Exclusively use batch received for receiving collateral Circles
from the hub contract during group minting*


```solidity
function onERC1155BatchReceived(address, address, uint256[] memory _ids, uint256[] memory _values, bytes calldata _data)
    public
    override
    onlyHub
    returns (bytes4);
```

### _mintBatchGroupCircles


```solidity
function _mintBatchGroupCircles(uint256[] memory _ids, uint256[] memory _values, address _group, bytes memory _userData)
    internal
    returns (bytes4);
```

### _mintGroupCircles


```solidity
function _mintGroupCircles(uint256 _id, uint256 _value, address _group, bytes memory _userData)
    internal
    returns (bytes4);
```

### _redeemGroupCircles


```solidity
function _redeemGroupCircles(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
    internal
    returns (bytes4);
```

### _decodeMetadataForGroup

*Decode the metadata for the group mint and revert if the type does not match group mint*


```solidity
function _decodeMetadataForGroup(bytes memory _data) internal pure returns (bytes32, address, bytes memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_data`|`bytes`|Metadata for the group mint|


### _validateCirclesIdToGroup

*Validate the Circles id to group address*


```solidity
function _validateCirclesIdToGroup(uint256 _id) internal pure returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Circles identifier|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`address`|group Address of the group|


### _ensureVault

*Ensure the vault exists for the group, and if not deploy it*


```solidity
function _ensureVault(address _group) internal returns (IStandardVault);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`address`|Address of the group|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IStandardVault`|vault Address of the vault|


### _deployVault

*Deploy the vault*


```solidity
function _deployVault() internal returns (IStandardVault);
```
**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`IStandardVault`|vault Address of the vault|


