// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {console2, Test} from "forge-std/Test.sol";
import {IERC1155Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {ICirclesCompactErrors} from "src/errors/Errors.sol";
import {TimeCirclesSetup} from "test/setup/TimeCirclesSetup.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IDiscountedBalances} from "test/circles/mocks/MockDiscountedBalances.sol";
import {
    MockERC1155,
    MockERC1155ReceiverOk,
    MockERC1155ReceiverRevert,
    MockERC1155ReceiverWrongReturn,
    MockERC1155ReceiverNoReasonRevert,
    MockReentrantReceiver
} from "test/circles/mocks/MockERC1155.sol";

contract ERC1155Test is Test, TimeCirclesSetup, IERC1155Errors, ICirclesCompactErrors {
    MockERC1155 public erc1155;

    // Represents Demurrage.MAX_VALUE in MockDiscountedBalances
    uint256 internal maxBalance;

    // Mock receivers for acceptance checks
    MockERC1155ReceiverOk internal receiverOk;
    MockERC1155ReceiverRevert internal receiverRevert;
    MockERC1155ReceiverWrongReturn internal receiverWrongReturn;
    MockERC1155ReceiverNoReasonRevert internal receiverNoReasonRevert;
    MockReentrantReceiver internal receiverReentrant;

    function setUp() public {
        // set time in 2021 (from TimeCirclesSetup)
        startTime();

        erc1155 = new MockERC1155("circles", INFLATION_DAY_ZERO);
        maxBalance = erc1155.maxBalance();

        // Deploy mock receivers
        receiverOk = new MockERC1155ReceiverOk();
        receiverRevert = new MockERC1155ReceiverRevert();
        receiverWrongReturn = new MockERC1155ReceiverWrongReturn();
        receiverNoReasonRevert = new MockERC1155ReceiverNoReasonRevert();
        receiverReentrant = new MockReentrantReceiver(erc1155);
    }

    // -------------------------------------------------------------------------
    // Test internal `_asSingletonArrays` function
    // -------------------------------------------------------------------------
    function testAsSingletonArrays(uint256 element1, uint256 element2) public {
        (uint256[] memory array1, uint256[] memory array2) = erc1155.asSingletonArrays(element1, element2);
        assertEq(array1.length, 1);
        assertEq(array2.length, 1);
        assertEq(array1[0], element1);
        assertEq(array2[0], element2);
    }

    // -------------------------------------------------------------------------
    // Test internal `_acceptanceCheck` function
    // -------------------------------------------------------------------------
    // The scenarios to cover:
    //
    // 1) to == address(0)          -> no acceptance check is performed
    // 2) ids.length == 0           -> calls _doSafeBatchTransferAcceptanceCheck with empty arrays
    // 3) ids.length == 1           -> calls _doSafeTransferAcceptanceCheck
    // 4) ids.length > 1            -> calls _doSafeBatchTransferAcceptanceCheck
    //
    // In each scenario, we can test:
    //    - success case (receiver returns correct magic value)
    //    - revert case (receiver reverts or returns wrong value)
    // -------------------------------------------------------------------------
    function testAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public {
        // ---------------------------------------------------------------------
        // 1) to == address(0)
        // ---------------------------------------------------------------------
        if (to == address(0)) {
            // Should simply do nothing (no revert, no acceptance check).
            erc1155.acceptanceCheck(from, to, ids, values, data);
        } else if (ids.length == 0) {
            // ---------------------------------------------------------------------
            // 2) ids.length == 0
            // ---------------------------------------------------------------------

            values = new uint256[](0);
            // Should call _doSafeBatchTransferAcceptanceCheck on the receiver
            // with empty arrays. Our "Ok" receiver returns the correct magic
            // value. So it should pass without reverting.
            erc1155.acceptanceCheck(from, address(receiverOk), ids, values, data);

            // Try with a receiver that reverts:
            vm.expectRevert("No thanks");
            erc1155.acceptanceCheck(from, address(receiverRevert), ids, values, data);

            // Try with a receiver that returns the wrong value:
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverWrongReturn))
            );
            erc1155.acceptanceCheck(from, address(receiverWrongReturn), ids, values, data);

            // The fallback in `receiverNoReasonRevert` reverts without a reason,
            // leading to reason.length == 0. This triggers `ERC1155InvalidReceiver` revert.
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverNoReasonRevert))
            );
            erc1155.acceptanceCheck(from, address(receiverNoReasonRevert), ids, values, data);
        } else if (ids.length == 1) {
            // ---------------------------------------------------------------------
            // 3) ids.length == 1 -> _doSafeTransferAcceptanceCheck
            // ---------------------------------------------------------------------

            values = new uint256[](1);
            values[0] = 888;

            // OK receiver
            erc1155.acceptanceCheck(from, address(receiverOk), ids, values, data);

            // Reverting receiver
            vm.expectRevert("No thanks");
            erc1155.acceptanceCheck(from, address(receiverRevert), ids, values, data);

            // Wrong return receiver
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverWrongReturn))
            );
            erc1155.acceptanceCheck(from, address(receiverWrongReturn), ids, values, data);

            // The fallback in `receiverNoReasonRevert` reverts without a reason,
            // leading to reason.length == 0. This triggers `ERC1155InvalidReceiver` revert.
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverNoReasonRevert))
            );
            erc1155.acceptanceCheck(from, address(receiverNoReasonRevert), ids, values, data);
        } else if (ids.length > 1) {
            // ---------------------------------------------------------------------
            // 4) ids.length > 1 (e.g. 2) -> _doSafeBatchTransferAcceptanceCheck
            // ---------------------------------------------------------------------

            values = new uint256[](ids.length);
            for (uint256 i; i < ids.length;) {
                values[i] = i;
                unchecked {
                    ++i;
                }
            }

            // OK receiver
            erc1155.acceptanceCheck(from, address(receiverOk), ids, values, data);

            // Reverting receiver
            vm.expectRevert("No thanks");
            erc1155.acceptanceCheck(from, address(receiverRevert), ids, values, data);

            // Wrong return receiver
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverWrongReturn))
            );
            erc1155.acceptanceCheck(from, address(receiverWrongReturn), ids, values, data);

            // The fallback in `receiverNoReasonRevert` reverts without a reason,
            // leading to reason.length == 0. This triggers `ERC1155InvalidReceiver` revert.
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverNoReasonRevert))
            );
            erc1155.acceptanceCheck(from, address(receiverNoReasonRevert), ids, values, data);
        }
    }

    // -------------------------------------------------------------------------
    // Test internal `_mint` function
    // -------------------------------------------------------------------------
    /**
     * @notice Tests `_mint` logic via fuzzy inputs.
     *         Covers revert paths, acceptance checks, events, and final balances.
     *
     * @param to    The recipient of the minted tokens.
     * @param id    The token ID being minted.
     * @param value The amount to mint.
     * @param data  Extra data for acceptance checks.
     * @param _doAcceptanceCheck Whether to perform an ERC1155Receiver check.
     */
    function testMint(address to, uint256 id, uint256 value, bytes memory data, bool _doAcceptanceCheck) public {
        // 1. If `to == address(0)`, must revert.
        if (to == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(0)));
            erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            return;
        }

        // 2. If `value > maxBalance` to mint, must revert
        if (value > maxBalance) {
            vm.expectRevert(
                abi.encodeWithSelector(ICirclesCompactErrors.CirclesErrorAddressUintArgs.selector, to, id, 0x82)
            );
            erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            return;
        }

        // 3. If `_doAcceptanceCheck == true` test `to` as a contract and EOA,
        //    we check for revert/wrong return cases.
        //    We'll do separate logic for each known mock receiver.
        if (_doAcceptanceCheck) {
            // EOA
            if (to.code.length == 0) {
                _expectEmitTransferSingle(address(0), to, id, value);
                erc1155.mint(to, id, value, data, _doAcceptanceCheck);
                assertEq(_getBalance(to, id), value, "Balance mismatch after mint");
            }

            // Test all mocks
            {
                to = address(receiverOk);
                // Should succeed
                // Expect a TransferSingle event from address(0) to `to`
                _expectEmitTransferSingle(address(0), to, id, value);
                // Then do the mint
                erc1155.mint(to, id, value, data, _doAcceptanceCheck);

                // Verify final balance
                assertEq(_getBalance(to, id), value, "Balance should match minted amount");
            }
            {
                to = address(receiverRevert);
                // Should revert with "No thanks"
                vm.expectRevert("No thanks");
                erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            }
            {
                to = address(receiverWrongReturn);
                // Should revert with ERC1155InvalidReceiver
                vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, to));
                erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            }
            {
                to = address(receiverNoReasonRevert);
                // Should revert with reason.length == 0 => ERC1155InvalidReceiver
                vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, to));
                erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            }
        } else {
            // 4. If `_doAcceptanceCheck == false`,
            //    no acceptance check. We only expect a TransferSingle event.
            _expectEmitTransferSingle(address(0), to, id, value);

            erc1155.mint(to, id, value, data, _doAcceptanceCheck);
            // Check final balance
            assertEq(_getBalance(to, id), value, "Balance mismatch after mint");
        }
    }

    // -------------------------------------------------------------------------
    // Test internal `_burn` function
    // -------------------------------------------------------------------------
    /**
     * @notice Tests `_burn` with various fuzzed parameters.
     *
     * @param from  The address whose tokens will be burned.
     * @param id    The token ID to burn.
     * @param value The amount of tokens to burn.
     */
    function testBurn(address from, uint256 id, uint256 value) public {
        // 1) If `from == address(0)`, must revert with ERC1155InvalidSender.
        if (from == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidSender.selector, address(0)));
            erc1155.burn(from, id, value);
            return;
        }
        // polish fuzzing, as mint test shows impossible to mint > maxBalance
        if (value > maxBalance) value = maxBalance;

        // 2) Before burning, we need `from` to hold tokens. Mint some to `from`.
        //    Possibly test insufficient balance by randomly minting less than needed.
        //    For demonstration, do a 50/50 chance:
        bool insufficient = (uint256(keccak256(abi.encodePacked(from, block.timestamp))) & 1) == 1;

        uint256 minted = insufficient ? value / 2 : value; // if insufficient, minted < value
        // Mint up to `minted` (unless minted=0, no effect)
        if (minted > 0) {
            erc1155.mint(from, id, minted, "", false);
        }

        // 3) If insufficient => expect revert on burn.
        if (insufficient && value > 0) {
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InsufficientBalance.selector, from, minted, value, id)
            );
            erc1155.burn(from, id, value);
            return;
        }

        // 4) Do a 50/50 chance: to test discount cost
        bool discount = (uint256(keccak256(abi.encodePacked(from))) & 1) == 1;
        if (discount && value > 0) {
            // skip some time to ensure demurrage might have accrued for `from`.
            skip(1 days);
            // distinguish balance and discount
            (uint256 balance, uint256 discountCost) = _getBalanceOnDay(from, id);
            // test insufficient revert trying to burn value (includes discount)
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InsufficientBalance.selector, from, balance, value, id)
            );
            erc1155.burn(from, id, value);
            // test happy path burning valid balance (excludes discount)
            _expectEmitDiscountEvents(from, id, discountCost); // discount
            _expectEmitTransferSingle(from, address(0), id, balance); // burned balance
            erc1155.burn(from, id, balance);
        } else {
            _expectEmitTransferSingle(from, address(0), id, value);
            erc1155.burn(from, id, value);
        }
        // check balance get burned
        assertEq(_getBalance(from, id), 0, "Incorrect final balance after burn");
    }

    // -------------------------------------------------------------------------
    // Test internal `_update` function
    // -------------------------------------------------------------------------
    /**
     * @notice A single fuzz test covering many branches of `_update`.
     * @dev Because `_update` can act as mint (from=0), burn (to=0), or transfer (neither=0),
     *      we handle each scenario with conditional logic. We also test discount cost,
     *      batch vs. single, etc.
     *
     * @param from The address from which tokens are transferred (or zero for mint).
     * @param to The address to which tokens are transferred (or zero for burn).
     * @param values The array of amounts corresponding to each ID.
     */
    function testUpdate(address from, address to, uint256[] memory values) public {
        uint256[] memory ids = new uint256[](values.length);
        uint256[] memory excessIds = new uint256[](values.length + 1);

        for (uint256 i; i < values.length;) {
            // exclude testing mint >maxBalance (is tested on _mint flow)
            if (values[i] > maxBalance) values[i] = maxBalance;
            ids[i] = i + 1;
            excessIds[i] = i + 1;
            unchecked {
                ++i;
            }
        }
        // -----------------------------------------------------------
        // 1) Array length mismatch => Must revert
        // -----------------------------------------------------------
        {
            excessIds[excessIds.length - 1] = excessIds.length;
            vm.expectRevert(
                abi.encodeWithSelector(
                    IERC1155Errors.ERC1155InvalidArrayLength.selector, excessIds.length, values.length
                )
            );
            erc1155.update(from, to, excessIds, values);
        }
        // -----------------------------------------------------------
        // 2) If from != 0, ensure it has enough balance to cover transfers
        //    or test the "insufficient balance" revert path.
        // -----------------------------------------------------------
        if (from != address(0)) {
            // Mint enough of each token ID to `from`.
            // We'll decide how much to mint vs. how much we try to transfer.
            // We want to test insufficient balance, we can do so randomly:
            //   e.g., sometimes mint exactly half the needed amounts.
            // For simplicity, let's just do a 50/50 chance.
            bool insufficient = (uint256(keccak256(abi.encodePacked(from, block.timestamp))) & 1) == 1;
            bool nonZeroValueExist = false;

            for (uint256 i = 0; i < ids.length; i++) {
                // If we plan an insufficient scenario,
                // mint half the needed value. Otherwise, mint full.
                uint256 amountToMint = insufficient
                    ? values[i] / 2 // guaranteed to be less
                    : values[i];

                if (amountToMint > 0) {
                    // We'll do a direct `_mint` wrapper from MockERC1155
                    // (i.e., from=0 => "to=from" => mint).
                    erc1155.mint(from, ids[i], amountToMint, "", false);
                    nonZeroValueExist = true;
                }
            }

            if (insufficient && nonZeroValueExist) {
                // We expect a revert on the first token that tries to transfer more
                // than balance (minted).
                // `_update` => revert ERC1155InsufficientBalance(from, fromBalance, value, id)
                // TODO: upgrade forge-std in order to have vm.expectPartialRevert(IERC1155Errors.ERC1155InsufficientBalance.selector);
                vm.expectRevert();
                erc1155.update(from, to, ids, values);
                return;
            }
        }

        // -----------------------------------------------------------
        // 3) Single-element => expect TransferSingle event
        //    Multi-element => expect TransferBatch event
        // -----------------------------------------------------------
        if (ids.length == 1) {
            // We can also check if discount cost might be > 0.
            // We'll do that by skipping time if from != 0 to trigger demurrage.
            if (from != address(0) && values[0] > 1) {
                skip(1 days);
            }

            // If from != 0 and discount cost > 0, we'd also expect a TransferSingle
            // event to 0 + DiscountCost event.
            // We'll just expect them if the discount cost is > 0, which we can check
            // using a function from the mock:
            (uint256 fromBalance, uint256 discountCost) = _getBalanceOnDay(from, ids[0]);
            // update transferable value accordingly
            values[0] = fromBalance;
            // There's no direct way to forcibly set discount cost > 0 aside from time skipping,
            // so let's do a naive check:
            if (from != address(0) && discountCost > 0) {
                _expectEmitDiscountEvents(from, ids[0], discountCost);
            }
            // Expect TransferSingle
            _expectEmitTransferSingle(from, to, ids[0], fromBalance);

            erc1155.update(from, to, ids, values);
            // check balances update
            if (to != from) assertEq(_getBalance(from, ids[0]), 0);
            if (to != address(0)) assertEq(_getBalance(to, ids[0]), values[0]);
        } else {
            // Skip discount check, works same as above
            // length = 0 || length > 1 => TransferBatch event
            _expectEmitTransferBatch(from, to, ids, values);

            // Now actually do the update
            erc1155.update(from, to, ids, values);
            // check balances update
            if (to != address(0)) {
                for (uint256 i; i < ids.length;) {
                    if (to != from) assertEq(_getBalance(from, ids[i]), 0);
                    assertEq(_getBalance(to, ids[i]), values[i]);
                    unchecked {
                        ++i;
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Test internal `_updateWithAcceptanceCheck` function
    // -------------------------------------------------------------------------
    /// @notice As _updateWithAcceptanceCheck implementation only calls internal _update and _acceptanceCheck functions,
    ///      which are fully tested we are going to test 3 scenarios:
    ///      - the call doesn't make any state changes emerging from _update due to _acceptanceCheck reverts (all branches)
    ///      - the reentrancy case, demonstrates that pure usage of a function leads to reentrancy and must be properly covered
    ///        (check-effect-interaction pattern) at external function implementation, which is using _updateWithAcceptanceCheck
    ///      - one positive path
    function testUpdateWithAcceptanceCheck(uint256[] memory values) public {
        // - from = address(0) => "mint"
        address from = address(0);
        // generate ids and polish values
        uint256[] memory ids = new uint256[](values.length);
        for (uint256 i; i < values.length;) {
            // exclude testing mint > maxBalance / 2
            if (values[i] > maxBalance / 2) values[i] = maxBalance / 2;
            ids[i] = i + 1;
            unchecked {
                ++i;
            }
        }
        address to;
        // SCENARIO - revert:
        // - to = reverting receiver
        address[] memory revertingReceivers = new address[](3);
        revertingReceivers[0] = address(receiverRevert);
        revertingReceivers[1] = address(receiverWrongReturn);
        revertingReceivers[2] = address(receiverNoReasonRevert);
        for (uint256 k; k < 3; k++) {
            to = revertingReceivers[k];
            // Expect revert from acceptance check
            if (k == 0) vm.expectRevert("No thanks");
            else vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, to));
            // Attempt the updateWithAcceptanceCheck
            erc1155.updateWithAcceptanceCheck(from, to, ids, values, "");
            // Confirm that "to" ended up with 0 balances for theses ids
            // Because the entire tx was reverted, the mint didn't stick.
            for (uint256 i; i < ids.length;) {
                assertEq(_getBalance(to, ids[i]), 0, "Balance should remain 0 after revert");
                unchecked {
                    ++i;
                }
            }
        }

        // SCENARIO - reentrancy:
        // - to = reentrant receiver
        // The reentrant receiver is coded to call `updateWithAcceptanceCheck`
        to = address(receiverReentrant);
        // makes reenter, because there's no reentrancy guard at this level,
        // we expect update and event emit twice
        if (ids.length == 1) {
            _expectEmitTransferSingle(from, to, ids[0], values[0]);
            // second event has reentrant receiver as operator
            _expectEmitTransferSingle(to, from, to, ids[0], values[0]);
        } else {
            _expectEmitTransferBatch(from, to, ids, values);
            // second event has reentrant receiver as operator
            _expectEmitTransferBatch(to, from, to, ids, values);
        }
        bytes memory data = abi.encode(erc1155.updateWithAcceptanceCheck.selector);
        erc1155.updateWithAcceptanceCheck(from, to, ids, values, data);
        // check balances should be twice values
        for (uint256 i; i < ids.length;) {
            assertEq(_getBalance(to, ids[i]), values[i] * 2, "Balance should be updated twice");
            unchecked {
                ++i;
            }
        }

        // SCENARIO - happy path:
        // - to = receiver ok
        to = address(receiverOk);
        if (ids.length == 1) _expectEmitTransferSingle(from, to, ids[0], values[0]);
        else _expectEmitTransferBatch(from, to, ids, values);
        erc1155.updateWithAcceptanceCheck(from, to, ids, values, "");
        // check balances should equal values
        for (uint256 i; i < ids.length;) {
            assertEq(_getBalance(to, ids[i]), values[i], "Balance should be updated");
            unchecked {
                ++i;
            }
        }
    }

    // -------------------------------------------------------------------------
    // Test external `safeTransferFrom` function
    // -------------------------------------------------------------------------
    /**
     * @notice Fuzz test for `safeTransferFrom` to ensure all revert paths
     *         and successful flows are covered.
     *
     * @param from   The address sending tokens.
     * @param to     The address receiving tokens.
     * @param id     The token type ID to transfer.
     * @param value  The amount of tokens to transfer.
     */
    function testSafeTransferFrom(address from, address to, uint256 id, uint256 value) public {
        // 1) If `from != msg.sender` and no approval, revert with `ERC1155MissingApprovalForAll`.
        // We'll handle that scenario by default if `from != address(this)`.
        if (from != address(this)) {
            // Expect revert
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155MissingApprovalForAll.selector, address(this), from)
            );
            erc1155.safeTransferFrom(from, to, id, value, "");

            // make from approve address(this)
            vm.prank(from);
            erc1155.setApprovalForAll(address(this), true);
        }

        // 2) If `from == address(0)`, must revert with `ERC1155InvalidSender`.
        if (from == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidSender.selector, address(0)));
            erc1155.safeTransferFrom(from, to, id, value, "");
            return;
        }

        // 3) If `to == address(0)`, must revert with `ERC1155InvalidReceiver`.
        if (to == address(0)) {
            // We don't even need to mint to `from` because it should revert
            // before checking balances.
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(0)));
            erc1155.safeTransferFrom(from, to, id, value, "");
            return;
        }

        bool random = (uint256(keccak256(abi.encodePacked(from, value))) & 1) == 1;
        // 4) Make sure `from` has enough tokens. If `value > 0`, we must mint >= `value`.
        // We'll mint exactly `value` to `from`, unless value=0 => no need
        if (value > 0) {
            // 5) before minting we can test revert with `ERC1155InsufficientBalance`.
            // make random 50/50 calls operator from/address(this)
            if (random) vm.prank(from);
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InsufficientBalance.selector, from, 0, value, id)
            );
            erc1155.safeTransferFrom(from, to, id, value, "");

            // polish fuzzing
            if (value > maxBalance) value = maxBalance;
            erc1155.mint(from, id, value, "", false);
        }

        // 6) Next, we test acceptance logic. If `to` is a contract that reverts or returns a wrong
        //    selector or tries to reenter, we expect a revert from `_doSafeTransferAcceptanceCheck`.
        if (to.code.length != 0 && to != address(receiverOk)) {
            // rewrite to with implementation of all known revert branches
            to = address(receiverRevert);
            vm.expectRevert("No thanks");
            erc1155.safeTransferFrom(from, to, id, value, "");
            to = address(receiverWrongReturn);
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, to));
            erc1155.safeTransferFrom(from, to, id, value, "");
            to = address(receiverNoReasonRevert);
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, to));
            erc1155.safeTransferFrom(from, to, id, value, "");
            // rewrite to for reentrancy
            to = address(receiverReentrant);
            bytes memory data = abi.encode(erc1155.safeTransferFrom.selector);
            // Expect revert: receiver is not approved
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155MissingApprovalForAll.selector, to, from));
            erc1155.safeTransferFrom(from, to, id, value, data);
        } else {
            // 7) Everything is valid for transfer execution.
            // Make snapshot
            uint256 snapshot = vm.snapshot(); // TODO: update forge-std to use vm.snapshotState()
            // transfer
            // Finally, do the call
            if (random) {
                _expectEmitTransferSingle(from, from, to, id, value);
                vm.prank(from);
            } else {
                _expectEmitTransferSingle(from, to, id, value);
            }
            erc1155.safeTransferFrom(from, to, id, value, "");
            // check balance updates
            assertEq(_getBalance(from, id), 0, "Incorrect final balance for `from`");
            assertEq(_getBalance(to, id), value, "Incorrect final balance for `to`");
            // Revert to snapshot
            vm.revertTo(snapshot); // TODO: update forge-std to use vm.revertToStateAndDelete(snapshot)
            // Skip a day for discount to occur
            skip(1 days);
            // 8) Everything is valid for transfer with discount execution.
            (uint256 balance, uint256 discount) = _getBalanceOnDay(from, id);
            if (random) {
                if (discount > 0) _expectEmitDiscountEvents(from, from, id, discount);
                _expectEmitTransferSingle(from, from, to, id, balance);
                vm.prank(from);
            } else {
                if (discount > 0) _expectEmitDiscountEvents(from, id, discount);
                _expectEmitTransferSingle(from, to, id, balance);
            }
            erc1155.safeTransferFrom(from, to, id, balance, "");
            assertEq(_getBalance(from, id), 0, "Incorrect final balance for `from`");
            assertEq(_getBalance(to, id), balance, "Incorrect final balance for `to`");
        }
    }

    // -------------------------------------------------------------------------
    // Test external `safeBatchTransferFrom` function
    // -------------------------------------------------------------------------
    /**
     * @notice Fuzz test for `safeBatchTransferFrom` to ensure all revert paths
     *         and successful flows are covered.
     *
     * @param from    The address sending tokens.
     * @param to      The address receiving tokens.
     * @param ids     The array of token type IDs to transfer.
     * @param values  The array of token amounts corresponding to `ids`.
     */
    function testSafeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory values)
        public
    {
        // 1) If from != address(this) and no approval => revert with `ERC1155MissingApprovalForAll`.
        if (from != address(this)) {
            // We expect a revert due to missing approval
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155MissingApprovalForAll.selector, address(this), from)
            );
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");

            // Now grant approval so we can continue
            vm.prank(from);
            erc1155.setApprovalForAll(address(this), true);
        }

        // 2) If from == address(0), must revert with `ERC1155InvalidSender`.
        if (from == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidSender.selector, address(0)));
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");
            return;
        }

        // 3) If to == address(0), must revert with `ERC1155InvalidReceiver`.
        if (to == address(0)) {
            vm.expectRevert(abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(0)));
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");
            return;
        }

        // 4) If ids.length != values.length => revert with ERC1155InvalidArrayLength
        if (ids.length != values.length) {
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidArrayLength.selector, ids.length, values.length)
            );
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");
        }

        // generate ids and polish values to avoid length mismatch and mint > maxBalance by dup ids
        ids = new uint256[](values.length);
        uint256 nonZeroId;
        for (uint256 i; i < values.length;) {
            // exclude testing mint > maxBalance
            if (values[i] > maxBalance) values[i] = maxBalance;
            if (values[i] > 0 && nonZeroId == 0) nonZeroId = i + 1;
            ids[i] = i + 1;
            unchecked {
                ++i;
            }
        }

        // do a quick random approach
        bool random = (uint256(keccak256(abi.encodePacked(from, values.length))) & 1) == 1;

        // 5) Try transferring before minting to trigger `ERC1155InsufficientBalance`
        // if any non-zero value is required.
        // We'll attempt the batch transfer first and expect a revert if there's any non-zero entry.
        if (nonZeroId > 0) {
            if (random) vm.prank(from);
            vm.expectRevert(
                abi.encodeWithSelector(
                    IERC1155Errors.ERC1155InsufficientBalance.selector,
                    from,
                    0,
                    values[nonZeroId - 1],
                    ids[nonZeroId - 1]
                )
            );
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");
        }

        // Now ensure each token is minted up to required amounts (clamped by maxBalance).
        for (uint256 i; i < ids.length;) {
            if (values[i] > 0) {
                erc1155.mint(from, ids[i], values[i], "", false);
            }
            unchecked {
                ++i;
            }
        }

        // 6) If `to` is a contract with revert/wrongReturn logic,
        //    we test acceptance check reverts for each and reentrancy.
        if (to.code.length != 0 && to != address(receiverOk)) {
            // Revert with reason
            vm.expectRevert("No thanks");
            erc1155.safeBatchTransferFrom(from, address(receiverRevert), ids, values, "");
            // Wrong-return version
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverWrongReturn))
            );
            erc1155.safeBatchTransferFrom(from, address(receiverWrongReturn), ids, values, "");
            // No-reason revert
            vm.expectRevert(
                abi.encodeWithSelector(IERC1155Errors.ERC1155InvalidReceiver.selector, address(receiverNoReasonRevert))
            );
            erc1155.safeBatchTransferFrom(from, address(receiverNoReasonRevert), ids, values, "");

            // Reentrant scenario
            bytes memory data = abi.encode(erc1155.safeBatchTransferFrom.selector);
            vm.expectRevert(
                abi.encodeWithSelector(
                    IERC1155Errors.ERC1155MissingApprovalForAll.selector, address(receiverReentrant), from
                )
            );
            erc1155.safeBatchTransferFrom(from, address(receiverReentrant), ids, values, data);
        } else {
            // 7) Everything is valid => we expect a `TransferBatch` event.
            //    We might have discount cost if time has passed. Let's do a 2-step approach:
            //    - Step 1: Transfer with no time skip
            //    - Step 2: Revert to snapshot, skip time, then transfer again to see discount events

            // Step 1: Transfer now
            uint256 snapshot = vm.snapshot(); // TODO: update forge-std
            if (random) {
                if (values.length == 1) _expectEmitTransferSingle(from, from, to, ids[0], values[0]);
                else _expectEmitTransferBatch(from, from, to, ids, values);
                vm.prank(from);
            } else {
                if (values.length == 1) _expectEmitTransferSingle(from, to, ids[0], values[0]);
                else _expectEmitTransferBatch(from, to, ids, values);
            }
            erc1155.safeBatchTransferFrom(from, to, ids, values, "");

            // Check final balances for step 1
            for (uint256 i; i < ids.length;) {
                // from should be 0 and to should be `values[i]`
                assertEq(_getBalance(from, ids[i]), 0, "Incorrect final balance for `from` after first transfer");
                assertEq(_getBalance(to, ids[i]), values[i], "Incorrect final balance for `to` after first transfer");
                unchecked {
                    ++i;
                }
            }

            // Revert to snapshot
            vm.revertTo(snapshot); // TODO: update forge-std

            // 8) Skip time so discount cost can accumulate.
            skip(1 days);

            // We'll gather new `values` because after demurrage, the "effective" balances were adjusted.
            uint256[] memory newValues = new uint256[](ids.length);
            for (uint256 i; i < ids.length;) {
                (uint256 balance, uint256 discount) = _getBalanceOnDay(from, ids[i]);
                newValues[i] = balance;
                if (random && discount > 0) {
                    // operator if from
                    _expectEmitDiscountEvents(from, from, ids[i], discount);
                } else if (discount > 0) {
                    _expectEmitDiscountEvents(from, ids[i], discount);
                }
                unchecked {
                    ++i;
                }
            }

            // Finally we expect a TransferBatch from => to
            if (random) {
                if (values.length == 1) _expectEmitTransferSingle(from, from, to, ids[0], newValues[0]);
                else _expectEmitTransferBatch(from, from, to, ids, newValues);
                vm.prank(from);
            } else {
                if (values.length == 1) _expectEmitTransferSingle(from, to, ids[0], newValues[0]);
                else _expectEmitTransferBatch(from, to, ids, newValues);
            }
            erc1155.safeBatchTransferFrom(from, to, ids, newValues, "");

            // Check final balances for step 2
            for (uint256 i; i < ids.length;) {
                // now from should be 0, and to should be newValues[i].
                assertEq(_getBalance(from, ids[i]), 0, "Incorrect final balance for `from` after second transfer");
                assertEq(
                    _getBalance(to, ids[i]), newValues[i], "Incorrect final balance for `to` after second transfer"
                );
                unchecked {
                    ++i;
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    function _getBalance(address avatar, uint256 id) internal view returns (uint256) {
        return erc1155.balanceOf(avatar, id);
    }

    function _getBalanceOnDay(address avatar, uint256 id)
        internal
        view
        returns (uint256 balance, uint256 discountCost)
    {
        (balance, discountCost) = erc1155.balanceOfOnDay(avatar, id, erc1155.day(block.timestamp));
    }

    /// @dev should emit IERC1155.TransferSingle
    function _expectEmitTransferSingle(address from, address to, uint256 id, uint256 amount) internal {
        _expectEmitTransferSingle(address(this), from, to, id, amount);
    }

    function _expectEmitTransferSingle(address operator, address from, address to, uint256 id, uint256 amount)
        internal
    {
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(operator, from, to, id, amount);
    }

    /// @dev should emit IERC1155.TransferBatch
    function _expectEmitTransferBatch(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
    {
        _expectEmitTransferBatch(address(this), from, to, ids, values);
    }

    function _expectEmitTransferBatch(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values
    ) internal {
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferBatch(operator, from, to, ids, values);
    }

    /// @dev should emit IERC1155.TransferSingle and DiscountCost events
    function _expectEmitDiscountEvents(address from, uint256 id, uint256 discountCost) internal {
        _expectEmitTransferSingle(from, address(0), id, discountCost);
        _expectEmitDiscount(from, id, discountCost);
    }

    function _expectEmitDiscountEvents(address operator, address from, uint256 id, uint256 discountCost) internal {
        _expectEmitTransferSingle(operator, from, address(0), id, discountCost);
        _expectEmitDiscount(from, id, discountCost);
    }

    function _expectEmitDiscount(address from, uint256 id, uint256 discountCost) internal {
        vm.expectEmit(true, true, false, true);
        emit IDiscountedBalances.DiscountCost(from, id, discountCost);
    }
}
