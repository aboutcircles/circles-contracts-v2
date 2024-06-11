# ICirclesDemurrageErrors
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/errors/Errors.sol)


## Errors
### CirclesERC1155MintBlocked

```solidity
error CirclesERC1155MintBlocked(address human, address mintV1Status);
```

### CirclesDemurrageAmountExceedsMaxUint190

```solidity
error CirclesDemurrageAmountExceedsMaxUint190(address account, uint256 circlesId, uint256 amount, uint8 code);
```

### CirclesDemurrageDayBeforeLastUpdatedDay

```solidity
error CirclesDemurrageDayBeforeLastUpdatedDay(
    address account, uint256 circlesId, uint64 day, uint64 lastUpdatedDay, uint8 code
);
```

### CirclesERC1155CannotReceiveBatch

```solidity
error CirclesERC1155CannotReceiveBatch(uint8 code);
```

