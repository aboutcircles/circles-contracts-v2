// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../setup/HumanRegistration.sol";
import "./MockNameRegistry.sol";

contract NamesTest is Test, HumanRegistration {
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
        assertEq(longName, "Circles-3fNX29VBXc9WSxAT2dG3RYSfj6uX");

        // now register a short name
        vm.prank(addresses[0]);
        mockNameRegistry.registerShortNameNoChecks();

        // and get the short name
        string memory shortName = mockNameRegistry.getShortOrLongName(addresses[0]);
        assertEq(shortName, "Circles-Q6sQpEYS9Dg1");

        // can't register a second time
        vm.expectRevert();
        vm.prank(addresses[0]);
        mockNameRegistry.registerShortNameWithNonceNoChecks(839892892);
    }

    function testShortNameWithNonce() public {
        vm.prank(addresses[0]);
        mockNameRegistry.registerShortNameWithNonceNoChecks(839892892);
        string memory shortName = mockNameRegistry.getShortOrLongName(addresses[0]);
        assertEq(shortName, "Circles-uNJGyf6sN6vY");
    }

    function testShortNameWithPadding() public {
        // 42 converts to "j" in base58
        assertEq(mockNameRegistry.toBase58(42), "j");

        // but as a short name it shold be padded to 12 characters
        mockNameRegistry.storeShortName(addresses[0], 42);
        string memory shortName = mockNameRegistry.getShortOrLongName(addresses[0]);
        assertEq(shortName, "Circles-11111111111j");
    }

    function testBase58Conversion() public {
        assertEq(mockNameRegistry.toBase58(0), "1");
        assertEq(mockNameRegistry.toBase58(mockNameRegistry.MAX_SHORT_NAME()), "zzzzzzzzzzzz");
        // longer names are not possible as tha calculation takes modulo MAX_SHORT_NAME + 1
        assertEq(mockNameRegistry.toBase58(mockNameRegistry.MAX_SHORT_NAME() + 1), "2111111111111");

        assertEq(mockNameRegistry.toBase58(845156846445168), "7bmqZRAo1");
        assertEq(mockNameRegistry.toBase58(912670482714768333), "37sj6xwGEtL");

        assertEq(mockNameRegistry.toBase58WithPadding(0), "111111111111");
        assertEq(mockNameRegistry.toBase58WithPadding(845156846445168), "1117bmqZRAo1");
    }

    function testCustomName() public {
        mockNameRegistry.registerCustomNameNoChecks(addresses[0], "Circles");
        assertEq(mockNameRegistry.customNames(addresses[0]), "Circles");
    }

    function testInvalidCustomNames() public {
        vm.expectRevert();
        mockNameRegistry.registerCustomNameNoChecks(addresses[0], "WeirdName=NotAllowed");
    }

    function testMetadataDigest() public {
        mockNameRegistry.setMetadataDigestNoChecks(addresses[0], SHA256_DIGEST);
        bytes32 digest = mockNameRegistry.getMetadataDigest(addresses[0]);

        assertEq(digest, SHA256_DIGEST);
    }
}
