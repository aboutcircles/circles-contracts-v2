// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {console2, Test} from "forge-std/Test.sol";
import {ICirclesErrors} from "src/errors/Errors.sol";
import {IERC1155Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {ICirclesCompactErrors} from "src/errors/Errors.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IDiscountedBalances} from "test/circles/mocks/MockDiscountedBalances.sol";
import {TimeCirclesSetup} from "test/setup/TimeCirclesSetup.sol";
import {
    MockERC1155ReceiverOk,
    MockERC1155ReceiverRevert,
    MockERC1155ReceiverWrongReturn,
    MockERC1155ReceiverNoReasonRevert
} from "test/circles/mocks/MockERC1155.sol";
import {MockCircles, MockReentrantReceiver} from "test/circles/mocks/MockCircles.sol";

/**
 * @title CirclesTest
 * @notice Provides unit tests for the Circles contract (via MockCircles).
 */
contract CirclesTest is Test, TimeCirclesSetup, IERC1155Errors, ICirclesErrors {
    /// @notice The MockCircles instance under test.
    MockCircles public circles;

    /// @notice Represents Demurrage.MAX_VALUE in the underlying Circles contract.
    uint256 internal maxBalance;

    /// @notice Mock receivers used to test different receiving scenarios.
    MockERC1155ReceiverOk internal receiverOk;
    MockERC1155ReceiverRevert internal receiverRevert;
    MockERC1155ReceiverWrongReturn internal receiverWrongReturn;
    MockERC1155ReceiverNoReasonRevert internal receiverNoReasonRevert;
    MockReentrantReceiver internal receiverReentrant;

    /// @notice Tracks the current day (based on inflationDayZero).
    uint64 currentDay;

    /**
     * @notice Initializes the test environment.
     * @dev Sets the start time (inherited from TimeCirclesSetup), deploys MockCircles
     *      and the various mock receivers. Also records `maxBalance` and `currentDay`
     *      for verification in tests.
     */
    function setUp() public {
        // Set time in 2021 (from TimeCirclesSetup)
        startTime();

        // Deploy the mock Circles contract
        circles = new MockCircles(INFLATION_DAY_ZERO, "circles");

        // Store the maximum possible balance (from the parent contract constant)
        maxBalance = circles.getMaxBalance();

        // Record the current day
        currentDay = circles.day(block.timestamp);

        // Deploy mock receivers to test receiving logic in the ERC1155 flow
        receiverOk = new MockERC1155ReceiverOk();
        receiverRevert = new MockERC1155ReceiverRevert();
        receiverWrongReturn = new MockERC1155ReceiverWrongReturn();
        receiverNoReasonRevert = new MockERC1155ReceiverNoReasonRevert();
        receiverReentrant = new MockReentrantReceiver(circles);

        // Verify the receivers correctly support the IERC1155Receiver interface
        bytes4 iERC1155Receiver = type(IERC1155Receiver).interfaceId;
        assertTrue(receiverOk.supportsInterface(iERC1155Receiver));
        assertTrue(receiverRevert.supportsInterface(iERC1155Receiver));
        assertTrue(receiverWrongReturn.supportsInterface(iERC1155Receiver));
        assertTrue(receiverReentrant.supportsInterface(iERC1155Receiver));
    }

    // -------------------------------------------------------------------------
    // Test internal `_max` function
    // -------------------------------------------------------------------------

    /**
     * @notice Tests the `_max` function in the MockCircles contract by comparing
     *         two random values and checking that the returned result is indeed
     *         the larger of the two.
     * @param a The first random test value.
     * @param b The second random test value.
     */
    function testMax(uint256 a, uint256 b) public {
        uint256 result = circles.max(a, b);
        // Assert the returned value is indeed the maximum.
        assertTrue((result == a && result >= b) || (result == b && result >= a));
    }

    // -------------------------------------------------------------------------
    // Test internal `_mintAndUpdateTotalSupply` function
    // -------------------------------------------------------------------------

    /**
     * @notice Tests the `_mintAndUpdateTotalSupply` function in the Circles contract.
     *         Exercises various scenarios including:
     *         - Reverting on mint to the zero address
     *         - Reverting on mint beyond maxBalance
     *         - Receiver acceptance checks (EOA vs. contract receivers)
     *         - Testing reentrancy in the mock receiver
     *         - Overflow scenarios in total supply
     *         - Day transitions for demurrage
     * @param account The address to receive the minted tokens (can be an EOA or contract).
     * @param id The token ID to be minted.
     * @param value The amount of tokens to be minted in attoCircles.
     * @param data Arbitrary data forwarded to receiver (if any).
     * @param doAcceptanceCheck Flag indicating whether to trigger ERC1155 receiver checks.
     */
    function testMintAndUpdateTotalSupply(
        address account,
        uint256 id,
        uint256 value,
        bytes memory data,
        bool doAcceptanceCheck
    ) public {
        // 1. If `to == address(0)`, must revert.
        if (account == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(0)));
            circles.mintAndUpdateTotalSupply(account, id, value, data, doAcceptanceCheck);
            return;
        }

        // 2. If `value > maxBalance`, revert with CirclesErrorAddressUintArgs.
        if (value > maxBalance) {
            vm.expectRevert(
                abi.encodeWithSelector(ICirclesCompactErrors.CirclesErrorAddressUintArgs.selector, account, id, 0x82)
            );
            circles.mintAndUpdateTotalSupply(account, id, value, data, doAcceptanceCheck);
            // For further logic, clamp `value` to maxBalance so we can continue testing.
            value = maxBalance;
        }

        // 3. If `doAcceptanceCheck == true`, we must evaluate contract receivers.
        if (doAcceptanceCheck) {
            // Various failing receiver mocks:
            {
                address mockReceiver = address(receiverRevert);
                // Should revert with "No thanks"
                vm.expectRevert("No thanks");
                circles.mintAndUpdateTotalSupply(mockReceiver, id, value, data, doAcceptanceCheck);
            }
            {
                address mockReceiver = address(receiverWrongReturn);
                // Should revert with ERC1155InvalidReceiver
                vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, mockReceiver));
                circles.mintAndUpdateTotalSupply(mockReceiver, id, value, data, doAcceptanceCheck);
            }
            {
                address mockReceiver = address(receiverNoReasonRevert);
                // Should revert with reason.length == 0 => ERC1155InvalidReceiver
                vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, mockReceiver));
                circles.mintAndUpdateTotalSupply(mockReceiver, id, value, data, doAcceptanceCheck);
            }

            // Snapshot the state for repeated trials
            uint256 snapshot = vm.snapshot();

            // Test reentrancy scenario
            {
                address mockReceiver = address(receiverReentrant);
                // For demonstration, clamp if large
                if (value > maxBalance / 2) {
                    value = maxBalance / 2;
                }

                // Expect two TransferSingle events due to reentrant re-minting
                _expectEmitTransferSingle(address(this), address(0), mockReceiver, id, value);
                _expectEmitTransferSingle(mockReceiver, address(0), mockReceiver, id, value);

                circles.mintAndUpdateTotalSupply(mockReceiver, id, value, data, doAcceptanceCheck);

                // Validate final balance reflects double minting
                assertEq(_getBalance(mockReceiver, id), value * 2, "Balance mismatch after reentrancy");
                // Validate the total supply data
                assertEq(
                    circles.getTotalSupplyLastUpdatedDayValue(id),
                    currentDay,
                    "Expected total supply last updated day mismatch"
                );
                assertEq(circles.totalSupply(id), value * 2, "Expected total supply mismatch after reentrancy");
            }
            {
                // Revert to the snapshot for next scenario
                vm.revertTo(snapshot);

                // The "successful" mock receiver
                address mockReceiver = address(receiverOk);
                // Expect a standard TransferSingle event
                _expectEmitTransferSingle(address(0), mockReceiver, id, value);

                // Execute the mint
                circles.mintAndUpdateTotalSupply(mockReceiver, id, value, data, doAcceptanceCheck);

                // Validate final balance
                assertEq(_getBalance(mockReceiver, id), value, "Balance mismatch after mint");
                // Validate total supply data
                assertEq(
                    circles.getTotalSupplyLastUpdatedDayValue(id),
                    currentDay,
                    "Expected total supply last updated day mismatch"
                );
                assertEq(circles.totalSupply(id), value, "Expected total supply mismatch");
            }

            // EOA scenario
            if (account.code.length == 0) {
                // Revert again to snapshot
                vm.revertTo(snapshot);
                // Expect a standard TransferSingle event
                _expectEmitTransferSingle(address(0), account, id, value);

                // Execute the mint
                circles.mintAndUpdateTotalSupply(account, id, value, data, doAcceptanceCheck);

                // Validate final balance
                assertEq(_getBalance(account, id), value, "EOA balance mismatch after mint");
                // Validate total supply data
                assertEq(
                    circles.getTotalSupplyLastUpdatedDayValue(id), currentDay, "Expected total supply last updated day"
                );
                assertEq(circles.totalSupply(id), value, "Expected total supply mismatch");
            }
        } else {
            // 4. If `doAcceptanceCheck == false`, skip acceptance checks.
            _expectEmitTransferSingle(address(0), account, id, value);
            circles.mintAndUpdateTotalSupply(account, id, value, data, doAcceptanceCheck);

            // Verify final balance
            assertEq(_getBalance(account, id), value, "Balance mismatch after mint without acceptance check");
            // Verify total supply
            assertEq(
                circles.getTotalSupplyLastUpdatedDayValue(id), currentDay, "Expected total supply last updated day"
            );
            assertEq(circles.totalSupply(id), value, "Expected total supply mismatch");
        }

        // 5. Test total supply overflow
        //    Attempt to mint beyond maxBalance with the newly minted supply included.
        uint256 amountToOverflowTotalSupply = maxBalance - value + 1;
        address derivedAccount = address(uint160(uint256(keccak256(abi.encode(account)))));

        // If we minted something, revert with 0x80; otherwise revert with 0x82
        if (value != 0) {
            vm.expectRevert(
                abi.encodeWithSelector(
                    ICirclesCompactErrors.CirclesErrorAddressUintArgs.selector, derivedAccount, id, 0x80
                )
            );
        } else {
            vm.expectRevert(
                abi.encodeWithSelector(
                    ICirclesCompactErrors.CirclesErrorAddressUintArgs.selector, derivedAccount, id, 0x82
                )
            );
        }
        circles.mintAndUpdateTotalSupply(derivedAccount, id, amountToOverflowTotalSupply, data, doAcceptanceCheck);

        // 6. If supply < maxBalance, we try to mint again. Otherwise, test day skip for demurrage.
        if (value < maxBalance) {
            // Mint 1 more token to check total supply increment
            circles.mintAndUpdateTotalSupply(derivedAccount, id, 1, data, doAcceptanceCheck);
            assertEq(circles.totalSupply(id), value + 1, "Final total supply mismatch after small mint");
            assertEq(_getBalance(derivedAccount, id), 1, "Balance mismatch in derivedAccount");
        } else {
            // If minted value was maxBalance, we skip a day to watch demurrage reduce the supply
            skip(1 days);
            uint256 demurragedSupply = circles.totalSupply(id);
            assertTrue(demurragedSupply < value, "Demurrage not applied as expected");

            // The contract still tracks the old last updated day
            assertEq(
                currentDay, circles.getTotalSupplyLastUpdatedDayValue(id), "Last updated day mismatch after time skip"
            );

            // Update the local currentDay
            currentDay = circles.day(block.timestamp);
            assertFalse(
                currentDay == circles.getTotalSupplyLastUpdatedDayValue(id),
                "Total supply lastUpdatedDay shouldn't have changed"
            );

            // Mint again up to maxBalance - demurragedSupply to restore it to `value`
            circles.mintAndUpdateTotalSupply(derivedAccount, id, maxBalance - demurragedSupply, data, doAcceptanceCheck);

            // Final supply after demurrage recovers
            assertEq(circles.totalSupply(id), value, "Expected total supply mismatch after demurrage recovery");
            assertEq(
                currentDay,
                circles.getTotalSupplyLastUpdatedDayValue(id),
                "Expected last updated day mismatch after mint"
            );
            assertEq(
                _getBalance(derivedAccount, id),
                maxBalance - demurragedSupply,
                "Derived account balance mismatch after demurrage recovery"
            );
        }
    }

    // -------------------------------------------------------------------------
    // Test internal `_burnAndUpdateTotalSupply` function
    // -------------------------------------------------------------------------

    /**
     * @notice Tests the `_burnAndUpdateTotalSupply` function in Circles by:
     *         1) Minting tokens to `from` so there is a balance to burn.
     *         2) Checking for edge cases like burning more than the user’s balance,
     *            burning when the total supply is discounted, and overall supply updates.
     * @param account The address from which tokens are burned.
     * @param id The token ID for burning.
     * @param value The number of tokens to attempt burning.
     */
    function testBurnAndUpdateTotalSupply(address account, uint256 id, uint256 value) public {
        // 1. We cannot burn from address(0). This will fail logically in an actual contract scenario.
        if (account == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidSender.selector, address(0)));
            circles.burnAndUpdateTotalSupply(account, id, value);
            return;
        }

        // 2. If value > maxBalance, clamp it for consistent testing.
        if (value > maxBalance) {
            value = maxBalance;
        }

        // 3. Before burning, we need `account` to hold tokens. Mint some to `account`.
        //    Test insufficient balance by randomly minting less than needed.
        bool insufficient = (uint256(keccak256(abi.encodePacked(account, block.timestamp))) & 1) == 1;
        // if insufficient, minted < value
        uint256 minted = insufficient ? value / 2 : value;
        // Mint up to `minted` (unless minted=0, no effect)
        if (minted > 0) {
            // We do not test acceptance checks here because we are focusing on burning logic.
            circles.mintAndUpdateTotalSupply(account, id, minted, "", false);
        }

        // 4. If insufficient => expect revert on burn.
        if (insufficient && value > 0) {
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InsufficientBalance.selector, account, minted, value, id)
            );
            circles.burnAndUpdateTotalSupply(account, id, value);
            return;
        }

        // 5. Test discount scenario: if minted value is large, skip a day so it might demurrage.
        //    Test discount randomly.
        bool discount = (uint256(keccak256(abi.encodePacked(account))) & 1) == 1;

        if (discount && value > 0) {
            // Skip one day to trigger demurrage
            skip(1 days);
            currentDay = circles.day(block.timestamp);

            // distinguish balance and discount
            (uint256 balance, uint256 discountCost) = _getBalanceOnDay(account, id);

            // test insufficient revert trying to burn value (includes discount)
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InsufficientBalance.selector, account, balance, value, id)
            );
            circles.burnAndUpdateTotalSupply(account, id, value);

            // test happy path burning valid balance (excludes discount)
            _expectEmitDiscountEvents(account, id, discountCost); // discount
            _expectEmitTransferSingle(account, address(0), id, balance); // burned balance
            circles.burnAndUpdateTotalSupply(account, id, balance);
        } else {
            _expectEmitTransferSingle(account, address(0), id, value);
            circles.burnAndUpdateTotalSupply(account, id, value);
        }

        // 6. Check final user balance and total supply are reduced
        assertEq(_getBalance(account, id), 0, "User balance after burn mismatch");
        assertEq(circles.totalSupply(id), 0, "Total supply after burn mismatch");
        assertEq(circles.getTotalSupplyLastUpdatedDayValue(id), currentDay, "Expected last updated day mismatch");

        // 7. Case, when total supply is less than balances is hard to reproduce, let's cheat to reach the branch
        address derivedAccount = address(uint160(uint256(keccak256(abi.encode(account)))));
        // leave the space to mint extra 1
        if (value == maxBalance) value = maxBalance - 1;
        if (value != 0) circles.mintAndUpdateTotalSupply(derivedAccount, id, value, "", false);

        // Force the discounted balance in storage to exceed totalSupply, triggering revert
        bytes32 idSlot = keccak256(abi.encodePacked(id, uint256(17)));
        bytes32 derivedAccountSlot = keccak256(abi.encodePacked(uint256(uint160(derivedAccount)), idSlot));
        uint256 discountedBalance = (uint256(currentDay) << 192) + value + 1;
        vm.store(address(circles), derivedAccountSlot, bytes32(discountedBalance));

        vm.expectRevert(abi.encodeWithSelector(ICirclesCompactErrors.CirclesErrorNoArgs.selector, 0x84));
        circles.burnAndUpdateTotalSupply(derivedAccount, id, value + 1);
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    /**
     * @notice Retrieves the ERC1155 balance for a particular `avatar` and `id`.
     * @dev Used internally by test cases to confirm mint/burn results.
     * @param avatar The address whose balance is being queried.
     * @param id The token ID for which we want the balance.
     * @return The current attoCircles balance for `avatar`.
     */
    function _getBalance(address avatar, uint256 id) internal view returns (uint256) {
        return circles.balanceOf(avatar, id);
    }

    /**
     * @notice Returns the demurraged balance and discount cost for the current day
     *         from the `balanceOfOnDay` function, purely for debugging or advanced checks.
     * @dev Not currently used in these tests, but left as a reference for expanded coverage.
     * @param avatar The address whose demurraged balance is queried.
     * @param id The token ID for the query.
     * @return balance The demurraged balance of `avatar` for `id`.
     * @return discountCost The discount cost subtracted due to demurrage.
     */
    function _getBalanceOnDay(address avatar, uint256 id)
        internal
        view
        returns (uint256 balance, uint256 discountCost)
    {
        (balance, discountCost) = circles.balanceOfOnDay(avatar, id, circles.day(block.timestamp));
    }

    /**
     * @notice Helper function to expect a `TransferSingle` event in Foundry tests.
     * @dev Expects the event with `operator = address(this)`.
     * @param from The account transferring the token (or `address(0)` if mint).
     * @param to The account receiving the token.
     * @param id The token ID being transferred.
     * @param amount The amount of tokens transferred.
     */
    function _expectEmitTransferSingle(address from, address to, uint256 id, uint256 amount) internal {
        _expectEmitTransferSingle(address(this), from, to, id, amount);
    }

    /**
     * @notice Helper function to expect a `TransferSingle` event in Foundry tests,
     *         allowing a custom operator value.
     * @param operator The address that initiates the transfer.
     * @param from The account transferring the token (or `address(0)` if mint).
     * @param to The account receiving the token.
     * @param id The token ID being transferred.
     * @param amount The amount of tokens transferred.
     */
    function _expectEmitTransferSingle(address operator, address from, address to, uint256 id, uint256 amount)
        internal
    {
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(operator, from, to, id, amount);
    }

    /**
     * @notice Helper function to expect and verify `TransferSingle` and `DiscountCost` events,
     *         commonly used when demurrage is subtracted.
     * @param from The account that pays the discount (or initiates the burn).
     * @param id The token ID subject to discount cost.
     * @param discountCost The cost incurred by demurrage.
     */
    function _expectEmitDiscountEvents(address from, uint256 id, uint256 discountCost) internal {
        _expectEmitTransferSingle(from, address(0), id, discountCost);
        _expectEmitDiscount(from, id, discountCost);
    }

    /**
     * @notice Extended version of `_expectEmitDiscountEvents` allowing a custom operator value.
     * @param operator The address initiating the discount or transfer.
     * @param from The account paying discount or from which tokens are burned.
     * @param id The token ID subject to discount cost.
     * @param discountCost The cost incurred by demurrage.
     */
    function _expectEmitDiscountEvents(address operator, address from, uint256 id, uint256 discountCost) internal {
        _expectEmitTransferSingle(operator, from, address(0), id, discountCost);
        _expectEmitDiscount(from, id, discountCost);
    }

    /**
     * @notice Helper to expect a `DiscountCost` event from the `IDiscountedBalances` interface.
     * @dev Used in tests that trigger demurrage-based cost calculations.
     * @param from The account paying the discount cost.
     * @param id The token ID whose discount cost is being emitted.
     * @param discountCost The discount cost amount.
     */
    function _expectEmitDiscount(address from, uint256 id, uint256 discountCost) internal {
        vm.expectEmit(true, true, false, true);
        emit IDiscountedBalances.DiscountCost(from, id, discountCost);
    }
}
