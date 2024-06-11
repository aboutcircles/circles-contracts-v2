# Circles
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/circles/Circles.sol)

**Inherits:**
[ERC1155](/src/circles/ERC1155.sol/abstract.ERC1155.md), [ICirclesErrors](/src/errors/Errors.sol/interface.ICirclesErrors.md)


## State Variables
### ISSUANCE_PER_SECOND
Issue one Circle per hour for each human in demurraged units.
So per second issue 10**18 / 3600 = 277777777777778 attoCircles.


```solidity
uint256 private constant ISSUANCE_PER_SECOND = uint256(277777777777778);
```


### MAX_CLAIM_DURATION
Upon claiming, the maximum claim is upto two weeks
of history. Unclaimed older Circles are unclaimable.


```solidity
uint256 private constant MAX_CLAIM_DURATION = 2 weeks;
```


### CIRCLES_STOPPED_V1
*Address used to indicate that the associated v1 Circles contract has been stopped.*


```solidity
address internal constant CIRCLES_STOPPED_V1 = address(0x1);
```


### INDEFINITE_FUTURE
Indefinite future, or approximated with uint96.max


```solidity
uint96 internal constant INDEFINITE_FUTURE = type(uint96).max;
```


### mintTimes
The mapping of avatar addresses to the last mint time,
and the status of the v1 Circles minting.

*This is used to store the last mint time for each avatar.*


```solidity
mapping(address => MintTime) internal mintTimes;
```


## Functions
### constructor

Constructor to create a Circles ERC1155 contract with demurrage.


```solidity
constructor(uint256 _inflation_day_zero, string memory _uri) ERC1155(_uri) DiscountedBalances(_inflation_day_zero);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_inflation_day_zero`|`uint256`|Inflation day zero stores the start of the global inflation curve|
|`_uri`|`string`|uri for the Circles metadata|


### calculateIssuance

Calculate the demurraged issuance for a human's avatar.


```solidity
function calculateIssuance(address _human) public view returns (uint256, uint256, uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|Address of the human's avatar to calculate the issuance for.|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|issuance The issuance in attoCircles.|
|`<none>`|`uint256`|startPeriod The start of the claimable period.|
|`<none>`|`uint256`|endPeriod The end of the claimable period.|


### inflationaryBalanceOf

Inflationary balance of an account for a Circles identifier. Careful,
calculating the inflationary balance can introduce numerical errors
in the least significant digits (order of few attoCircles).


```solidity
function inflationaryBalanceOf(address _account, uint256 _id) public view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_account`|`address`|Address for which the balance is queried.|
|`_id`|`uint256`|Circles identifier for which the balance is queried.|


### safeInflationaryTransferFrom

safeInflationaryTransferFrom transfers Circles from one address to another by specifying inflationary units.


```solidity
function safeInflationaryTransferFrom(
    address _from,
    address _to,
    uint256 _id,
    uint256 _inflationaryValue,
    bytes memory _data
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|Address from which the Circles are transferred.|
|`_to`|`address`|Address to which the Circles are transferred.|
|`_id`|`uint256`|Circles indentifier for which the Circles are transferred.|
|`_inflationaryValue`|`uint256`|Inflationary value of the Circles transferred.|
|`_data`|`bytes`|Data to pass to the receiver.|


### safeInflationaryBatchTransferFrom

safeInflationaryBatchTransferFrom transfers Circles from one address to another by specifying inflationary units.


```solidity
function safeInflationaryBatchTransferFrom(
    address _from,
    address _to,
    uint256[] memory _ids,
    uint256[] memory _inflationaryValues,
    bytes memory _data
) public;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_from`|`address`|Address from which the Circles are transferred.|
|`_to`|`address`|Address to which the Circles are transferred.|
|`_ids`|`uint256[]`|Batch of Circles identifiers for which the Circles are transferred.|
|`_inflationaryValues`|`uint256[]`|Batch of inflationary values of the Circles transferred.|
|`_data`|`bytes`|Data to pass to the receiver.|


### _claimIssuance

Claim issuance for a human's avatar and update the last mint time.


```solidity
function _claimIssuance(address _human) internal;
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_human`|`address`|Address of the human's avatar to claim the issuance for.|


### _mintAndUpdateTotalSupply


```solidity
function _mintAndUpdateTotalSupply(address _account, uint256 _id, uint256 _value, bytes memory _data) internal;
```

### _burnAndUpdateTotalSupply


```solidity
function _burnAndUpdateTotalSupply(address _account, uint256 _id, uint256 _value) internal;
```

### _max

*Max function to compare two values.*


```solidity
function _max(uint256 a, uint256 b) private pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`a`|`uint256`|Value a|
|`b`|`uint256`|Value b|


## Events
### PersonalMint

```solidity
event PersonalMint(address indexed human, uint256 amount, uint256 startPeriod, uint256 endPeriod);
```

## Structs
### MintTime
MintTime struct stores the last mint time,
and the status of a connected v1 Circles contract.

*This is used to store the last mint time for each avatar,
and the address is used as a status for the connected v1 Circles contract.
The address is kept at zero address if the avatar is not registered in Hub v1.
If the avatar is registered in Hub v1, but the associated Circles ERC20 contract
has not been stopped, then the address is set to that v1 Circles contract address.
Once the Circles v1 contract has been stopped, the address is set to 0x01.
At every observed transition of the status of the v1 Circles contract,
the lastMintTime will be updated to the current timestamp to avoid possible
overlap of the mint between Hub v1 and Hub v2.*


```solidity
struct MintTime {
    address mintV1Status;
    uint96 lastMintTime;
}
```

