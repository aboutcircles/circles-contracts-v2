# Hub
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/hub/Hub.sol)

**Inherits:**
[Circles](/src/circles/Circles.sol/contract.Circles.md), [TypeDefinitions](/src/hub/TypeDefinitions.sol/contract.TypeDefinitions.md), [IHubErrors](/src/errors/Errors.sol/interface.IHubErrors.md)

The Hub contract is the main contract for the Circles protocol.
It adopts the ERC1155 standard for multi-token contracts and governs
the personal and group Circles of people, organizations and groups.
Circle balances are demurraged in the Hub contract.
It registers the trust relations between people and groups and allows
to transfer Circles to be path fungible along trust relations.
It further allows to wrap any token into an inflationary or demurraged
ERC20 Circles contract.


## State Variables
### WELCOME_BONUS
*Welcome bonus for new avatars invited to Circles. Set to 50 Circles.*


```solidity
uint256 private constant WELCOME_BONUS = 50 * EXA;
```


### INVITATION_COST
*The cost of an invitation for a new avatar, paid in personal Circles burnt, set to 100 Circles.*


```solidity
uint256 private constant INVITATION_COST = 2 * WELCOME_BONUS;
```


### SENTINEL
*The address used as the first element of the linked list of avatars.*


```solidity
address private constant SENTINEL = address(0x1);
```


### ADVANCED_FLAG_OPTOUT_CONSENTEDFLOW

```solidity
bytes32 private constant ADVANCED_FLAG_OPTOUT_CONSENTEDFLOW = bytes32(uint256(1));
```


### hubV1
The Hub v1 contract address.


```solidity
IHubV1 internal immutable hubV1;
```


### nameRegistry
The name registry contract address.


```solidity
INameRegistry internal nameRegistry;
```


### migration
The address of the migration contract for v1 Circles.


```solidity
address internal migration;
```


### liftERC20
The address of the Lift ERC20 contract.


```solidity
IERC20Lift internal liftERC20;
```


### invitationOnlyTime
The timestamp of the start of the invitation-only period.

*This is used to determine the start of the invitation-only period.
Prior to this time v1 avatars can register without an invitation, and
new avatars can be invited by registered avatars. After this time
only registered avatars can invite new avatars.*


```solidity
uint256 internal immutable invitationOnlyTime;
```


### standardTreasury
The standard treasury contract address used when
registering a (non-custom) group.


```solidity
address internal standardTreasury;
```


### avatars
The mapping of registered avatar addresses to the next avatar address,
stored as a linked list.

*This is used to store the linked list of registered avatars.*


```solidity
mapping(address => address) public avatars;
```


### mintPolicies
The mapping of group avatar addresses to the mint policy contract address.


```solidity
mapping(address => address) public mintPolicies;
```


### treasuries
The mapping of group avatar addresses to the treasury contract address.


```solidity
mapping(address => address) public treasuries;
```


### advancedUsageFlags
By default the advanced usage flags should remain set to zero.
Only for advanced purposes people can consider enabling flags.


```solidity
mapping(address => bytes32) public advancedUsageFlags;
```


### trustMarkers
The iterable mapping of directional trust relations between avatars and
their expiry times.


```solidity
mapping(address => mapping(address => TrustMarker)) public trustMarkers;
```


## Functions
### onlyDuringBootstrap

Modifier to check if the current time is during the bootstrap period.


```solidity
modifier onlyDuringBootstrap(uint8 _code);
```

### onlyMigration

Modifier to check if the caller is the migration contract.


```solidity
modifier onlyMigration();
```

### nonReentrant

*Reentrancy guard for nonReentrant functions.
see https://soliditylang.org/blog/2024/01/26/transient-storage/*


```solidity
modifier nonReentrant(uint8 _code);
```

### constructor

Constructor for the Hub contract.


```solidity
constructor(
    IHubV1 _hubV1,
    INameRegistry _nameRegistry,
    address _migration,
    IERC20Lift _liftERC20,
    address _standardTreasury,
    uint256 _inflationDayZero,
    uint256 _bootstrapTime,
    string memory _gatewayUrl
) Circles(_inflationDayZero, _gatewayUrl);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_hubV1`|`IHubV1`|address of the Hub v1 contract|
|`_nameRegistry`|`INameRegistry`||
|`_migration`|`address`||
|`_liftERC20`|`IERC20Lift`||
|`_standardTreasury`|`address`|address of the standard treasury contract|
|`_inflationDayZero`|`uint256`|timestamp of the start of the global inflation curve. For deployment on Gnosis Chain this parameter should be set to midnight 15 October 2020, or in unix time 1602786330 (deployment at 6:25:30 pm UTC) - 66330 (offset to midnight) = 1602720000.|
|`_bootstrapTime`|`uint256`|duration of the bootstrap period (for v1 registration) in seconds|
|`_gatewayUrl`|`string`|gateway URL string for the ERC1155 metadata mirroring IPFS metadata storage (eg. "https://gateway.aboutcircles.com/v2/circles/{id}.json")|


### registerHuman

Register human allows to register an avatar for a human,
if they have a stopped v1 Circles contract, during the bootstrap period.


```solidity
function registerHuman(bytes32 _metatdataDigest) external onlyDuringBootstrap(0);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_metatdataDigest`|`bytes32`|(optional) sha256 metadata digest for the avatar metadata should follow ERC1155 metadata standard.|


### inviteHuman

Invite human allows to register another human avatar.
The inviter must burn twice the welcome bonus of their own Circles,
and the invited human receives the welcome bonus in their personal Circles.
The inviter is set to trust the invited avatar.


```solidity
function inviteHuman(address _human) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|avatar of the human to invite|


### registerGroup

Register group allows to register a group avatar.


```solidity
function registerGroup(address _mint, string calldata _name, string calldata _symbol, bytes32 _metatdataDigest)
    external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mint`|`address`|mint address will be called before minting group circles|
|`_name`|`string`|immutable name of the group Circles|
|`_symbol`|`string`|immutable symbol of the group Circles|
|`_metatdataDigest`|`bytes32`|sha256 digest for the group metadata|


### registerCustomGroup

Register custom group allows to register a group with a custom treasury contract.


```solidity
function registerCustomGroup(
    address _mint,
    address _treasury,
    string calldata _name,
    string calldata _symbol,
    bytes32 _metatdataDigest
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_mint`|`address`|mint address will be called before minting group circles|
|`_treasury`|`address`|treasury address for receiving collateral|
|`_name`|`string`|immutable name of the group Circles|
|`_symbol`|`string`|immutable symbol of the group Circles|
|`_metatdataDigest`|`bytes32`|metadata digest for the group metadata|


### registerOrganization

Register organization allows to register an organization avatar.


```solidity
function registerOrganization(string calldata _name, bytes32 _metatdataDigest) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_name`|`string`|name of the organization|
|`_metatdataDigest`|`bytes32`|Metadata digest for the organization metadata|


### trust

Trust allows to trust another address for a certain period of time.
Expiry times in the past are set to the current block timestamp.

*Trust is directional and can be set by the caller to any address.
The trusted address does not (yet) have to be registered in the Hub contract.*


```solidity
function trust(address _trustReceiver, uint96 _expiry) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_trustReceiver`|`address`|address that is trusted by the caller|
|`_expiry`|`uint96`|expiry time in seconds since unix epoch until when trust is valid|


### personalMint

Personal mint allows to mint personal Circles for a registered human avatar.


```solidity
function personalMint() external;
```

### calculateIssuanceWithCheck

Calculate issuance allows to calculate the issuance for a human avatar with a check
to update the v1 mint status if updated.


```solidity
function calculateIssuanceWithCheck(address _human) external returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|address of the human avatar to calculate the issuance for|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|issuance amount of Circles that can be minted|
|`<none>`|`uint256`|startPeriod start of the claimable period|
|`<none>`|`uint256`|endPeriod end of the claimable period|


### groupMint

Group mint allows to mint group Circles by providing the required collateral.


```solidity
function groupMint(
    address _group,
    address[] calldata _collateralAvatars,
    uint256[] calldata _amounts,
    bytes calldata _data
) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`address`|address of the group avatar to mint Circles of|
|`_collateralAvatars`|`address[]`|array of (personal or group) avatar addresses to be used as collateral|
|`_amounts`|`uint256[]`|array of amounts of collateral to be used for minting|
|`_data`|`bytes`|(optional) additional data to be passed to the mint policy, treasury and minter|


### stop

Stop allows to stop future mints of personal Circles for this avatar.
Must be called by the avatar itself. This action is irreversible.


```solidity
function stop() external;
```

### stopped

Stopped checks whether the avatar has stopped future mints of personal Circles.


```solidity
function stopped(address _human) external view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|address of avatar of the human to check whether it is stopped|


### migrate

Migrate allows to migrate v1 Circles to v2 Circles. During bootstrap period,
no invitation cost needs to be paid for new humans to be registered. After the bootstrap
period the same invitation cost applies as for normal invitations, and this requires the
owner to be a human and to have enough personal Circles to pay the invitation cost.
Organizations and groups have to ensure all humans have been registered after the bootstrap period.
Can only be called by the migration contract.


```solidity
function migrate(address _owner, address[] calldata _avatars, uint256[] calldata _amounts) external onlyMigration;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_owner`|`address`|address of the owner of the v1 Circles and beneficiary of the v2 Circles|
|`_avatars`|`address[]`|array of avatar addresses to migrate|
|`_amounts`|`uint256[]`|array of amounts in inflationary v1 units to migrate|


### burn

Burn allows to burn Circles owned by the caller.


```solidity
function burn(uint256 _id, uint256 _amount, bytes calldata _data) external;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_id`|`uint256`|Circles identifier of the Circles to burn|
|`_amount`|`uint256`|amount of Circles to burn|
|`_data`|`bytes`|(optional) additional data to be passed to the burn policy if they are group Circles|


### wrap


```solidity
function wrap(address _avatar, uint256 _amount, CirclesType _type) external returns (address);
```

### operateFlowMatrix


```solidity
function operateFlowMatrix(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    Stream[] calldata _streams,
    bytes calldata _packedCoordinates
) external nonReentrant(0);
```

### setAdvancedUsageFlag


```solidity
function setAdvancedUsageFlag(bytes32 _flag) external;
```

### isHuman

Checks if an avatar is registered as a human.


```solidity
function isHuman(address _human) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|address of the human to check|


### isGroup

Checks if an avatar is registered as a group.


```solidity
function isGroup(address _group) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_group`|`address`|address of the group to check|


### isOrganization

Checks if an avatar is registered as an organization.


```solidity
function isOrganization(address _organization) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_organization`|`address`|address of the organization to check|


### isTrusted

Returns true if the truster trusts the trustee.


```solidity
function isTrusted(address _truster, address _trustee) public view returns (bool);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_truster`|`address`|Address of the trusting account|
|`_trustee`|`address`|Address of the trusted account|


### isPermittedFlow


```solidity
function isPermittedFlow(address _to, address _circlesAvatar) public view returns (bool);
```

### _groupMint

Group mint allows to mint group Circles by providing the required collateral.


```solidity
function _groupMint(
    address _sender,
    address _group,
    uint256[] memory _collateral,
    uint256[] memory _amounts,
    bytes memory _data
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_sender`|`address`|address of the sender of the group mint, and receiver of minted group Circles|
|`_group`|`address`|address of the group avatar to mint Circles of|
|`_collateral`|`uint256[]`|array of (personal or group) avatar addresses to be used as collateral|
|`_amounts`|`uint256[]`|array of amounts of collateral to be used for minting|
|`_data`|`bytes`|(optional) additional data to be passed to the mint policy, treasury and minter|


### _verifyFlowMatrix


```solidity
function _verifyFlowMatrix(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    uint16[] memory _coordinates,
    bool _closedPath
) internal view returns (int256[] memory);
```

### _effectPathTransfers


```solidity
function _effectPathTransfers(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    Stream[] calldata _streams,
    uint16[] memory _coordinates
) internal;
```

### _callAcceptanceChecks


```solidity
function _callAcceptanceChecks(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    Stream[] calldata _streams,
    uint16[] memory _coordinates
) internal returns (int256[] memory);
```

### _matchNettedFlows


```solidity
function _matchNettedFlows(int256[] memory _streamsNettedFlow, int256[] memory _matrixNettedFlow) internal pure;
```

### _registerHuman

Register human allows to register an avatar for a human,
and returns the status of the associated v1 Circles contract.
Additionally set the trust to self indefinitely.


```solidity
function _registerHuman(address _human) internal returns (address v1CirclesStatus);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|address of the human to be registered|


### _registerGroup

Register a group avatar.


```solidity
function _registerGroup(
    address _avatar,
    address _mint,
    address _treasury,
    string calldata _name,
    string calldata _symbol
) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|address of the group registering|
|`_mint`|`address`|address of the mint policy for the group|
|`_treasury`|`address`|address of the treasury for the group|
|`_name`|`string`|name of the group Circles|
|`_symbol`|`string`|symbol of the group Circles|


### _trust


```solidity
function _trust(address _truster, address _trustee, uint96 _expiry) internal;
```

### _ensureAvatarsRegistered


```solidity
function _ensureAvatarsRegistered(address[] calldata _avatars) internal returns (uint256);
```

### _checkHumanV1CirclesStatus

Check the status of an avatar's Circles in the Hub v1 contract,
and update the mint status of the avatar.


```solidity
function _checkHumanV1CirclesStatus(address _human) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|Address of the human avatar to check the v1 mint status of.|


### _avatarV1CirclesStatus

Checks the status of an avatar's Circles in the Hub v1 contract,
and returns the address of the Circles if it exists and is not stopped.
Else, it returns the zero address if no Circles exist,
and it returns the address CIRCLES_STOPPED_V1 (0x1) if the Circles contract is stopped.


```solidity
function _avatarV1CirclesStatus(address _avatar) internal view returns (address);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|avatar address for which to check registration in Hub v1|


### _updateMintV1Status

Update the mint status of an avatar given the status of the v1 Circles contract.


```solidity
function _updateMintV1Status(address _human, address _mintV1Status) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|Address of the human avatar to check the v1 mint status of.|
|`_mintV1Status`|`address`|Mint status of the v1 Circles contract.|


### _insertAvatar

Insert an avatar into the linked list of avatars.
Reverts on inserting duplicates.


```solidity
function _insertAvatar(address _avatar) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|avatar address to insert|


### _validateAddressFromId


```solidity
function _validateAddressFromId(uint256 _id, uint8 _code) internal pure returns (address);
```

### _unpackCoordinates

*abi.encodePacked of an array uint16[] would still pad each uint16 - I think;
if abi packing does not add padding this function is redundant and should be thrown out
Unpacks the packed coordinates from bytes.
Each coordinate is 16 bits, and each triplet is thus 48 bits.*


```solidity
function _unpackCoordinates(bytes calldata _packedData, uint256 _numberOfTriplets)
    internal
    pure
    returns (uint16[] memory unpackedCoordinates_);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_packedData`|`bytes`|The packed data containing the coordinates.|
|`_numberOfTriplets`|`uint256`|The number of coordinate triplets in the packed data.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`unpackedCoordinates_`|`uint16[]`|An array of unpacked coordinates (of length 3* numberOfTriplets)|


### _upsertTrustMarker

*Internal function to upsert a trust marker for a truster and a trusted address.
It will initialize the linked list for the truster if it does not exist yet.
If the trustee is not yet trusted by the truster, it will insert the trust marker.
It will update the expiry time for the trusted address.*


```solidity
function _upsertTrustMarker(address _truster, address _trusted, uint96 _expiry) private;
```

## Events
### RegisterHuman

```solidity
event RegisterHuman(address indexed avatar);
```

### InviteHuman

```solidity
event InviteHuman(address indexed inviter, address indexed invited);
```

### RegisterOrganization

```solidity
event RegisterOrganization(address indexed organization, string name);
```

### RegisterGroup

```solidity
event RegisterGroup(address indexed group, address indexed mint, address indexed treasury, string name, string symbol);
```

### Trust

```solidity
event Trust(address indexed truster, address indexed trustee, uint256 expiryTime);
```

### Stopped

```solidity
event Stopped(address indexed avatar);
```

