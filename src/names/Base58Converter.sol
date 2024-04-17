// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

contract Base58Converter {
    // Constants

    string internal constant ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz";

    uint256 internal constant IPFS_CIDV0_LENGTH = 46;

    uint256 internal constant ALPHABET_LENGTH = 58;

    // Internal functions

    function toBase58(uint256 _data) internal pure returns (string memory) {
        bytes memory b58 = new bytes(64); // More than enough length
        uint256 i = 0;
        while (_data > 0 || i == 0) {
            uint256 mod = _data % ALPHABET_LENGTH;
            b58[i++] = bytes(ALPHABET)[mod];
            _data = _data / ALPHABET_LENGTH;
        }
        // Reverse the string since the encoding works backwards
        return string(_reverse(b58, i));
    }

    function toBase58WithPadding(uint256 _data) internal pure returns (string memory) {
        bytes memory b58 = new bytes(IPFS_CIDV0_LENGTH); // Fixed length for CIDv0
        uint256 i = 0;
        while (_data > 0 || i == 0) {
            uint256 mod = _data % ALPHABET_LENGTH;
            b58[i++] = bytes(ALPHABET)[mod];
            _data /= ALPHABET_LENGTH;
        }
        while (i < IPFS_CIDV0_LENGTH) {
            // Ensure the output is exactly 46 characters
            b58[i++] = bytes(ALPHABET)[0]; // '1' in base58 represents the value 0
        }
        return string(_reverse(b58, i));
    }

    function _reverse(bytes memory _b, uint256 _len) internal pure returns (bytes memory) {
        bytes memory reversed = new bytes(_len);
        for (uint256 i = 0; i < _len; i++) {
            reversed[i] = _b[_len - 1 - i];
        }
        return reversed;
    }
}
