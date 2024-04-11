// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/lift/ERC20Lift.sol";

contract MockERC20Lift is ERC20Lift {
    // Constructor

    constructor(address _mastercopyERC20Demurrage, address _mastercopyERC20Inflation)
        ERC20Lift(IHubV2(address(1)), INameRegistry(address(1)), _mastercopyERC20Demurrage, _mastercopyERC20Inflation)
    {}

    // External functions

    function setSiblings(IHubV2 _hub, INameRegistry _nameRegistry) external {
        hub = _hub;
        nameRegistry = _nameRegistry;
    }
}
