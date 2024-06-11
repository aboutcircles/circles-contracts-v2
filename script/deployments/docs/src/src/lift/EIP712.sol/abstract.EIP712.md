# EIP712
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lift/EIP712.sol)

**Inherits:**
IERC5267

*https://eips.ethereum.org/EIPS/eip-712[EIP 712] is a standard for hashing and signing of typed structured data.
The encoding scheme specified in the EIP requires a domain separator and a hash of the typed structured data, whose
encoding is very generic and therefore its implementation in Solidity is not feasible, thus this contract
does not implement the encoding itself. Protocols need to implement the type-specific encoding they need in order to
produce the hash of their typed data using a combination of `abi.encode` and `keccak256`.
This contract implements the EIP 712 domain separator ([_domainSeparatorV4](/src/lift/EIP712.sol/abstract.EIP712.md#_domainseparatorv4)) that is used as part of the encoding
scheme, and the final step of the encoding to obtain the message digest that is then signed via ECDSA
({_hashTypedDataV4}).
The implementation of the domain separator was designed to be as efficient as possible while still properly updating
the chain id to protect against replay attacks on an eventual fork of the chain.
NOTE: This contract implements the version of the encoding known as "v4", as implemented by the JSON RPC method
https://docs.metamask.io/guide/signing-data.html[`eth_signTypedDataV4` in MetaMask].
NOTE: In the upgradeable version of this contract, the cached values will correspond to the address, and the domain
separator of the implementation contract. This will cause the {_domainSeparatorV4} function to always rebuild the
separator from the immutable values, which is cheaper than accessing a cached version in cold storage.*


## State Variables
### TYPE_HASH

```solidity
bytes32 private constant TYPE_HASH =
    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)");
```


### _cachedDomainSeparator

```solidity
bytes32 private _cachedDomainSeparator;
```


### _cachedChainId

```solidity
uint256 private _cachedChainId;
```


### _cachedThis

```solidity
address private _cachedThis;
```


### _hashedName

```solidity
bytes32 private _hashedName;
```


### _hashedVersion

```solidity
bytes32 private _hashedVersion;
```


### _name

```solidity
ShortString private _name;
```


### _version

```solidity
ShortString private _version;
```


### _nameFallback

```solidity
string private _nameFallback;
```


### _versionFallback

```solidity
string private _versionFallback;
```


## Functions
### constructor


```solidity
constructor();
```

### _setupEIP712

*Initializes the domain separator and parameter caches.
The meaning of `name` and `version` is specified in
https://eips.ethereum.org/EIPS/eip-712#definition-of-domainseparator[EIP 712]:
- `name`: the user readable name of the signing domain, i.e. the name of the DApp or the protocol.
- `version`: the current major version of the signing domain.
NOTE: These parameters cannot be changed except through a xref:learn::upgrading-smart-contracts.adoc[smart
contract upgrade].*


```solidity
function _setupEIP712(string memory name, string memory version) internal;
```

### eip712Domain

*See {IERC-5267}.*


```solidity
function eip712Domain()
    public
    view
    virtual
    returns (
        bytes1 fields,
        string memory name,
        string memory version,
        uint256 chainId,
        address verifyingContract,
        bytes32 salt,
        uint256[] memory extensions
    );
```

### _domainSeparatorV4

*Returns the domain separator for the current chain.*


```solidity
function _domainSeparatorV4() internal view returns (bytes32);
```

### _hashTypedDataV4

*Given an already https://eips.ethereum.org/EIPS/eip-712#definition-of-hashstruct[hashed struct], this
function returns the hash of the fully encoded EIP712 message for this domain.
This hash can be used together with [ECDSA-recover](/lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol/library.ECDSA.md#recover) to obtain the signer of a message. For example:
```solidity
bytes32 digest = _hashTypedDataV4(keccak256(abi.encode(
keccak256("Mail(address to,string contents)"),
mailTo,
keccak256(bytes(mailContents))
)));
address signer = ECDSA.recover(digest, signature);
```*


```solidity
function _hashTypedDataV4(bytes32 structHash) internal view virtual returns (bytes32);
```

### _EIP712Name

*The name parameter for the EIP712 domain.
NOTE: By default this function reads _name which is an immutable value.
It only reads from storage if necessary (in case the value is too large to fit in a ShortString).*


```solidity
function _EIP712Name() internal view returns (string memory);
```

### _EIP712Version

*The version parameter for the EIP712 domain.
NOTE: By default this function reads _version which is an immutable value.
It only reads from storage if necessary (in case the value is too large to fit in a ShortString).*


```solidity
function _EIP712Version() internal view returns (string memory);
```

### _buildDomainSeparator


```solidity
function _buildDomainSeparator() private view returns (bytes32);
```

