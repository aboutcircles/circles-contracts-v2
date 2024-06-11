# ERC20InflationaryBalances
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/ERC20InflationaryBalances.sol)

**Inherits:**
[ERC20Permit](/src/lift/ERC20Permit.sol/contract.ERC20Permit.md), [Demurrage](/src/circles/Demurrage.sol/contract.Demurrage.md), IERC20


## State Variables
### EXTENDED_ACCURACY_BITS

```solidity
uint8 internal constant EXTENDED_ACCURACY_BITS = 64;
```


### _extendedTotalSupply

```solidity
uint256 internal _extendedTotalSupply;
```


### _extendedAccuracyBalances

```solidity
mapping(address => uint256) private _extendedAccuracyBalances;
```


## Functions
### transfer


```solidity
function transfer(address _to, uint256 _amount) external returns (bool);
```

### transferFrom


```solidity
function transferFrom(address _from, address _to, uint256 _amount) external returns (bool);
```

### approve


```solidity
function approve(address _spender, uint256 _amount) external returns (bool);
```

### increaseAllowance


```solidity
function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool);
```

### decreaseAllowance


```solidity
function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool);
```

### balanceOf


```solidity
function balanceOf(address _account) external view returns (uint256);
```

### allowance


```solidity
function allowance(address _owner, address _spender) external view returns (uint256);
```

### totalSupply


```solidity
function totalSupply() external view returns (uint256);
```

### _convertToExtended


```solidity
function _convertToExtended(uint256 _amount) internal pure returns (uint256);
```

### _transfer


```solidity
function _transfer(address _from, address _to, uint256 _amount) internal;
```

### _mintFromDemurragedAmount


```solidity
function _mintFromDemurragedAmount(address _owner, uint256 _demurragedAmount) internal returns (uint256);
```

### _burn


```solidity
function _burn(address _owner, uint256 _amount) internal returns (uint256);
```

