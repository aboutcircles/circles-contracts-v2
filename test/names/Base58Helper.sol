// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "forge-std/console.sol";

/**
 * Helper contract to do the base58 decoding in solidity unit tests;
 * this should only be used for tests, in production this conversion to bytes
 * should be done off-chain with a proper library.
 */
contract Base58Decode {
    function base58Decode(string memory source) public view returns (bytes memory) {
        bytes memory bSource = bytes(source);
        uint256 base = 58;
        uint256 result = 0;
        uint256 multi = 1;

        // Mapping of base58 characters to their integer values
        uint8[58] memory base58Map = [
            0x31,
            0x32,
            0x33,
            0x34,
            0x35,
            0x36,
            0x37,
            0x38,
            0x39,
            0x41,
            0x42,
            0x43,
            0x44,
            0x45,
            0x46,
            0x47,
            0x48,
            0x4A,
            0x4B,
            0x4C,
            0x4D,
            0x4E,
            0x50,
            0x51,
            0x52,
            0x53,
            0x54,
            0x55,
            0x56,
            0x57,
            0x58,
            0x59,
            0x5A,
            0x61,
            0x62,
            0x63,
            0x64,
            0x65,
            0x66,
            0x67,
            0x68,
            0x69,
            0x6A,
            0x6B,
            0x6D,
            0x6E,
            0x6F,
            0x70,
            0x71,
            0x72,
            0x73,
            0x74,
            0x75,
            0x76,
            0x77,
            0x78,
            0x79,
            0x7A
        ];

        // Adjust to ignore the "Qm" prefix if it exists and length is 34 bytes
        uint256 startIndex = 0;
        if (bSource.length == 46 && bSource[0] == 0x51 && bSource[1] == 0x6D) {
            // 'Q' == 0x51 and 'm' == 0x6D
            startIndex = 2;
        } else if (bSource.length != 44) {
            revert("Invalid CIDv0 length for IPFS decoding.");
        }

        console.log("startIndex:", startIndex);
        console.log("CIDv0 inside length:", bSource.length);

        // for (uint256 i = startIndex; i < bSource.length; i++) {
        //     uint256 value = indexOf(uint8(bSource[i]), base58Map);
        //     result += value * multi;
        //     if (i )
        //     multi *= base;
        //     console.log("index:", i - startIndex + 1);
        //     console.log("charater:", uint8(bSource[i]), "value:", value);
        //     console.log("result:", result, "multi:", multi);
        // }

        uint256 j = 0;
        for (uint256 i = bSource.length; i > startIndex; i--) {
            uint256 value = indexOf(uint8(bSource[i - 1]), base58Map);
            result += value * multi;
            if (i > startIndex + 1) {
                // skip the last iteration to avoid overflow
                // 58^44 > 2^256 - 1
                multi *= base;
                console.log("iteration:", j++);
            } else {
                console.log("last iteration");
            }
            console.log("index:", bSource.length - i + 1);
            console.log("charater:", uint8(bSource[i - 1]), "value:", value);
            console.log("result:", result, "multi:", multi);
        }

        return toBytes(result);
    }

    function indexOf(uint8 char, uint8[58] memory map) private pure returns (uint256) {
        for (uint256 i = 0; i < map.length; i++) {
            if (map[i] == char) {
                return i;
            }
        }
        revert("Character not in base58 map.");
    }

    function toBytes(uint256 x) private pure returns (bytes memory b) {
        b = new bytes(32);
        assembly {
            mstore(add(b, 32), x)
        }
    }
}
