// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

interface IUpgradeableRenounceableProxy {
    function implementation() external view returns (address);
    function upgradeToAndCall(address newImplementation, bytes memory data) external;
    function renounceUpgradeability() external;
}

contract UpgradeableRenounceableProxy is ERC1967Proxy {
    // Errors

    error BlockReceive();

    /// Triggered when the delegatecall modifies values, indicating a violation of proxy-native functionality.
    error ProxyNative();

    // Constructor

    constructor(address _implementation, bytes memory _data) ERC1967Proxy(_implementation, _data) {
        // set the admin to the deployer
        ERC1967Utils.changeAdmin(msg.sender);
    }

    /// @dev Handles proxy function calls: attempts to dispatch to a specific
    ///      function or delegates all calls to the implementation contract.
    function _fallback() internal virtual override {
        // staticcall implementation() returns the address
        if (msg.sig == IUpgradeableRenounceableProxy.implementation.selector) {
            bytes32 slot = ERC1967Utils.IMPLEMENTATION_SLOT;
            assembly {
                let implementation := sload(slot)
                mstore(0, shr(12, shl(12, implementation)))
                return(0, 0x20)
            }
        }
        // dispatch if caller is admin, otherwise delegate to the implementation
        if (msg.sender == ERC1967Utils.getAdmin()) {
            _dispatchAdmin();
        } else {
            _delegate(_implementation());
        }
    }

    /// @dev Overrides the function to add a check that prevents rewriting of admin and implementation slots.
    function _delegate(address implementation) internal virtual override {
        bytes32 adminSlot = ERC1967Utils.ADMIN_SLOT;
        bytes32 implementationSlot = ERC1967Utils.IMPLEMENTATION_SLOT;
        bytes32 errorProxyNative = ProxyNative.selector;
        assembly {
            // put the admin value on the stack before delegatecall (the implementation value has already been read and is on the stack)
            let originalAdminValue := sload(adminSlot)
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())
            switch result
            // delegatecall returns 0 on error.
            case 0 { revert(0, returndatasize()) }
            default {
                // read the values after the delegatecall
                let currentAdminValue := sload(adminSlot)
                let currentImplementationValue := sload(implementationSlot)
                // check that the values remain unchanged
                if iszero(
                    and(eq(originalAdminValue, currentAdminValue), eq(implementation, currentImplementationValue))
                ) {
                    // revert with ProxyNative error, as delegatecall has modified values (proxy-native functionality)
                    mstore(0, errorProxyNative)
                    revert(0, 0x04)
                }
                return(0, returndatasize())
            }
        }
    }

    /// @dev Upgrades to new implementation, renounces the ability to upgrade or moves to regular flow based on admin request.
    function _dispatchAdmin() private {
        if (msg.sig == IUpgradeableRenounceableProxy.upgradeToAndCall.selector) {
            // upgrades to new implementation
            (address newImplementation, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } else if (msg.sig == IUpgradeableRenounceableProxy.renounceUpgradeability.selector) {
            // renounces the ability to upgrade the contract, by setting the admin to 0x01.
            ERC1967Utils.changeAdmin(address(0x01));
        } else {
            _delegate(_implementation());
        }
    }

    // Fallback function

    receive() external payable {
        revert BlockReceive();
    }
}
