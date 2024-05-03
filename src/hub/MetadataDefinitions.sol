// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

contract MetadataDefinitions {
    // Type declarations

    struct Metadata {
        bytes32 metadataType;
        bytes metadata;
        bytes erc1155UserData;
    }

    struct GroupMintMetadata {
        address group;
    }

    // note: Redemption does not require Metadata

    // Constants

    bytes32 internal constant METADATATYPE_GROUPMINT = keccak256("CIRCLESv2:RESERVED_DATA:CirclesGroupMint");
    bytes32 internal constant METADATATYPE_GROUPREDEEM = keccak256("CIRCLESv2:RESERVED_DATA:CirclesGroupRedeem");
}
