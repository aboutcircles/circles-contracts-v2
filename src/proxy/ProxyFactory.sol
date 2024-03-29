// SPDX-License-Identifier: AGPL-3.0-only
// Taken from https://github.com/gnosis/safe-contracts
pragma solidity >=0.8.4;

import "./Proxy.sol";

/// @title Proxy Factory - Allows to create new proxy contact and
///        execute a message call to the new proxy within one transaction.
/// @author Stefan George - <stefan@gnosis.pm>
contract ProxyFactory {
    event ProxyCreation(Proxy proxy, address masterCopy);

    /// @dev Allows to create new proxy contact and
    ///      execute a message call to the new proxy within one transaction.
    /// @param masterCopy Address of master copy.
    /// @param data Payload for message call sent to new proxy contract.
    function _createProxy(address masterCopy, bytes memory data) internal returns (Proxy proxy) {
        proxy = new Proxy(masterCopy);
        if (data.length > 0) {
            // solhint-disable-next-line no-inline-assembly
            assembly {
                // solhint-disable-next-line max-line-length
                if eq(call(gas(), proxy, 0, add(data, 0x20), mload(data), 0, 0), 0) { revert(0, 0) }
            }
        }
        emit ProxyCreation(proxy, masterCopy);
    }
}
