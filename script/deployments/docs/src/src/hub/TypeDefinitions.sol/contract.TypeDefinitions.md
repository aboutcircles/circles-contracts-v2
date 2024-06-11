# TypeDefinitions
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/hub/TypeDefinitions.sol)


## State Variables
### METADATATYPE_GROUPMINT

```solidity
bytes32 internal constant METADATATYPE_GROUPMINT = keccak256("CIRCLESv2:RESERVED_DATA:CirclesGroupMint");
```


### METADATATYPE_GROUPREDEEM

```solidity
bytes32 internal constant METADATATYPE_GROUPREDEEM = keccak256("CIRCLESv2:RESERVED_DATA:CirclesGroupRedeem");
```


## Structs
### TrustMarker
TrustMarker stores the expiry of a trust relation as uint96,
and is iterable as a linked list of trust markers.

*This is used to store the directional trust relation between two avatars,
and the expiry of the trust relation as uint96 in unix time.*


```solidity
struct TrustMarker {
    address previous;
    uint96 expiry;
}
```

### FlowEdge

```solidity
struct FlowEdge {
    uint16 streamSinkId;
    uint192 amount;
}
```

### Stream

```solidity
struct Stream {
    uint16 sourceCoordinate;
    uint16[] flowEdgeIds;
    bytes data;
}
```

### Metadata

```solidity
struct Metadata {
    bytes32 metadataType;
    bytes metadata;
    bytes erc1155UserData;
}
```

### GroupMintMetadata

```solidity
struct GroupMintMetadata {
    address group;
}
```

