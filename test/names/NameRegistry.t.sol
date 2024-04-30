// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../setup/HumanRegistration.sol";
import "./MockNameRegistry.sol";
import "./base58Helper.sol";

contract NamesTest is Test, HumanRegistration, Base58Decode {
    // Constants

    // IPFS hash for Ubuntu 20.04, random CIDv0
    string constant IPFS_CID_V0 = "QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB";
    // using https://cid.ipfs.tech/#QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB
    // this is the 32 bytes hash digest
    bytes32 constant DECODED_UINT = 0x0E7071C59DF3B9454D1D18A15270AA36D54F89606A576DC621757AFD44AD1D2E;

    // State variables

    MockNameRegistry mockNameRegistry;

    bytes32 cidBytes;

    // Constructor

    constructor() HumanRegistration(4) {}

    // Setup

    function setUp() public {
        mockNameRegistry = new MockNameRegistry();
        // Convert CIDv0 to bytes32 (should be done off-chain in production)
        console.log("CIDv0 length", bytes(IPFS_CID_V0).length);
        cidBytes = convertCidV0ToBytes32(IPFS_CID_V0);
    }

    // Tests

    function testCidV0Digest() public {
        mockNameRegistry.setCidV0DigestNoChecks(addresses[0], cidBytes);
    }

    // Helper functions

    function convertCidV0ToBytes32(string memory _cidV0) internal view returns (bytes32) {
        bytes memory decodedBytes = base58Decode(_cidV0);
        console.log("CIDv0 length:", decodedBytes.length);
    }
}
