# ERC20DiscountedBalances
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/ERC20DiscountedBalances.sol)

**Inherits:**
[ERC20Permit](/src/lift/ERC20Permit.sol/contract.ERC20Permit.md), [Demurrage](/src/circles/Demurrage.sol/contract.Demurrage.md), IERC20


## State Variables
### avatar

```solidity
address public avatar;
```


### discountedBalances
*The mapping of addresses to the discounted balances.*


```solidity
mapping(address => DiscountedBalance) public discountedBalances;
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
function totalSupply() external view virtual returns (uint256);
```

### balanceOfOnDay


```solidity
function balanceOfOnDay(address _account, uint64 _day)
    public
    view
    returns (uint256 balanceOnDay_, uint256 discountCost_);
```

### _inflationaryBalanceOf


```solidity
function _inflationaryBalanceOf(address _account) internal view returns (uint256);
```

### _updateBalance


```solidity
function _updateBalance(address _account, uint256 _balance, uint64 _day) internal;
```

### _discountAndAddToBalance


```solidity
function _discountAndAddToBalance(address _account, uint256 _value, uint64 _day) internal;
```

### _transfer


```solidity
function _transfer(address _from, address _to, uint256 _amount) internal;
```

### _mint


```solidity
function _mint(address _owner, uint256 _amount) internal;
```

### _burn


```solidity
function _burn(address _owner, uint256 _amount) internal;
```

