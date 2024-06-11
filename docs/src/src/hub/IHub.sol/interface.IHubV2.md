# IHubV2
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/hub/IHub.sol)

**Inherits:**
IERC1155, [ICircles](/src/circles/ICircles.sol/interface.ICircles.md)


## Functions
### avatars


```solidity
function avatars(address avatar) external view returns (address);
```

### isHuman


```solidity
function isHuman(address avatar) external view returns (bool);
```

### isGroup


```solidity
function isGroup(address avatar) external view returns (bool);
```

### isOrganization


```solidity
function isOrganization(address avatar) external view returns (bool);
```

### migrate


```solidity
function migrate(address owner, address[] calldata avatars, uint256[] calldata amounts) external;
```

### mintPolicies


```solidity
function mintPolicies(address avatar) external view returns (address);
```

### burn


```solidity
function burn(uint256 id, uint256 amount, bytes calldata data) external;
```

### operateFlowMatrix


```solidity
function operateFlowMatrix(
    address[] calldata _flowVertices,
    TypeDefinitions.FlowEdge[] calldata _flow,
    TypeDefinitions.Stream[] calldata _streams,
    bytes calldata _packedCoordinates
) external;
```

