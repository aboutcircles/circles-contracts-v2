# ICirclesErrors
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/errors/Errors.sol)


## Errors
### CirclesAvatarMustBeRegistered

```solidity
error CirclesAvatarMustBeRegistered(address avatar, uint8 code);
```

### CirclesAddressCannotBeZero

```solidity
error CirclesAddressCannotBeZero(uint8 code);
```

### CirclesInvalidFunctionCaller

```solidity
error CirclesInvalidFunctionCaller(address caller, address expectedCaller, uint8 code);
```

### CirclesInvalidCirclesId

```solidity
error CirclesInvalidCirclesId(uint256 id, uint8 code);
```

### CirclesInvalidString

```solidity
error CirclesInvalidString(string str, uint8 code);
```

### CirclesInvalidParameter

```solidity
error CirclesInvalidParameter(uint256 parameter, uint8 code);
```

### CirclesAmountOverflow

```solidity
error CirclesAmountOverflow(uint256 amount, uint8 code);
```

### CirclesArraysLengthMismatch

```solidity
error CirclesArraysLengthMismatch(uint256 lengthArray1, uint256 lengthArray2, uint8 code);
```

### CirclesArrayMustNotBeEmpty

```solidity
error CirclesArrayMustNotBeEmpty(uint8 code);
```

### CirclesAmountMustNotBeZero

```solidity
error CirclesAmountMustNotBeZero(uint8 code);
```

### CirclesProxyAlreadyInitialized

```solidity
error CirclesProxyAlreadyInitialized();
```

### CirclesLogicAssertion

```solidity
error CirclesLogicAssertion(uint8 code);
```

### CirclesIdMustBeDerivedFromAddress

```solidity
error CirclesIdMustBeDerivedFromAddress(uint256 providedId, uint8 code);
```

### CirclesReentrancyGuard

```solidity
error CirclesReentrancyGuard(uint8 code);
```

