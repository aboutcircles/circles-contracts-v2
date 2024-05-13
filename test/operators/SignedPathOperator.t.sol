// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../../src/operators/SignedPathOperator.sol";
import "../hub/MockDeployment.sol";
import "../setup/TimeCirclesSetup.sol";
import "../setup/HumanRegistration.sol";
import "./TrustGraph.sol";

contract SignedPathOperatorTest is Test, TimeCirclesSetup, HumanRegistration, TrustGraph {
    // Constants

    uint96 expiry = type(uint96).max;

    // State variables

    SignedPathOperator public operator;
    MockHub public hub;
    MockDeployment public deployment;

    // Constructor

    constructor() HumanRegistration(20) {}

    // Setup

    function setUp() public {
        // set time to 10 december 2021
        startTime();

        // deploy all contracts and the signed path operator
        deployment = new MockDeployment(INFLATION_DAY_ZERO, 365 days);
        hub = deployment.hub();
        operator = new SignedPathOperator(IHubV2(address(hub)));

        // register 20 humans
        for (uint256 i = 0; i < N; i++) {
            vm.prank(addresses[i]);
            deployment.hub().registerHumanUnrestricted();
            assertEq(deployment.hub().isTrusted(addresses[i], addresses[i]), true);
        }
        // skip time to claim Circles
        skipTime(14 days + 1 minutes);
        for (uint256 i = 0; i < N; i++) {
            vm.prank(addresses[i]);
            hub.personalMintWithoutV1Check();
        }

        // diagram of the trust graph (all doubly connected)

        // 1---2---3       8---9
        // | \ | / |       | / |
        // 12  4---5---7---6---10
        // | / |   |       | \ |
        // 11--13  14      15--16
        // |       |       |   |
        // 20------17------18--19
        _setTrustGraph();
    }

    // Tests

    // Internal functions

    function _setTrustGraph() internal {
        _linearlyDoubleConnect20(L1);
        _linearlyDoubleConnect7(L2);
        _fullyConnect3(F1);
        _fullyConnect3(F2);
        _fullyConnect3(F3);
        _fullyConnect3(F4);
        _fullyConnect3(F5);
    }

    function _fullyConnect3(uint256[3] memory _list) internal {
        for (uint256 i = 0; i < _list.length; i++) {
            for (uint256 j = 0; j < _list.length; j++) {
                if (i != j) {
                    vm.prank(addresses[_list[i]]);
                    hub.trust(addresses[_list[j]], expiry);
                }
            }
        }
    }

    function _linearlySingleConnect(uint256[] memory _list) internal {
        for (uint256 i = 0; i < _list.length - 1; i++) {
            vm.prank(addresses[_list[i]]);
            hub.trust(addresses[_list[i + 1]], expiry);
        }
    }

    function _linearlyDoubleConnect20(uint256[20] memory _list) internal {
        for (uint256 i = 0; i < _list.length - 1; i++) {
            vm.prank(addresses[_list[i]]);
            hub.trust(addresses[_list[i + 1]], expiry);
            vm.prank(addresses[_list[i + 1]]);
            hub.trust(addresses[_list[i]], expiry);
        }
    }

    function _linearlyDoubleConnect7(uint256[7] memory _list) internal {
        for (uint256 i = 0; i < _list.length - 1; i++) {
            vm.prank(addresses[_list[i]]);
            hub.trust(addresses[_list[i + 1]], expiry);
            vm.prank(addresses[_list[i + 1]]);
            hub.trust(addresses[_list[i]], expiry);
        }
    }
}
