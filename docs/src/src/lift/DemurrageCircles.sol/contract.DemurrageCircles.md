# DemurrageCircles
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/DemurrageCircles.sol)

**Inherits:**
[MasterCopyNonUpgradable](/src/proxy/MasterCopyNonUpgradable.sol/contract.MasterCopyNonUpgradable.md), [ERC20DiscountedBalances](/src/lift/ERC20DiscountedBalances.sol/contract.ERC20DiscountedBalances.md), ERC1155Holder


## State Variables
### hub

```solidity
IHubV2 public hub;
```


### nameRegistry

```solidity
INameRegistry public nameRegistry;
```


## Functions
### onlyHub


```solidity
modifier onlyHub(uint8 _code);
```

### constructor


```solidity
constructor();
```

### setup


```solidity
function setup(address _hub, address _nameRegistry, address _avatar) external;
```

### unwrap


```solidity
function unwrap(uint256 _amount) external;
```

### totalSupply


```solidity
function totalSupply() external view override returns (uint256);
```

### name


```solidity
function name() external view returns (string memory);
```

### symbol


```solidity
function symbol() external view returns (string memory);
```

### decimals


```solidity
function decimals() external pure returns (uint8);
```

### onERC1155Received


```solidity
function onERC1155Received(address, address _from, uint256 _id, uint256 _amount, bytes memory)
    public
    override
    onlyHub(0)
    returns (bytes4);
```

### onERC1155BatchReceived


```solidity
function onERC1155BatchReceived(address, address, uint256[] memory, uint256[] memory, bytes memory)
    public
    view
    override
    onlyHub(1)
    returns (bytes4);
```

### circlesIdentifier


```solidity
function circlesIdentifier() public view returns (uint256);
```

## Events
### DepositDemurraged

```solidity
event DepositDemurraged(address indexed account, uint256 amount, uint256 inflationaryAmount);
```

### WithdrawDemurraged

```solidity
event WithdrawDemurraged(address indexed account, uint256 amount, uint256 inflationaryAmount);
```

