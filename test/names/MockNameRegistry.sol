// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../../src/names/NameRegistry.sol";

contract MockNameRegistry is NameRegistry {
    constructor() NameRegistry(IHubV2(address(1))) {}

    // External functions

    function registerShortNameNoChecks() external {
        _registerShortName();
    }

    function registerShortNameWithNonceNoChecks(uint256 _nonce) external {
        _registerShortNameWithNonce(_nonce);
    }

    function registerCustomNameNoChecks(address _avatar, string calldata _name) external {
        if (bytes(_name).length == 0) {
            // if name is left empty, it will default to default name "Circles-<base58(short)Name>"
            return;
        }
        if (!isValidName(_name)) {
            revert CirclesNamesInvalidName(_avatar, _name, 0);
        }
        customNames[_avatar] = _name;
    }

    function registerCustomSymbolNoChecks(address _avatar, string calldata _symbol) external {
        if (bytes(_symbol).length == 0) {
            // if symbol is left empty, it will default to default symbol "CRC"
            return;
        }
        if (!isValidSymbol(_symbol)) {
            revert CirclesNamesInvalidName(_avatar, _symbol, 1);
        }
        customSymbols[_avatar] = _symbol;
    }

    function setCidV0DigestNoChecks(address _avatar, bytes32 _dicV0Digest) external {
        _setCidV0Digest(_avatar, _dicV0Digest);
    }
}
