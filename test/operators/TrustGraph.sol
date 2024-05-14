// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../../src/hub/IHub.sol";

contract TrustGraph {
    // Constants

    // diagram of the trust graph (all doubly connected)

    // 1---2---3       8---9
    // | \ | / |       | / |
    // 12  4---5---7---6---10
    // | / |   |       | \ |
    // 11--13  14      15--16
    // |       |       |   |
    // 20------17------18--19

    // should be indexed from zero;

    // // contours
    // uint256[20] internal L1 = [1, 2, 3, 5, 7, 6, 8, 9, 10, 16, 19, 18, 17, 20, 11, 12];
    // uint256[7] internal L2 = [5, 7, 6, 15, 18, 17, 14];
    // // inside clusters
    // uint256[3] internal F1 = [1, 2, 4];
    // uint256[3] internal F2 = [4, 3, 5];
    // uint256[3] internal F3 = [11, 13, 4];
    // uint256[3] internal F4 = [10, 9, 6];
    // uint256[3] internal F5 = [6, 15, 16];

    // // define paths from Alice (11) to Bob (14)
    // uint256[4] internal P1 = [11, 4, 5, 14];
    // uint256[5] internal P2 = [11, 13, 4, 5, 14];

    // contours
    uint256[20] internal L1 = [0, 1, 2, 4, 6, 5, 7, 8, 9, 15, 18, 17, 16, 19, 10, 11];
    uint256[7] internal L2 = [4, 6, 5, 14, 17, 16, 13];
    // inside clusters
    uint256[3] internal F1 = [0, 1, 3];
    uint256[3] internal F2 = [3, 2, 4];
    uint256[3] internal F3 = [10, 12, 3];
    uint256[3] internal F4 = [9, 8, 5];
    uint256[3] internal F5 = [5, 14, 15];

    // define paths from Alice (11) to Bob (14)
    uint256[4] internal P1 = [10, 3, 4, 13];
    uint256[5] internal P2 = [10, 12, 3, 4, 13];
}
