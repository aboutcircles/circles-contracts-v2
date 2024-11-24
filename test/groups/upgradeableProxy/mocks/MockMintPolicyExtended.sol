// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.20;

import {MintPolicy, IMintPolicy} from "src/groups/BaseMintPolicy.sol";
import {Initializable} from "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import {ERC1967Utils} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Utils.sol";

interface IMockMintPolicyExtended is IMintPolicy {
    function setProxyImplementation(address newImplementation, bytes memory data) external;
    function changeWhitelistAdmin(address newWhitelistAdmin) external;
    function setWhitelisted(address minter, bool whitelist) external;
    function getWhitelistAdmin() external view returns (address);
    function isWhitelisted(address minter) external view returns (bool);
}

contract MockMintPolicyExtended is Initializable, MintPolicy {
    /// @custom:storage-location erc7201:circles.storage.MockMintPolicyExtended
    struct MockWhitelistStorage {
        address whitelistAdmin;
        mapping(address minter => bool) whitelisted;
    }

    // keccak256(abi.encode(uint256(keccak256("circles.storage.MockWhitelist")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant MockWhitelistStorageLocation =
        0xad8f981846947e2d39c57b5b7bd1e5ee93f80ef26284ffb0224c576ef51a7c00;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address _admin, address[] calldata _initWhitelist) external initializer {
        _setWhitelistAdmin(_admin);

        for (uint256 i; i < _initWhitelist.length;) {
            _setWhitelisted(_initWhitelist[i], true);
            unchecked {
                ++i;
            }
        }
    }

    // Modifiers

    modifier onlyWhitelistAdmin() {
        require(msg.sender == _getWhitelistAdmin());
        _;
    }

    // External functions

    function beforeMintPolicy(
        address _minter,
        address, /*_group*/
        uint256[] calldata, /*_collateral*/
        uint256[] calldata, /*_amounts*/
        bytes calldata /*_data*/
    ) external virtual override returns (bool) {
        return _isWhitelisted(_minter);
    }

    function changeWhitelistAdmin(address newWhitelistAdmin) external onlyWhitelistAdmin {
        _setWhitelistAdmin(newWhitelistAdmin);
    }

    function setWhitelisted(address minter, bool whitelist) external onlyWhitelistAdmin {
        _setWhitelisted(minter, whitelist);
    }

    // Functions to bypass proxy admin functions

    function setProxyAdmin(address newAdmin) external onlyWhitelistAdmin {
        ERC1967Utils.changeAdmin(newAdmin);
    }

    function setProxyImplementation(address newImplementation, bytes memory data) external onlyWhitelistAdmin {
        ERC1967Utils.upgradeToAndCall(newImplementation, data);
    }

    // View functions

    function getWhitelistAdmin() external view returns (address) {
        return _getWhitelistAdmin();
    }

    function isWhitelisted(address minter) external view returns (bool) {
        return _isWhitelisted(minter);
    }

    // Private functions

    function _getMockWhitelistStorage() private pure returns (MockWhitelistStorage storage $) {
        assembly {
            $.slot := MockWhitelistStorageLocation
        }
    }

    function _getWhitelistAdmin() private view returns (address) {
        MockWhitelistStorage storage $ = _getMockWhitelistStorage();
        return $.whitelistAdmin;
    }

    function _setWhitelistAdmin(address admin) private {
        MockWhitelistStorage storage $ = _getMockWhitelistStorage();
        $.whitelistAdmin = admin;
    }

    function _isWhitelisted(address minter) private view returns (bool) {
        MockWhitelistStorage storage $ = _getMockWhitelistStorage();
        return $.whitelisted[minter];
    }

    function _setWhitelisted(address minter, bool whitelist) private {
        MockWhitelistStorage storage $ = _getMockWhitelistStorage();
        $.whitelisted[minter] = whitelist;
    }
}
