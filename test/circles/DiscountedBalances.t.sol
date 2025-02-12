// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {console2, Test} from "forge-std/Test.sol";
import {TimeCirclesSetup} from "../setup/TimeCirclesSetup.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {ICirclesCompactErrors, ICirclesDemurrageErrors} from "src/errors/Errors.sol";
import {IDiscountedBalances, MockDiscountedBalances} from "test/circles/mocks/MockDiscountedBalances.sol";

contract DiscountedBalancesTest is Test, TimeCirclesSetup, ICirclesCompactErrors, ICirclesDemurrageErrors {
    MockDiscountedBalances public discountedBalances;
    // represents Demurrage.MAX_VALUE
    uint256 internal maxBalance;
    // default test values
    address internal defaultAvatar;
    uint256 internal defaultId;
    uint192 internal defaultValue;
    uint64 internal defaultDay;

    function setUp() public {
        // Set time in 2021
        startTime();

        discountedBalances = new MockDiscountedBalances(INFLATION_DAY_ZERO);
        maxBalance = discountedBalances.maxBalance();

        defaultAvatar = address(0xa4a7a5);
        defaultId = uint256(0x1d);
        defaultValue = uint192(10 ** 18);
        defaultDay = uint64(0xda1);
    }

    // Internal _updateBalance(address _account, uint256 _id, uint256 _balance, uint64 _day)

    function testUpdateBalance(address avatar, uint256 id, uint256 newBalance, uint64 newDay) public {
        if (newBalance <= maxBalance) {
            // balance should be updated correctly
            discountedBalances.updateBalance(avatar, id, newBalance, newDay);

            uint192 updatedAvatarBalance = discountedBalances.getAvatarBalanceValue(id, avatar);
            uint64 updatedAvatarLastUpdatedDay = discountedBalances.getAvatarLastUpdatedDayValue(id, avatar);

            assertEq(updatedAvatarBalance, newBalance);
            assertEq(updatedAvatarLastUpdatedDay, newDay);
        } else {
            // call should revert when balance exceeds MAX_VALUE
            vm.expectRevert(abi.encodeWithSelector(CirclesErrorAddressUintArgs.selector, avatar, id, 0x81));
            discountedBalances.updateBalance(avatar, id, newBalance, newDay);
        }
    }

    // Internal _discountAndAddToBalance(address _account, uint256 _id, uint256 _value, uint64 _day)

    function testDiscountFromInitialZeroBalanceAndAddValue(
        address avatar,
        uint256 id,
        uint256 newBalance,
        uint64 newDay
    ) public {
        // behaves exactly the same as _updateBalance
        if (newBalance <= maxBalance) {
            // balance should be updated correctly
            discountedBalances.discountAndAddToBalance(avatar, id, newBalance, newDay);

            uint192 updatedAvatarBalance = discountedBalances.getAvatarBalanceValue(id, avatar);
            uint64 updatedAvatarLastUpdatedDay = discountedBalances.getAvatarLastUpdatedDayValue(id, avatar);

            assertEq(updatedAvatarBalance, newBalance);
            assertEq(updatedAvatarLastUpdatedDay, newDay);
        } else {
            // call should revert when balance exceeds MAX_VALUE
            vm.expectRevert(abi.encodeWithSelector(CirclesErrorAddressUintArgs.selector, avatar, id, 0x82));
            discountedBalances.discountAndAddToBalance(avatar, id, newBalance, newDay);
        }
    }

    function testDiscountAndAddToBalance() public {
        // store default values
        discountedBalances.updateBalance(defaultAvatar, defaultId, defaultValue, defaultDay);

        // first branch: dayDifference == 0 (input: same day as last updated and defaultValue)
        uint64 day = defaultDay;
        uint256 addedValue = defaultValue;

        discountedBalances.discountAndAddToBalance(defaultAvatar, defaultId, addedValue, day);

        // should update balance by adding value without applying discount and leaving same last updated day
        uint192 updatedAvatarBalance = discountedBalances.getAvatarBalanceValue(defaultId, defaultAvatar);
        uint64 updatedAvatarLastUpdatedDay = discountedBalances.getAvatarLastUpdatedDayValue(defaultId, defaultAvatar);
        assertEq(updatedAvatarBalance, 2 * defaultValue);
        assertEq(updatedAvatarLastUpdatedDay, defaultDay);

        // second branch: dayDifference != 0 and discount < addedValue (input: small day difference and defaultValue)
        day += 10;

        // should emit DiscountCost events
        _expectEmitDiscountEvents(defaultId, defaultAvatar);

        discountedBalances.discountAndAddToBalance(defaultAvatar, defaultId, addedValue, day);

        // should increase balance by applying small discount and adding significant value, update last updated day
        updatedAvatarBalance = discountedBalances.getAvatarBalanceValue(defaultId, defaultAvatar);
        updatedAvatarLastUpdatedDay = discountedBalances.getAvatarLastUpdatedDayValue(defaultId, defaultAvatar);
        assertTrue(updatedAvatarBalance > 2 * defaultValue && updatedAvatarBalance < 3 * defaultValue);
        assertEq(updatedAvatarLastUpdatedDay, day);

        // third branch: dayDifference != 0 and discount > addedValue (input: big day difference and small added value)
        day += 7200;
        addedValue /= 10;

        // should emit DiscountCost events
        _expectEmitDiscountEvents(defaultId, defaultAvatar);

        discountedBalances.discountAndAddToBalance(defaultAvatar, defaultId, addedValue, day);

        // should decrease balance by applying significant discount and adding small value, update last updated day
        updatedAvatarBalance = discountedBalances.getAvatarBalanceValue(defaultId, defaultAvatar);
        updatedAvatarLastUpdatedDay = discountedBalances.getAvatarLastUpdatedDayValue(defaultId, defaultAvatar);
        assertTrue(updatedAvatarBalance < defaultValue);
        assertEq(updatedAvatarLastUpdatedDay, day);
    }

    function testRevertInputDayBeforeLastUpdatedDay(uint64 newDay) public {
        vm.assume(newDay > 0);
        // store default values and newDay (becomes the last updated day)
        discountedBalances.updateBalance(defaultAvatar, defaultId, defaultValue, newDay);

        // set input as a day before the last updated day
        uint64 inputDay = newDay - 1;

        // two functions should revert

        // test internal discountAndAddToBalance
        vm.expectRevert(abi.encodeWithSelector(CirclesErrorAddressUintArgs.selector, defaultAvatar, newDay, 0xA1));
        discountedBalances.discountAndAddToBalance(defaultAvatar, defaultId, defaultValue, inputDay);
        // test public balanceOfOnDay
        vm.expectRevert(abi.encodeWithSelector(CirclesErrorAddressUintArgs.selector, defaultAvatar, newDay, 0xA0));
        discountedBalances.balanceOfOnDay(defaultAvatar, defaultId, inputDay);
    }

    // Public totalSupply(uint256 _id)

    function testTotalSupply(uint256 id, uint192 balance) public {
        uint64 day = discountedBalances.day(block.timestamp);
        discountedBalances.updateTotalSupply(id, balance, day);

        uint192 storedSupply = discountedBalances.getTotalSupplyBalanceValue(id);
        uint64 storedDay = discountedBalances.getTotalSupplyLastUpdatedDayValue(id);
        assertEq(balance, storedSupply);
        assertEq(day, storedDay);

        uint256 staticCallResult = discountedBalances.totalSupply(id);
        assertEq(staticCallResult, balance);

        // test total supply is discounted on a new day
        if (balance > 10) {
            skipTime(1 days);
            uint256 discountedTotalSupply = discountedBalances.totalSupply(id);
            assertTrue(uint192(discountedTotalSupply) < balance);
            // test supply is discounted in a year
            skipTime(730 days);
            uint256 totalSupplyInAYear = discountedBalances.totalSupply(id);
            assertTrue(uint192(totalSupplyInAYear) < uint192(discountedTotalSupply));
        }
    }

    // Public balanceOfOnDay(address _account, uint256 _id, uint64 _day)

    function testBalanceOfOnDay(address avatar, uint256 id, uint64 day) public {
        vm.assume(day <= type(uint64).max - 31);
        // zero balance always returns 0,0
        (uint256 balanceOnDay, uint256 discountCost) = discountedBalances.balanceOfOnDay(avatar, id, day);
        assertEq(balanceOnDay, 0);
        assertEq(discountCost, 0);

        // store default balance for avatar
        discountedBalances.updateBalance(avatar, id, defaultValue, day);

        // returned balance should remain the same on the same day as last update, with a discount cost of 0.
        uint64 requestedDay = day;
        (balanceOnDay, discountCost) = discountedBalances.balanceOfOnDay(avatar, id, requestedDay);
        assertEq(balanceOnDay, defaultValue);
        assertEq(discountCost, 0);

        // returned balance should be discounted
        requestedDay += 31;
        (balanceOnDay, discountCost) = discountedBalances.balanceOfOnDay(avatar, id, requestedDay);
        assertEq(balanceOnDay + discountCost, defaultValue);
        assertTrue(discountCost > 0);
    }

    // Internal helpers

    /// @dev should emit IERC1155.TransferSingle and DiscountCost events (discountCost value check is skipped)
    function _expectEmitDiscountEvents(uint256 id, address avatar) internal {
        vm.expectEmit(true, true, true, false);
        emit IERC1155.TransferSingle(address(this), avatar, address(0), id, 0);
        vm.expectEmit(true, true, false, false);
        emit IDiscountedBalances.DiscountCost(avatar, id, 0);
    }
}
