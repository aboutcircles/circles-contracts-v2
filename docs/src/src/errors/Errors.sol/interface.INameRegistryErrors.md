# INameRegistryErrors
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/errors/Errors.sol)


## Errors
### CirclesNamesInvalidName

```solidity
error CirclesNamesInvalidName(address avatar, string name, uint8 code);
```

### CirclesNamesShortNameAlreadyAssigned

```solidity
error CirclesNamesShortNameAlreadyAssigned(address avatar, uint72 shortName, uint8 code);
```

### CirclesNamesShortNameWithNonceTaken

```solidity
error CirclesNamesShortNameWithNonceTaken(address avatar, uint256 nonce, uint72 shortName, address takenByAvatar);
```

### CirclesNamesAvatarAlreadyHasCustomNameOrSymbol

```solidity
error CirclesNamesAvatarAlreadyHasCustomNameOrSymbol(address avatar, string nameOrSymbol, uint8 code);
```

### CirclesNamesOrganizationHasNoSymbol

```solidity
error CirclesNamesOrganizationHasNoSymbol(address organization, uint8 code);
```

