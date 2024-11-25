// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

interface IUpgradeableRenounceableProxy {
    function implementation() external view returns (address);
    function upgradeToAndCall(address _newImplementation, bytes memory _data) external;
    function renounceUpgradeability() external;
}

contract UpgradeableRenounceableProxy is ERC1967Proxy {
    // Errors

    error BlockReceive();

    /// The implementation interacts with the native functionality of the proxy
    error ProxyNative();

    // Constants

    /// @dev Initial proxy admin.
    address internal immutable ADMIN_INIT;

    // Constructor

    constructor(address _implementation, bytes memory _data) ERC1967Proxy(_implementation, _data) {
        // set the admin to the deployer
        ERC1967Utils.changeAdmin(msg.sender);
        // set the admin as immutable
        ADMIN_INIT = msg.sender;
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
        if (msg.sender == ADMIN_INIT && msg.sender == ERC1967Utils.getAdmin()) {
            _dispatchAdmin();
        } else {
            super._fallback();
        }
    }

    /// @dev Overriding to add a check admin and implementation slots are not rewritten
    function _delegate(address implementation) internal virtual override {
        address proxyAdmin = ERC1967Utils.getAdmin();
        assembly {
            //
            function assertValuesEqualOrRevertProxyNativeError(prevValue, currValue) {
                switch eq(prevValue, currValue)
                case 0 {
                    // ProxyNative
                    mstore(0, 0x73afa62800000000000000000000000000000000000000000000000000000000)
                    revert(0, 0x20)
                }
            }

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
                // ERC1967Utils.IMPLEMENTATION_SLOT
                let postImplementation := sload(0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc)
                assertValuesEqualOrRevertProxyNativeError(implementation, postImplementation)
                // ERC1967Utils.ADMIN_SLOT
                let postAdmin := sload(0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103)
                assertValuesEqualOrRevertProxyNativeError(proxyAdmin, postAdmin)
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
