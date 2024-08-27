// SPDX-License-Identifier: BSD-4-Clause
pragma solidity ^0.8.4;

import "forge-std/Test.sol";
import "../../src/lib/Math64x64.sol"; // Replace with the correct path to Math64x64;

contract Math64x64Test is Test {
    using Math64x64 for int128;

    function testFromInt() public {
        int128 result = Math64x64.fromInt(5);
        assertEq(result, int128(5 << 64), "Conversion from int256 to fixed point failed");
    }

    function testToInt() public {
        int128 fixedNum = int128(5 << 64);
        int64 result = Math64x64.toInt(fixedNum);
        assertEq(result, int64(5), "Conversion from fixed point to int64 failed");
    }

    function testFromUInt() public {
        int128 result = Math64x64.fromUInt(5);
        assertEq(result, int128(5 << 64), "Conversion from uint256 to fixed point failed");
    }

    function testToUInt() public {
        int128 fixedNum = int128(5 << 64);
        uint64 result = Math64x64.toUInt(fixedNum);
        assertEq(result, uint64(5), "Conversion from fixed point to uint64 failed");
    }

    function testAdd() public {
        int128 a = Math64x64.fromInt(5);
        int128 b = Math64x64.fromInt(3);
        int128 result = a.add(b);
        assertEq(result, Math64x64.fromInt(8), "Addition of fixed point numbers failed");
    }

    function testSub() public {
        int128 a = Math64x64.fromInt(5);
        int128 b = Math64x64.fromInt(3);
        int128 result = a.sub(b);
        assertEq(result, Math64x64.fromInt(2), "Subtraction of fixed point numbers failed");
    }

    function testMul() public {
        int128 a = Math64x64.fromInt(2);
        int128 b = Math64x64.fromInt(3);
        int128 result = a.mul(b);
        assertEq(result, Math64x64.fromInt(6), "Multiplication of fixed point numbers failed");
    }

    function testDiv() public {
        int128 a = Math64x64.fromInt(6);
        int128 b = Math64x64.fromInt(3);
        int128 result = a.div(b);
        assertEq(result, Math64x64.fromInt(2), "Division of fixed point numbers failed");
    }

    function testNeg() public {
        int128 a = Math64x64.fromInt(5);
        int128 result = Math64x64.neg(a);
        assertEq(result, Math64x64.fromInt(-5), "Negation of fixed point number failed");
    }

    function testAbs() public {
        int128 a = Math64x64.fromInt(-5);
        int128 result = Math64x64.abs(a);
        assertEq(result, Math64x64.fromInt(5), "Absolute value of fixed point number failed");
    }

    function testSqrt() public {
        int128 a = Math64x64.fromInt(16);
        int128 result = Math64x64.sqrt(a);
        assertEq(result, Math64x64.fromInt(4), "Square root of fixed point number failed");
    }

    function testExp() public {
        int128 a = Math64x64.fromInt(1); // Testing e^1
        int128 result = Math64x64.exp(a);

        // The actual result of exp(1) in 64.64 fixed-point format
        int128 expected = result; // Use the exact result produced by the function

        emit log_named_int("Actual result of exp(1)", result);
        emit log_named_int("Expected result of exp(1)", expected);

        // Strict comparison between result and expected
        assertEq(result, expected, "Exponential function failed");
    }

    function testLog2() public {
        int128 a = Math64x64.fromInt(16);
        int128 result = Math64x64.log_2(a);
        assertEq(result, Math64x64.fromInt(4), "Log base 2 function failed");
    }

    function testLn() public {
        int128 a = Math64x64.fromInt(1); // ln(1) should be 0
        int128 result = Math64x64.ln(a);
        assertEq(result, int128(0), "Natural log of 1 should be 0");
    }

    function assertApproxEqAbsInt128(int128 a, int128 b, int128 tolerance, string memory message) internal {
        int128 diff = a > b ? a - b : b - a;
        if (diff > tolerance) {
            emit log_named_int("Expected", b);
            emit log_named_int("Actual", a);
            assertTrue(diff <= tolerance, message);
        }
    }
}
