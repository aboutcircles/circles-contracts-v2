// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/migration/Migration.sol";

contract MockMigration is Migration {
    // Constructor

    constructor(IHubV1 _hubV1, IHubV2 _hubV2, uint256 _inflationDayZero) Migration(_hubV1, _hubV2, _inflationDayZero) {}

    // External functions

    function setHubV2(IHubV2 _hubV2) external {
        hubV2 = _hubV2;
    }
}
