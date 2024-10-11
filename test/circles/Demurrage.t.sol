// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../setup/TimeCirclesSetup.sol";
import "../utils/Approximation.sol";
import "./MockDemurrage.sol";

contract DemurrageTest is Test, TimeCirclesSetup, Approximation {
    // State variables

    MockDemurrage public demurrage;

    /**
     * @dev Store a lookup table R(n) for computing issuance.
     * See ../../specifications/TCIP009-demurrage.md for more details.
     */
    uint256[15] internal HIGHER_ACCURACY_R = [
        uint256(18446744073709551616), // 0, ONE_64x64
        uint256(18443079296116538654), // 1, GAMMA_64x64
        uint256(18439415246597529027), // 2, GAMMA_64x64^2
        uint256(18435751925007877736), // 3, etc.
        uint256(18432089331202968517),
        uint256(18428427465038213837),
        uint256(18424766326369054888),
        uint256(18421105915050961582),
        uint256(18417446230939432544),
        uint256(18413787273889995104),
        uint256(18410129043758205300),
        uint256(18406471540399647861),
        uint256(18402814763669936209),
        uint256(18399158713424712450),
        uint256(18395503389519647372)
    ];

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();

        demurrage = new MockDemurrage();

        demurrage.setInflationDayZero(INFLATION_DAY_ZERO);
    }

    // Tests

    function testDemurrageFactor() public {
        for (uint256 i = 0; i <= demurrage.rLength(); i++) {
            assertTrue(
                relativeApproximatelyEqual(
                    uint256(int256(Math64x64.pow(demurrage.gamma_64x64(), i))), HIGHER_ACCURACY_R[i], DUST
                )
            );
        }
    }

    // Test the inversion accuracy of the gamma and beta exponentiation over 20 and 100 years
    // with and without the extension
    // conclusion: we can just drop the extension as the 64x64 fixed point is accurate, and unsure if the extension
    // is actually doing something? -- maybe not because GAMMA and BETA have a fixed precision, so they will always
    // introduce errors at their precision level... so the extension is pointless and costs extra gas

    // (note) leaving these tests here for now, to document why the extension is removed from Inflationary ERC20 in patch21!
    // this can later be tidied up and removed

    function testInversionGammaBeta64x64_20years() public {
        // for the coming 20 years (2024 is year 4 since INFLATION_DAY_ZERO)
        // check that simply exponentiating the number of days remains accurate
        // and without overflow

        // one year in unix time (approximately)
        uint256 oneYear = 365 * 24 * 3600;

        for (uint256 i = 0; i <= 20; i++) {
            uint256 secondsNow = INFLATION_DAY_ZERO + i * oneYear;
            uint64 dayCount = demurrage.day(secondsNow);
            // convert one CRC to inflationary value
            uint256 inflationaryOneCRC = demurrage.convertDemurrageToInflationaryValue(100 * CRC, dayCount);
            // now invert the operation
            uint256 demurrageOneCRC = demurrage.convertInflationaryToDemurrageValue(inflationaryOneCRC, dayCount);
            assertTrue(relativeApproximatelyEqual(100 * CRC, demurrageOneCRC, 1000 * DUST));
            console.log("year ", i, ": ", demurrageOneCRC);
        }
    }

    function testInversionGammaBeta64x64_100years() public {
        // for the coming 100 years (2024 is year 4 since INFLATION_DAY_ZERO)
        // check that simply exponentiating the number of days remains accurate
        // and without overflow

        // one year in unix time (approximately)
        uint256 oneYear = 365 * 24 * 3600;

        for (uint256 i = 0; i <= 100; i++) {
            uint256 secondsNow = INFLATION_DAY_ZERO + i * oneYear;
            uint64 dayCount = demurrage.day(secondsNow);
            // convert one CRC to inflationary value
            uint256 inflationaryOneCRC = demurrage.convertDemurrageToInflationaryValue(CRC, dayCount);
            // now invert the operation
            uint256 demurrageOneCRC = demurrage.convertInflationaryToDemurrageValue(inflationaryOneCRC, dayCount);
            assertTrue(relativeApproximatelyEqual(CRC, demurrageOneCRC, 1000 * DUST));
        }
    }

    function testInversionGammaBeta64x64_100years_withExtension() public {
        // for the coming 100 years (2024 is year 4 since INFLATION_DAY_ZERO)
        // check that simply exponentiating the number of days remains accurate
        // and without overflow

        // one year in unix time (approximately)
        uint256 oneYear = 365 * 24 * 3600;

        uint8 accuracy_shift = 64;

        uint192 amount = uint192(10000000 * CRC);
        console.log("amount: ", amount);

        for (uint256 i = 0; i <= 100; i++) {
            uint256 secondsNow = INFLATION_DAY_ZERO + i * oneYear;
            uint64 dayCount = demurrage.day(secondsNow);
            // convert one CRC to inflationary value
            uint256 extendedAmount = amount << accuracy_shift;
            uint256 inflationaryAmountExtended = demurrage.convertDemurrageToInflationaryValue(extendedAmount, dayCount);
            uint256 trimmedInflationaryAmount = inflationaryAmountExtended >> accuracy_shift;
            // now invert the operation
            uint256 extendedInflationAmountTrimmed = trimmedInflationaryAmount << accuracy_shift;
            uint256 demurrageAmountExtended =
                demurrage.convertInflationaryToDemurrageValue(extendedInflationAmountTrimmed, dayCount);
            uint256 trimmedDemurrageAmount = demurrageAmountExtended >> accuracy_shift;
            assertTrue(relativeApproximatelyEqual(amount, trimmedDemurrageAmount, 1000 * DUST));
            console.log("year ", i, ": ", trimmedDemurrageAmount);
        }
    }

    function testInversionGammaBeta64x64_100years_withExtension_comparison() public {
        // for the coming 100 years (2024 is year 4 since INFLATION_DAY_ZERO)
        // check that simply exponentiating the number of days remains accurate
        // and without overflow

        // one year in unix time (approximately)
        uint256 oneYear = 365 * 24 * 3600;

        uint8 accuracy_shift = 64;

        uint192 amount = uint192(254516523121 * CRC);
        console.log("amount: ", amount);

        for (uint256 i = 0; i <= 100; i++) {
            uint256 secondsNow = INFLATION_DAY_ZERO + i * oneYear;
            uint64 dayCount = demurrage.day(secondsNow);
            // convert one CRC to inflationary value
            uint256 extendedAmount = amount << accuracy_shift;
            uint256 inflationaryAmountExtended = demurrage.convertDemurrageToInflationaryValue(extendedAmount, dayCount);
            uint256 trimmedInflationaryAmount = inflationaryAmountExtended >> accuracy_shift;
            // now invert the operation
            uint256 extendedInflationAmountTrimmed = trimmedInflationaryAmount << accuracy_shift;
            uint256 demurrageAmountExtended =
                demurrage.convertInflationaryToDemurrageValue(extendedInflationAmountTrimmed, dayCount);
            uint256 trimmedDemurrageAmount = demurrageAmountExtended >> accuracy_shift;

            // now do the same without extension
            uint256 inflationaryAmount_withoutExtension =
                demurrage.convertDemurrageToInflationaryValue(amount, dayCount);
            // now invert the operation
            uint256 demurrageAmount_withoutExtension =
                demurrage.convertInflationaryToDemurrageValue(inflationaryAmount_withoutExtension, dayCount);

            uint256 diff = demurrageAmount_withoutExtension > trimmedDemurrageAmount
                ? demurrageAmount_withoutExtension - trimmedDemurrageAmount
                : trimmedDemurrageAmount - demurrageAmount_withoutExtension;

            assertTrue(diff == 0);
            console.log(trimmedDemurrageAmount, " vs ", demurrageAmount_withoutExtension);
        }
    }
}
