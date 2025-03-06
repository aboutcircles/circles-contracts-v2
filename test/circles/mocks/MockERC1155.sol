// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {IERC1155Receiver} from "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import {MockDiscountedBalances} from "test/circles/mocks/MockDiscountedBalances.sol";
import {ERC1155} from "src/circles/ERC1155.sol";

/**
 * @title MockERC1155
 * @notice A simple mock implementation of the abstract ERC1155 contract. Inherits
 * both ERC1155 and MockDiscountedBalances for testing purposes.
 */
contract MockERC1155 is ERC1155, MockDiscountedBalances {
    /**
     * @notice Deploys the mock contract.
     * @dev Calls the parent ERC1155 constructor to set the URI, and
     *      calls MockDiscountedBalances constructor to set the inflationDayZero timestamp.
     * @param newuri The initial metadata URI.
     * @param _inflationDayZero The reference day (timestamp) from which inflation is calculated.
     */
    constructor(string memory newuri, uint256 _inflationDayZero)
        ERC1155(newuri)
        MockDiscountedBalances(_inflationDayZero)
    {}

    // -------------------------------------------------------------------------
    // Wrapped internal functions into external to enable testing
    // -------------------------------------------------------------------------

    /**
     * @notice Public wrapper to test the internal `_asSingletonArrays` function.
     * @dev Creates two arrays each with a single element, to mimic the internal logic in ERC1155.
     * @param element1 The element for the first singleton array.
     * @param element2 The element for the second singleton array.
     * @return array1 The singleton array containing `element1`.
     * @return array2 The singleton array containing `element2`.
     */
    function asSingletonArrays(uint256 element1, uint256 element2)
        public
        pure
        returns (uint256[] memory array1, uint256[] memory array2)
    {
        (array1, array2) = _asSingletonArrays(element1, element2);
    }

    /**
     * @notice Public wrapper to test the internal `_acceptanceCheck` function.
     * @dev This triggers `_doSafeTransferAcceptanceCheck` or `_doSafeBatchTransferAcceptanceCheck`
     *      on the receiving contract if `_to` is a contract.
     * @param _from The address sending the tokens.
     * @param _to The address receiving the tokens.
     * @param _ids An array of token IDs.
     * @param _values An array of token amounts corresponding to `_ids`.
     * @param _data Extra calldata to pass to the receiving contract.
     */
    function acceptanceCheck(
        address _from,
        address _to,
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes memory _data
    ) public {
        _acceptanceCheck(_from, _to, _ids, _values, _data);
    }

    /**
     * @notice Public wrapper to test the internal `_update` function.
     * @dev This function updates the balances by transferring/minting/burning
     *      depending on whether `from` or `to` is the zero address.
     * @param from The address losing tokens (or zero address for mint).
     * @param to The address gaining tokens (or zero address for burn).
     * @param ids An array of token IDs.
     * @param values An array of token amounts corresponding to `ids`.
     */
    function update(address from, address to, uint256[] memory ids, uint256[] memory values) public {
        _update(from, to, ids, values);
    }

    /**
     * @notice Public wrapper to test the internal `_updateWithAcceptanceCheck` function.
     * @dev Updates balances and also performs the ERC1155 receiver acceptance checks.
     * @param from The address losing tokens (or zero address for mint).
     * @param to The address gaining tokens (or zero address for burn).
     * @param ids An array of token IDs.
     * @param values An array of token amounts corresponding to `ids`.
     * @param data Additional data that gets forwarded to the receiver contract.
     */
    function updateWithAcceptanceCheck(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public {
        _updateWithAcceptanceCheck(from, to, ids, values, data);
    }

    /**
     * @notice Public wrapper to test the internal `_mint` function.
     * @dev Creates new tokens of a given ID and amount, and assigns them to an address.
     * @param to The address receiving the newly minted tokens.
     * @param id The token type ID to mint.
     * @param value The amount of tokens to mint.
     * @param data Additional data that gets forwarded to the receiver contract.
     * @param _doAcceptanceCheck Whether or not to perform ERC1155 receiver acceptance checks.
     */
    function mint(address to, uint256 id, uint256 value, bytes memory data, bool _doAcceptanceCheck) public {
        _mint(to, id, value, data, _doAcceptanceCheck);
    }

    /**
     * @notice Public wrapper to test the internal `_burn` function.
     * @dev Destroys tokens of a given ID and amount from the `from` address.
     * @param from The address from which tokens will be burned.
     * @param id The token type ID to burn.
     * @param value The amount of tokens to burn.
     */
    function burn(address from, uint256 id, uint256 value) public {
        _burn(from, id, value);
    }

    /**
     * @notice Changes the metadata URI used by this ERC1155 contract.
     * @dev This function modifies the internal `_uri` state variable in the inherited contract.
     * @param _newuri The new metadata URI to be set.
     */
    function setURI(string memory _newuri) public {
        _setURI(_newuri);
    }
}

/*//////////////////////////////////////////////////////////////////////////
                            MOCK RECEIVERS
//////////////////////////////////////////////////////////////////////////*/

/**
 * @dev Receiver that always returns the correct magic value for both single and batch transfers.
 */
contract MockERC1155ReceiverOk is IERC1155Receiver {
    function onERC1155Received(
        address, /* operator */
        address, /* from */
        uint256, /* id */
        uint256, /* value */
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address, /* operator */
        address, /* from */
        uint256[] calldata, /* ids */
        uint256[] calldata, /* values */
        bytes calldata /* data */
    ) external pure override returns (bytes4) {
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}

/**
 * @dev Receiver that always reverts (for single and batch) to mimic rejection.
 */
contract MockERC1155ReceiverRevert is IERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        revert("No thanks");
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        revert("No thanks");
    }

    function supportsInterface(bytes4) external pure returns (bool) {
        return true;
    }
}

/**
 * @dev Receiver that returns a wrong magic value (instead of the standard acceptance magic).
 */
contract MockERC1155ReceiverWrongReturn is IERC1155Receiver {
    function onERC1155Received(address, address, uint256, uint256, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return 0xDEADDEAD; // Wrong return
    }

    function onERC1155BatchReceived(address, address, uint256[] calldata, uint256[] calldata, bytes calldata)
        external
        pure
        override
        returns (bytes4)
    {
        return 0xDEADDEAD; // Wrong return
    }

    function supportsInterface(bytes4) external pure returns (bool) {
        return true;
    }
}

/**
 * @dev Receiver that *always reverts without a message* in the fallback,
 *      causing the revert reason to be an empty bytes array.
 */
contract MockERC1155ReceiverNoReasonRevert {
    // No onERC1155Received / onERC1155BatchReceived => not a valid receiver

    fallback() external {
        // Revert with no message => reason.length == 0
        revert();
    }
}

/**
 * @dev This receiver attempts a single reentrant call in `onERC1155Received`.
 */
contract MockReentrantReceiver is IERC1155Receiver {
    MockERC1155 public erc1155;
    bool private hasReentered; // to avoid infinite loops

    constructor(MockERC1155 _erc1155) {
        erc1155 = _erc1155;
    }

    /**
     * @notice Called by ERC1155 contract after a single token transfer/mint.
     *         We'll attempt a reentrant call back into `updateWithAcceptanceCheck` or `safeTransferFrom` exactly once.
     */
    function onERC1155Received(address, address from, uint256 id, uint256 value, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        if (!hasReentered) {
            hasReentered = true;
            bytes4 selector = abi.decode(data, (bytes4));
            // Reenter!
            if (selector == erc1155.updateWithAcceptanceCheck.selector) {
                // Attempt a second mint from=0, same ID/value.
                // This call is reentrant because we're still in the middle
                // of `updateWithAcceptanceCheck` from the first call.
                uint256[] memory ids = new uint256[](1);
                ids[0] = id;
                uint256[] memory values = new uint256[](1);
                values[0] = value;
                erc1155.updateWithAcceptanceCheck(address(0), address(this), ids, values, data);
            } else if (selector == erc1155.safeTransferFrom.selector) {
                erc1155.safeTransferFrom(from, address(this), id, value, data);
            }
        }

        return this.onERC1155Received.selector;
    }

    /**
     * @notice Called by ERC1155 contract after a batch transfer.
     *         We'll attempt a reentrant call back into `updateWithAcceptanceCheck` or `safeBatchTransferFrom` exactly once.
     */
    function onERC1155BatchReceived(
        address,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        if (!hasReentered) {
            hasReentered = true;
            bytes4 selector = abi.decode(data, (bytes4));
            // Reenter!
            if (selector == erc1155.updateWithAcceptanceCheck.selector) {
                erc1155.updateWithAcceptanceCheck(address(0), address(this), ids, values, data);
            } else if (selector == erc1155.safeBatchTransferFrom.selector) {
                erc1155.safeBatchTransferFrom(from, address(this), ids, values, data);
            }
        }
        return this.onERC1155BatchReceived.selector;
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId;
    }
}
