# IHubV1
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/migration/IHub.sol)

**Author:**
Circles

legacy interface of Hub contract in Circles v1


## Functions
### signup


```solidity
function signup() external;
```

### signupBonus


```solidity
function signupBonus() external view returns (uint256);
```

### organizationSignup


```solidity
function organizationSignup() external;
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### name


```solidity
function name() external view returns (string memory);
```

### tokenToUser


```solidity
function tokenToUser(address token) external view returns (address);
```

### userToToken


```solidity
function userToToken(address user) external view returns (address);
```

### limits


```solidity
function limits(address truster, address trustee) external returns (uint256);
```

### trust


```solidity
function trust(address trustee, uint256 limit) external;
```

### deployedAt


```solidity
function deployedAt() external view returns (uint256);
```

### initialIssuance


```solidity
function initialIssuance() external view returns (uint256);
```

### issuance


```solidity
function issuance() external view returns (uint256);
```

### issuanceByStep


```solidity
function issuanceByStep(uint256 periods) external view returns (uint256);
```

### inflate


```solidity
function inflate(uint256 initial, uint256 periods) external view returns (uint256);
```

### inflation


```solidity
function inflation() external view returns (uint256);
```

### divisor


```solidity
function divisor() external view returns (uint256);
```

### period


```solidity
function period() external view returns (uint256);
```

### periods


```solidity
function periods() external view returns (uint256);
```

### timeout


```solidity
function timeout() external view returns (uint256);
```

