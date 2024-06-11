# IHubErrors
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/errors/Errors.sol)


## Errors
### CirclesHubOnlyDuringBootstrap

```solidity
error CirclesHubOnlyDuringBootstrap(uint8 code);
```

### CirclesHubRegisterAvatarV1MustBeStopped

```solidity
error CirclesHubRegisterAvatarV1MustBeStopped(address avatar, uint8 code);
```

### CirclesHubAvatarAlreadyRegistered

```solidity
error CirclesHubAvatarAlreadyRegistered(address avatar, uint8 code);
```

### CirclesHubMustBeHuman

```solidity
error CirclesHubMustBeHuman(address avatar, uint8 code);
```

### CirclesHubGroupIsNotRegistered

```solidity
error CirclesHubGroupIsNotRegistered(address group, uint8 code);
```

### CirclesHubInvalidTrustReceiver

```solidity
error CirclesHubInvalidTrustReceiver(address trustReceiver, uint8 code);
```

### CirclesHubGroupMintPolicyRejectedMint

```solidity
error CirclesHubGroupMintPolicyRejectedMint(
    address minter, address group, uint256[] collateral, uint256[] amounts, bytes data, uint8 code
);
```

### CirclesHubGroupMintPolicyRejectedBurn

```solidity
error CirclesHubGroupMintPolicyRejectedBurn(address burner, address group, uint256 amount, bytes data, uint8 code);
```

### CirclesHubOperatorNotApprovedForSource

```solidity
error CirclesHubOperatorNotApprovedForSource(address operator, address source, uint16 streamId, uint8 code);
```

### CirclesHubFlowEdgeIsNotPermitted

```solidity
error CirclesHubFlowEdgeIsNotPermitted(address receiver, uint256 circlesId, uint8 code);
```

### CirclesHubOnClosedPathOnlyPersonalCirclesCanReturnToAvatar

```solidity
error CirclesHubOnClosedPathOnlyPersonalCirclesCanReturnToAvatar(address failedReceiver, uint256 circlesId);
```

### CirclesHubFlowVerticesMustBeSorted

```solidity
error CirclesHubFlowVerticesMustBeSorted();
```

### CirclesHubFlowEdgeStreamMismatch

```solidity
error CirclesHubFlowEdgeStreamMismatch(uint16 flowEdgeId, uint16 streamId, uint8 code);
```

### CirclesHubStreamMismatch

```solidity
error CirclesHubStreamMismatch(uint16 streamId, uint8 code);
```

### CirclesHubNettedFlowMismatch

```solidity
error CirclesHubNettedFlowMismatch(uint16 vertexPosition, int256 matrixNettedFlow, int256 streamNettedFlow);
```

