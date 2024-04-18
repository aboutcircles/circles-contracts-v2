// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../../src/names/NameRegistry.sol";

contract MockNameRegistry is NameRegistry {
    constructor() NameRegistry(IHubV2(address(1))) {}
}
