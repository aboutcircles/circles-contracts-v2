// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {console2, Test} from "forge-std/Test.sol";
import {IERC1155Errors} from "@openzeppelin/contracts/interfaces/draft-IERC6093.sol";
import {TimeCirclesSetup} from "test/setup/TimeCirclesSetup.sol";
import {IERC1155} from "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import {IDiscountedBalances} from "test/circles/mocks/MockDiscountedBalances.sol";
import {
    MockERC1155,
    MockERC1155ReceiverOk,
    MockERC1155ReceiverRevert,
    MockERC1155ReceiverWrongReturn,
    MockERC1155ReceiverNoReasonRevert
} from "test/circles/mocks/MockERC1155.sol";

contract ERC1155Test is Test, TimeCirclesSetup, IERC1155Errors {
    MockERC1155 public erc1155;

    // Represents Demurrage.MAX_VALUE in MockDiscountedBalances
    uint256 internal maxBalance;

    // Mock receivers for acceptance checks
    MockERC1155ReceiverOk internal receiverOk;
    MockERC1155ReceiverRevert internal receiverRevert;
    MockERC1155ReceiverWrongReturn internal receiverWrongReturn;
    MockERC1155ReceiverNoReasonRevert internal receiverNoReasonRevert;

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
            (uint256 fromBalance, uint256 discountCost) =
                erc1155.balanceOfOnDay(from, ids[0], erc1155.day(block.timestamp));
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
            if (to != from) assertEq(_getCurrentBalance(from, ids[0]), 0);
            if (to != address(0)) assertEq(_getCurrentBalance(to, ids[0]), values[0]);
        } else {
            // Skip discount check, works same as above
            // length = 0 || length > 1 => TransferBatch event
            _expectEmitTransferBatch(from, to, ids, values);

            // Now actually do the update
            erc1155.update(from, to, ids, values);
            // check balances update
            if (to != address(0)) {
                for (uint256 i; i < ids.length;) {
                    if (to != from) assertEq(_getCurrentBalance(from, ids[i]), 0);
                    assertEq(_getCurrentBalance(to, ids[i]), values[i]);
                    unchecked {
                        ++i;
                    }
                }
            }
        }
    }

    // -------------------------------------------------------------------------
    // Internal helpers
    // -------------------------------------------------------------------------

    function _getCurrentBalance(address avatar, uint256 id) internal view returns (uint256 currentBalance) {
        (currentBalance,) = erc1155.balanceOfOnDay(avatar, id, erc1155.day(block.timestamp));
    }

    /// @dev should emit IERC1155.TransferSingle
    function _expectEmitTransferSingle(address from, address to, uint256 id, uint256 amount) internal {
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferSingle(address(this), from, to, id, amount);
    }

    /// @dev should emit IERC1155.TransferBatch
    function _expectEmitTransferBatch(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
    {
        vm.expectEmit(true, true, true, true);
        emit IERC1155.TransferBatch(address(this), from, to, ids, values);
    }

    /// @dev should emit IERC1155.TransferSingle and DiscountCost events
    function _expectEmitDiscountEvents(address from, uint256 id, uint256 discountCost) internal {
        _expectEmitTransferSingle(from, address(0), id, discountCost);
        vm.expectEmit(true, true, false, true);
        emit IDiscountedBalances.DiscountCost(from, id, discountCost);
    }
}
