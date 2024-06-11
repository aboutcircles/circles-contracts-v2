# Demurrage
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/circles/Demurrage.sol)

**Inherits:**
[ICirclesDemurrageErrors](/src/errors/Errors.sol/interface.ICirclesDemurrageErrors.md)


## State Variables
### DEMURRAGE_WINDOW
Demurrage window reduces the resolution for calculating
the demurrage of balances from once per second (block.timestamp)
to once per day.


```solidity
uint256 private constant DEMURRAGE_WINDOW = 1 days;
```


### MAX_VALUE
*Maximum value that can be stored or transferred*


```solidity
uint256 internal constant MAX_VALUE = type(uint192).max;
```


### GAMMA_64x64
*Reduction factor GAMMA for applying demurrage to balances
demurrage_balance(d) = GAMMA^d * inflationary_balance
where 'd' is expressed in days (DEMURRAGE_WINDOW) since demurrage_day_zero,
and GAMMA < 1.
GAMMA_64x64 stores the numerator for the signed 128bit 64.64
fixed decimal point expression:
GAMMA = GAMMA_64x64 / 2**64.
To obtain GAMMA for a daily accounting of 7% p.a. demurrage
=> GAMMA = (0.93)^(1/365.25)
= 0.99980133200859895743...
and expressed in 64.64 fixed point representation:
=> GAMMA_64x64 = 18443079296116538654
For more details, see ./specifications/TCIP009-demurrage.md*


```solidity
int128 internal constant GAMMA_64x64 = int128(18443079296116538654);
```


### BETA_64x64
*For calculating the inflationary mint amount on day `d`
since demurrage_day_zero, a person can mint
(1/GAMMA)^d CRC / hour
As GAMMA is a constant, to save gas costs store the inverse
as BETA = 1 / GAMMA.
BETA_64x64 is the 64.64 fixed point representation:
BETA_64x64 = 2**64 / ((0.93)^(1/365.25))
= 18450409579521241655
For more details, see ./specifications/TCIP009-demurrage.md*


```solidity
int128 internal constant BETA_64x64 = int128(18450409579521241655);
```


### DECIMALS
*ERC1155 tokens MUST be 18 decimals.*


```solidity
uint8 internal constant DECIMALS = uint8(18);
```


### EXA
*EXA factor as 10^18*


```solidity
uint256 internal constant EXA = uint256(10 ** DECIMALS);
```


### ONE_64x64
*Store the signed 128-bit 64.64 representation of 1 as a constant*


```solidity
int128 internal constant ONE_64x64 = int128(2 ** 64);
```


### R_TABLE_LOOKUP

```solidity
uint8 internal constant R_TABLE_LOOKUP = uint8(14);
```


### inflationDayZero
Inflation day zero stores the start of the global inflation curve
As Circles Hub v1 was deployed on Thursday 15th October 2020 at 6:25:30 pm UTC,
or 1602786330 unix time, in production this value MUST be set to 1602720000 unix time,
or midnight prior of the same day of deployment, marking the start of the first day
where there was no inflation on one CRC per hour.


```solidity
uint256 public inflationDayZero;
```


### T
*Store a lookup table T(n) for computing issuance.
T is only accessed for minting in Hub.sol, so it is initialized in
storage of Hub.sol during the constructor, by copying these values.
(It is not properly intialized in a ERC20 Proxy contract, but we never need
to access it there, so it is not a problem - it is only initialized in the
storage of the mastercopy during deployment.)
See ../../specifications/TCIP009-demurrage.md for more details.*


```solidity
int128[15] internal T = [
    int128(442721857769029238784),
    int128(885355760875826166476),
    int128(1327901726794166863126),
    int128(1770359772994355928788),
    int128(2212729916943227173193),
    int128(2655012176104144305282),
    int128(3097206567937001622606),
    int128(3539313109898224700583),
    int128(3981331819440771081628),
    int128(4423262714014130964135),
    int128(4865105811064327891331),
    int128(5306861128033919439986),
    int128(5748528682361997908993),
    int128(6190108491484191007805),
    int128(6631600572832662544739)
];
```


### R
*Store a lookup table R(n) for computing issuance and demurrage.
This table is computed in the constructor of Hub.sol and mastercopy deployments,
and lazily computed in the ERC20 Demurrage proxy contracts, then cached into their storage.
The non-trivial situation for R(n) (vs T(n)) is that R is accessed
from the ERC20 Demurrage proxy contracts, so their storage will not yet
have been initialized with the constructor. (Counter to T which is only
accessed for minting in Hub.sol, and as such initialized in the constructor
of Hub.sol by Solidity by copying the python calculated values stored above.)
Computing R in contract is done with .64bits precision, whereas the python computed
table is slightly more accurate, but equal within dust (10^-18). See unit tests.
However, we want to ensure that Hub.sol and the ERC20 Demurrage proxy contracts
use the exact same R values (even if the difference would not matter).
So for R we rely on the in-contract computed values.
In the unit tests, the table of python computed values is stored in HIGHER_ACCURACY_R,
and matched against the solidity computed values.
See ../../specifications/TCIP009-demurrage.md for more details.*


```solidity
int128[15] internal R;
```


## Functions
### constructor


```solidity
constructor();
```

### day

Calculate the day since inflation_day_zero for a given timestamp.


```solidity
function day(uint256 _timestamp) public view returns (uint64);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_timestamp`|`uint256`|Timestamp for which to calculate the day since inflation_day_zero.|


### toTokenId

Casts an avatar address to a tokenId uint256.


```solidity
function toTokenId(address _avatar) public pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_avatar`|`address`|avatar address to convert to tokenId|


### convertInflationaryToDemurrageValue

Converts an inflationary value to a demurrage value for a given day since inflation_day_zero.


```solidity
function convertInflationaryToDemurrageValue(uint256 _inflationaryValue, uint64 _day) public pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_inflationaryValue`|`uint256`|Inflationary value to convert to demurrage value.|
|`_day`|`uint64`|Day since inflation_day_zero to convert the inflationary value to a demurrage value.|


### convertBatchInflationaryToDemurrageValues

Converts a batch of inflationary values to demurrage values for a given day since inflation_day_zero.


```solidity
function convertBatchInflationaryToDemurrageValues(uint256[] memory _inflationaryValues, uint64 _day)
    public
    pure
    returns (uint256[] memory);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_inflationaryValues`|`uint256[]`|Batch of inflationary values to convert to demurrage values.|
|`_day`|`uint64`|Day since inflation_day_zero to convert the inflationary values to demurrage values.|


### _calculateDiscountedBalance

*Calculates the discounted balance given a number of days to discount*


```solidity
function _calculateDiscountedBalance(uint256 _balance, uint256 _daysDifference) internal view returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balance`|`uint256`|balance to calculate the discounted balance of|
|`_daysDifference`|`uint256`|days of difference between the last updated day and the day of interest|


### _calculateDiscountedBalanceAndCache


```solidity
function _calculateDiscountedBalanceAndCache(uint256 _balance, uint256 _daysDifference) internal returns (uint256);
```

### _calculateDemurrageFactor


```solidity
function _calculateDemurrageFactor(uint256 _dayDifference) internal view returns (int128);
```

### _calculateDemurrageFactorAndCache


```solidity
function _calculateDemurrageFactorAndCache(uint256 _dayDifference) internal returns (int128);
```

### _calculateInflationaryBalance

Calculate the inflationary balance of a demurraged balance


```solidity
function _calculateInflationaryBalance(uint256 _balance, uint256 _dayUpdated) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`_balance`|`uint256`|Demurraged balance to calculate the inflationary balance of|
|`_dayUpdated`|`uint256`|The day the balance was last updated|


## Events
### DiscountCost

```solidity
event DiscountCost(address indexed account, uint256 indexed id, uint256 discountCost);
```

## Structs
### DiscountedBalance
*Discounted balance with a last updated timestamp.
Note: The balance is stored as a 192-bit unsigned integer.
The last updated timestamp is stored as a 64-bit unsigned integer counting the days
since `inflation_day_zero` (for elegance, to not start the clock in 1970 with unix time).
We ensure that they combine to 32 bytes for a single Ethereum storage slot.
Note: The maximum total supply of CRC is ~10^5 per human, with 10**10 humans,
so even if all humans would pool all their tokens into a single group and then a single account
the total resolution required is 10^(10 + 5 + 18) = 10^33 << 10**57 (~ max uint192).*


```solidity
struct DiscountedBalance {
    uint192 balance;
    uint64 lastUpdatedDay;
}
```

