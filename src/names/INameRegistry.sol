// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

interface INameRegistry {
    function setMetadataDigest(address avatar, bytes32 metadataDigest) external;
    function registerCustomName(address avatar, string calldata name) external;
    function registerCustomSymbol(address avatar, string calldata symbol) external;

    function name(address avatar) external view returns (string memory);
    function symbol(address avatar) external view returns (string memory);
    function getMetadataDigest(address _avatar) external view returns (bytes32);

    function isValidName(string calldata name) external pure returns (bool);
    function isValidSymbol(string calldata symbol) external pure returns (bool);
}
