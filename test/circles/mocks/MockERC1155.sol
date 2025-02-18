// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

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

    // The functions to test safeTransferFrom, safeBatchTransferFrom, balanceOf, balanceOfBatch,
    // setApprovalForAll, isApprovedForAll, and uri() are inherited from the parent contracts.
    // Only setURI is implemented here.

    /**
     * @notice Changes the metadata URI used by this ERC1155 contract.
     * @dev This function modifies the internal `_uri` state variable in the inherited contract.
     * @param _newuri The new metadata URI to be set.
     */
    function setURI(string memory _newuri) public {
        _setURI(_newuri);
    }
}
