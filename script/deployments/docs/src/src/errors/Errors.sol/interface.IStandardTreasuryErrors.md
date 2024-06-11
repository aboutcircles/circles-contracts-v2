# IStandardTreasuryErrors
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/errors/Errors.sol)


## Errors
### CirclesStandardTreasuryGroupHasNoVault

```solidity
error CirclesStandardTreasuryGroupHasNoVault(address group);
```

### CirclesStandardTreasuryRedemptionCollateralMismatch

```solidity
error CirclesStandardTreasuryRedemptionCollateralMismatch(
    uint256 circlesId, uint256[] redemptionIds, uint256[] redemptionValues, uint256[] burnIds, uint256[] burnValues
);
```

### CirclesStandardTreasuryInvalidMetadataType

```solidity
error CirclesStandardTreasuryInvalidMetadataType(bytes32 metadataType, uint8 code);
```

### CirclesStandardTreasuryInvalidMetadata

```solidity
error CirclesStandardTreasuryInvalidMetadata(bytes metadata, uint8 code);
```

