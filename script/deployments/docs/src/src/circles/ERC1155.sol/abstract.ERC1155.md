# ERC1155
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/circles/ERC1155.sol)

**Inherits:**
[DiscountedBalances](/src/circles/DiscountedBalances.sol/contract.DiscountedBalances.md), Context, ERC165, IERC1155, IERC1155MetadataURI, IERC1155Errors

*Implementation of the basic standard multi-token for demurraged and inflationary balances.
See https://eips.ethereum.org/EIPS/eip-1155
This code is modified from the open-zeppelin implementation v5.0.0:
https://github.com/OpenZeppelin/openzeppelin-contracts/
Originally based on code by Enjin: https://github.com/enjin/erc-1155*


## State Variables
### _operatorApprovals

```solidity
mapping(address account => mapping(address operator => bool)) private _operatorApprovals;
```


### _uri

```solidity
string private _uri;
```


## Functions
### constructor

*See [_setURI](/src/circles/ERC1155.sol/abstract.ERC1155.md#_seturi).*


```solidity
constructor(string memory _newuri);
```

### supportsInterface

*See [IERC165-supportsInterface](/src/treasury/StandardTreasury.sol/contract.StandardTreasury.md#supportsinterface).*


```solidity
function supportsInterface(bytes4 _interfaceId) public view virtual override(ERC165, IERC165) returns (bool);
```

### uri

*See [IERC1155MetadataURI-uri](/lib/openzeppelin-contracts/contracts/token/ERC1155/ERC1155.sol/abstract.ERC1155.md#uri).
This implementation returns the same URI for *all* token types. It relies
on the token type ID substitution mechanism
https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
Clients calling this function must replace the `\{id\}` substring with the
actual token type ID.*


```solidity
function uri(uint256) public view virtual returns (string memory);
```

### balanceOf

*See [IERC1155-balanceOf](/src/lift/ERC20DiscountedBalances.sol/contract.ERC20DiscountedBalances.md#balanceof).*


```solidity
function balanceOf(address _account, uint256 _id) public view returns (uint256);
```

### balanceOfBatch

*See [IERC1155-balanceOfBatch](/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#balanceofbatch).
Requirements:
- `accounts` and `ids` must have the same length.*


```solidity
function balanceOfBatch(address[] memory _accounts, uint256[] memory _ids) public view returns (uint256[] memory);
```

### setApprovalForAll

*See [IERC1155-setApprovalForAll](/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#setapprovalforall).*


```solidity
function setApprovalForAll(address _operator, bool _approved) public;
```

### isApprovedForAll

*See [IERC1155-isApprovedForAll](/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#isapprovedforall).*


```solidity
function isApprovedForAll(address _account, address _operator) public view returns (bool);
```

### safeTransferFrom

*See [IERC1155-safeTransferFrom](/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#safetransferfrom).*


```solidity
function safeTransferFrom(address _from, address _to, uint256 _id, uint256 _value, bytes memory _data) public;
```

### safeBatchTransferFrom

*See [IERC1155-safeBatchTransferFrom](/lib/forge-std/src/interfaces/IERC1155.sol/interface.IERC1155.md#safebatchtransferfrom).*


```solidity
function safeBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _values,
    bytes memory _data
) public virtual;
```

### _update

*Transfers a `value` amount of tokens of type `id` from `from` to `to`. Will mint (or burn) if `from`
(or `to`) is the zero address.
Emits a {TransferSingle} event if the arrays contain one element, and {TransferBatch} otherwise.
Requirements:
- If `to` refers to a smart contract, it must implement either {IERC1155Receiver-onERC1155Received}
or {IERC1155Receiver-onERC1155BatchReceived} and return the acceptance magic value.
- `ids` and `values` must have the same length.
NOTE: The ERC-1155 acceptance check is not performed in this function. See {_updateWithAcceptanceCheck} instead.*


```solidity
function _update(address from, address to, uint256[] memory ids, uint256[] memory values) internal virtual;
```

### _updateWithAcceptanceCheck

*Version of [_update](/src/circles/ERC1155.sol/abstract.ERC1155.md#_update) that performs the token acceptance check by calling
{IERC1155Receiver-onERC1155Received} or {IERC1155Receiver-onERC1155BatchReceived} on the receiver address if it
contains code (eg. is a smart contract at the moment of execution).
IMPORTANT: Overriding this function is discouraged because it poses a reentrancy risk from the receiver. So any
update to the contract state after this function would break the check-effect-interaction pattern. Consider
overriding {_update} instead.*


```solidity
function _updateWithAcceptanceCheck(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) internal virtual;
```

### _acceptanceCheck

*do the ERC1155 token acceptance check to the receiver*


```solidity
function _acceptanceCheck(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _values,
    bytes memory _data
) internal;
```

### _safeTransferFrom

*Transfers a `value` tokens of token type `id` from `from` to `to`.
Emits a {TransferSingle} event.
Requirements:
- `to` cannot be the zero address.
- `from` must have a balance of tokens of type `id` of at least `value` amount.
- If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
acceptance magic value.*


```solidity
function _safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) internal;
```

### _safeBatchTransferFrom

*xref:ROOT:erc1155.adoc#batch-operations[Batched] version of [_safeTransferFrom](/src/circles/ERC1155.sol/abstract.ERC1155.md#_safetransferfrom).
Emits a {TransferBatch} event.
Requirements:
- If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
acceptance magic value.
- `ids` and `values` must have the same length.*


```solidity
function _safeBatchTransferFrom(
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) internal;
```

### _setURI

*Sets a new URI for all token types, by relying on the token type ID
substitution mechanism
https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
By this mechanism, any occurrence of the `\{id\}` substring in either the
URI or any of the values in the JSON file at said URI will be replaced by
clients with the token type ID.
For example, the `https://token-cdn-domain/\{id\}.json` URI would be
interpreted by clients as
`https://token-cdn-domain/000000000000000000000000000000000000000000000000000000000004cce0.json`
for token type ID 0x4cce0.
See [uri](/src/circles/ERC1155.sol/abstract.ERC1155.md#uri).
Because these URIs cannot be meaningfully represented by the {URI} event,
this function emits no events.*


```solidity
function _setURI(string memory _newuri) internal virtual;
```

### _mint

*Creates a `value` amount of tokens of type `id`, and assigns them to `to`.
Emits a {TransferSingle} event.
Requirements:
- `to` cannot be the zero address.
- If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155Received} and return the
acceptance magic value.*


```solidity
function _mint(address to, uint256 id, uint256 value, bytes memory data) internal;
```

### _burn

*xref:ROOT:erc1155.adoc#batch-operations[Batched] version of [_mint](/src/circles/ERC1155.sol/abstract.ERC1155.md#_mint).
Emits a {TransferBatch} event.
Requirements:
- `ids` and `values` must have the same length.
- `to` cannot be the zero address.
- If `to` refers to a smart contract, it must implement {IERC1155Receiver-onERC1155BatchReceived} and return the
acceptance magic value.*

*Destroys a `value` amount of tokens of type `id` from `from`
Emits a {TransferSingle} event.
Requirements:
- `from` cannot be the zero address.
- `from` must have at least `value` amount of tokens of type `id`.*


```solidity
function _burn(address from, uint256 id, uint256 value) internal;
```

### _setApprovalForAll

*xref:ROOT:erc1155.adoc#batch-operations[Batched] version of [_burn](/src/circles/ERC1155.sol/abstract.ERC1155.md#_burn).
Emits a {TransferBatch} event.
Requirements:
- `from` cannot be the zero address.
- `from` must have at least `value` amount of tokens of type `id`.
- `ids` and `values` must have the same length.
//*

*Approve `operator` to operate on all of `owner` tokens
Emits an {ApprovalForAll} event.
Requirements:
- `operator` cannot be the zero address.*


```solidity
function _setApprovalForAll(address owner, address operator, bool approved) internal virtual;
```

### _asSingletonArrays

*Creates an array in memory with only one value for each of the elements provided.*


```solidity
function _asSingletonArrays(uint256 element1, uint256 element2)
    internal
    pure
    returns (uint256[] memory array1, uint256[] memory array2);
```

### _doSafeTransferAcceptanceCheck

*Performs an acceptance check by calling [IERC1155-onERC1155Received](/src/treasury/StandardTreasury.sol/contract.StandardTreasury.md#onerc1155received) on the `to` address
if it contains code at the moment of execution.*


```solidity
function _doSafeTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256 id,
    uint256 value,
    bytes memory data
) private;
```

### _doSafeBatchTransferAcceptanceCheck

*Performs a batch acceptance check by calling [IERC1155-onERC1155BatchReceived](/src/treasury/StandardTreasury.sol/contract.StandardTreasury.md#onerc1155batchreceived) on the `to` address
if it contains code at the moment of execution.*


```solidity
function _doSafeBatchTransferAcceptanceCheck(
    address operator,
    address from,
    address to,
    uint256[] memory ids,
    uint256[] memory values,
    bytes memory data
) private;
```

