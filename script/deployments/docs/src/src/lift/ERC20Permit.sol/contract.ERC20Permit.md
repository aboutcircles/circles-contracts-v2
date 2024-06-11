# ERC20Permit
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/ERC20Permit.sol)

**Inherits:**
[EIP712](/src/lift/EIP712.sol/abstract.EIP712.md), Nonces, IERC20Permit, IERC20Errors, [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### PERMIT_TYPEHASH

```solidity
bytes32 private constant PERMIT_TYPEHASH =
    keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
```


### permitName

```solidity
string private constant permitName = "Circles";
```


### permitVersion

```solidity
string private constant permitVersion = "v2";
```


### _allowances

```solidity
mapping(address => mapping(address => uint256)) internal _allowances;
```


## Functions
### constructor


```solidity
constructor();
```

### _setupPermit


```solidity
function _setupPermit() internal;
```

### permit


```solidity
function permit(address _owner, address _spender, uint256 _value, uint256 _deadline, uint8 _v, bytes32 _r, bytes32 _s)
    external;
```

### nonces


```solidity
function nonces(address _owner) public view override(IERC20Permit, Nonces) returns (uint256);
```

### DOMAIN_SEPARATOR


```solidity
function DOMAIN_SEPARATOR() public view override returns (bytes32);
```

### _approve


```solidity
function _approve(address _owner, address _spender, uint256 _amount) internal;
```

### _spendAllowance


```solidity
function _spendAllowance(address _owner, address _spender, uint256 _amount) internal;
```

## Errors
### ERC2612ExpiredSignature
*Permit deadline has expired.*


```solidity
error ERC2612ExpiredSignature(uint256 deadline);
```

### ERC2612InvalidSigner
*Mismatched signature.*


```solidity
error ERC2612InvalidSigner(address signer, address owner);
```

