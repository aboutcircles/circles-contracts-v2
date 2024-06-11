# Math64x64
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/lib/Math64x64.sol)

Smart contract library of mathematical functions operating with signed
64.64-bit fixed point numbers.  Signed 64.64-bit fixed point number is
basically a simple fraction whose numerator is signed 128-bit integer and
denominator is 2^64.  As long as denominator is always the same, there is no
need to store it, thus in Solidity signed 64.64-bit fixed point numbers are
represented by int128 type holding only the numerator.


## State Variables
### MIN_64x64

```solidity
int128 private constant MIN_64x64 = -0x80000000000000000000000000000000;
```


### MAX_64x64

```solidity
int128 private constant MAX_64x64 = 0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
```


## Functions
### fromInt

Convert signed 256-bit integer number into signed 64.64-bit fixed point
number.  Revert on overflow.


```solidity
function fromInt(int256 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int256`|signed 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### toInt

Convert signed 64.64 fixed point number into signed 64-bit integer number
rounding down.


```solidity
function toInt(int128 x) internal pure returns (int64);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int64`|signed 64-bit integer number|


### fromUInt

Convert unsigned 256-bit integer number into signed 64.64-bit fixed point
number.  Revert on overflow.


```solidity
function fromUInt(uint256 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|unsigned 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### toUInt

Convert signed 64.64 fixed point number into unsigned 64-bit integer
number rounding down.  Revert on underflow.


```solidity
function toUInt(int128 x) internal pure returns (uint64);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint64`|unsigned 64-bit integer number|


### from128x128

Convert signed 128.128 fixed point number into signed 64.64-bit fixed point
number rounding down.  Revert on overflow.


```solidity
function from128x128(int256 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int256`|signed 128.128-bin fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### to128x128

Convert signed 64.64 fixed point number into signed 128.128 fixed point
number.


```solidity
function to128x128(int128 x) internal pure returns (int256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|signed 128.128 fixed point number|


### add

Calculate x + y.  Revert on overflow.


```solidity
function add(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### sub

Calculate x - y.  Revert on overflow.


```solidity
function sub(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### mul

Calculate x * y rounding down.  Revert on overflow.


```solidity
function mul(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### muli

Calculate x * y rounding towards zero, where x is signed 64.64 fixed point
number and y is signed 256-bit integer number.  Revert on overflow.


```solidity
function muli(int128 x, int256 y) internal pure returns (int256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64 fixed point number|
|`y`|`int256`|signed 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int256`|signed 256-bit integer number|


### mulu

Calculate x * y rounding down, where x is signed 64.64 fixed point number
and y is unsigned 256-bit integer number.  Revert on overflow.


```solidity
function mulu(int128 x, uint256 y) internal pure returns (uint256);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64 fixed point number|
|`y`|`uint256`|unsigned 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint256`|unsigned 256-bit integer number|


### div

Calculate x / y rounding towards zero.  Revert on overflow or when y is
zero.


```solidity
function div(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### divi

Calculate x / y rounding towards zero, where x and y are signed 256-bit
integer numbers.  Revert on overflow or when y is zero.


```solidity
function divi(int256 x, int256 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int256`|signed 256-bit integer number|
|`y`|`int256`|signed 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### divu

Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
integer numbers.  Revert on overflow or when y is zero.


```solidity
function divu(uint256 x, uint256 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|unsigned 256-bit integer number|
|`y`|`uint256`|unsigned 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### neg

Calculate -x.  Revert on overflow.


```solidity
function neg(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### abs

Calculate |x|.  Revert on overflow.


```solidity
function abs(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### inv

Calculate 1 / x rounding towards zero.  Revert on overflow or when x is
zero.


```solidity
function inv(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### avg

Calculate arithmetics average of x and y, i.e. (x + y) / 2 rounding down.


```solidity
function avg(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### gavg

Calculate geometric average of x and y, i.e. sqrt (x * y) rounding down.
Revert on overflow or in case x * y is negative.


```solidity
function gavg(int128 x, int128 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### pow

Calculate x^y assuming 0^0 is 1, where x is signed 64.64 fixed point number
and y is unsigned 256-bit integer number.  Revert on overflow.


```solidity
function pow(int128 x, uint256 y) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|
|`y`|`uint256`|uint256 value|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### sqrt

Calculate sqrt (x) rounding down.  Revert if x < 0.


```solidity
function sqrt(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### log_2

Calculate binary logarithm of x.  Revert if x <= 0.


```solidity
function log_2(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### ln

Calculate natural logarithm of x.  Revert if x <= 0.


```solidity
function ln(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### exp_2

Calculate binary exponent of x.  Revert on overflow.


```solidity
function exp_2(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### exp

Calculate natural exponent of x.  Revert on overflow.


```solidity
function exp(int128 x) internal pure returns (int128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`int128`|signed 64.64-bit fixed point number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`int128`|signed 64.64-bit fixed point number|


### divuu

Calculate x / y rounding towards zero, where x and y are unsigned 256-bit
integer numbers.  Revert on overflow or when y is zero.


```solidity
function divuu(uint256 x, uint256 y) private pure returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|unsigned 256-bit integer number|
|`y`|`uint256`|unsigned 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|unsigned 64.64-bit fixed point number|


### sqrtu

Calculate sqrt (x) rounding down, where x is unsigned 256-bit integer
number.


```solidity
function sqrtu(uint256 x) private pure returns (uint128);
```
**Parameters**

|Name|Type|Description|
|----|----|-----------|
|`x`|`uint256`|unsigned 256-bit integer number|

**Returns**

|Name|Type|Description|
|----|----|-----------|
|`<none>`|`uint128`|unsigned 128-bit integer number|


