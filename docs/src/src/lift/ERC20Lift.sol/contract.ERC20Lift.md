# ERC20Lift
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/ERC20Lift.sol)

**Inherits:**
[ProxyFactory](/src/proxy/ProxyFactory.sol/contract.ProxyFactory.md), [IERC20Lift](/src/lift/IERC20Lift.sol/interface.IERC20Lift.md), [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### ERC20_WRAPPER_SETUP_CALLPREFIX

```solidity
bytes4 public constant ERC20_WRAPPER_SETUP_CALLPREFIX = bytes4(keccak256("setup(address,address,address)"));
```


### hub

```solidity
IHubV2 public hub;
```


### nameRegistry

```solidity
INameRegistry public nameRegistry;
```


### masterCopyERC20Wrapper
*The master copy of the ERC20 demurrage and inflation Circles contract.*


```solidity
address[2] public masterCopyERC20Wrapper;
```


### erc20Circles

```solidity
mapping(CirclesType => mapping(address => address)) public erc20Circles;
```


## Functions
### constructor


```solidity
constructor(
    IHubV2 _hub,
    INameRegistry _nameRegistry,
    address _masterCopyERC20Demurrage,
    address _masterCopyERC20Inflation
);
```

### ensureERC20


```solidity
function ensureERC20(address _avatar, CirclesType _circlesType) public returns (address);
```

### _deployERC20


```solidity
function _deployERC20(address _masterCopy, address _avatar) internal returns (address);
```

## Events
### ERC20WrapperDeployed

```solidity
event ERC20WrapperDeployed(address indexed avatar, address indexed erc20Wrapper, CirclesType circlesType);
```

