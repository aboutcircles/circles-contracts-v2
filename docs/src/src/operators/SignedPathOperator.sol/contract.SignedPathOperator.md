# SignedPathOperator
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/operators/SignedPathOperator.sol)

**Inherits:**
[BaseOperator](/src/operators/BaseOperator.sol/contract.BaseOperator.md), [TypeDefinitions](/src/hub/TypeDefinitions.sol/contract.TypeDefinitions.md)


## Functions
### constructor


```solidity
constructor(IHubV2 _hub) BaseOperator(_hub);
```

### operateSignedFlowMatrix


```solidity
function operateSignedFlowMatrix(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    Stream[] calldata _streams,
    bytes calldata _packedCoordinates,
    uint256 _sourceCoordinate
) external;
```

## Errors
### CirclesOperatorInvalidStreamSource

```solidity
error CirclesOperatorInvalidStreamSource(
    uint256 streamIndex, uint256 singleSourceCoordinate, uint256 streamSourceCoordinate
);
```

