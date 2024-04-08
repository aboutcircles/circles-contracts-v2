// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/groups/BaseMintPolicy.sol";
import "../setup/HumanRegistration.sol";
import "../setup/TimeCirclesSetup.sol";
import "../hub/MockDeployment.sol";
import "../hub/MockHub.sol";

contract GroupSetup is TimeCirclesSetup, HumanRegistration {
    // State variables

    MockDeployment public mockDeployment;
    MockHub public hub;
    address public mintPolicy;
    
    // Constructor

    constructor() HumanRegistration(40) {}

    // Setup

    function groupSetup() public {
        // Set time in 2021
        startTime();

        // Mock deployment
        mockDeployment = new MockDeployment(INFLATION_DAY_ZERO, 365 days);
        hub = mockDeployment.hub();
        mintPolicy = address(new MintPolicy());

        // register 35 humans

        for (uint256 i = 0; i < 35; i++) {
            vm.prank(addresses[i]);
            hub.registerHumanUnrestricted();
        }

        // skip time and mint
        skipTime(14 days);
        for (uint256 i = 0; i < 35; i++) {
            vm.prank(addresses[i]);
            hub.personalMintWithoutV1Check();
        }
    }
}