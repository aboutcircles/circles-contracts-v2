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
    // string constant IPFS_CID_V0 = "ipfs://QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB";
    // using https://cid.ipfs.tech/#QmPK1s3pNYLi9ERiq3BDxKa4XosgWwFRQUydHUtz4YgpqB
    // this is the 32 bytes hash digest
    bytes32 constant SHA256_DIGEST = 0x0E7071C59DF3B9454D1D18A15270AA36D54F89606A576DC621757AFD44AD1D2E;

    // State variables

    MockNameRegistry mockNameRegistry;

    // Constructor

    constructor() HumanRegistration(4) {}

    // Setup

    function setUp() public {
        mockNameRegistry = new MockNameRegistry();
    }

    // Tests

    function testShortName() public {
        // without a short name registered, first get the long name
        string memory longName = mockNameRegistry.getShortOrLongName(addresses[0]);
        assertEq(longName, "Rings-3fNX29VBXc9WSxAT2dG3RYSfj6uX");

        // now register a short name
        vm.prank(addresses[0]);
        mockNameRegistry.registerShortNameNoChecks();

        // and get the short name
        string memory shortName = mockNameRegistry.getShortOrLongName(addresses[0]);
        assertEq(shortName, "Rings-Q6sQpEYS9Dg1");
    }

    function testMetadataDigest() public {
        mockNameRegistry.setMetadataDigestNoChecks(addresses[0], SHA256_DIGEST);
        bytes32 digest = mockNameRegistry.getMetadataDigest(addresses[0]);

        assertEq(digest, SHA256_DIGEST);
    }
}
