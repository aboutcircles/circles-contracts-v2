// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/hub/Hub.sol";
import "../../src/lift/IERC20Lift.sol";
import "../../src/migration/IHub.sol";
import "../../src/names/INameRegistry.sol";
import "../../src/names/NameRegistry.sol";
import "../../src/treasury/StandardVault.sol";
import "../../src/treasury/StandardTreasury.sol";
import "../../src/lift/DemurrageCircles.sol";
import "../../src/lift/InflationaryCircles.sol";
import "../lift/MockERC20Lift.sol";
import "./MockHub.sol";

contract MockDeployment {
    bool public IS_TEST = true;
    // State variables

    MockHub public hub;
    NameRegistry public nameRegistry;
    StandardTreasury public treasury;
    StandardVault public masterCopyVault;
    MockERC20Lift public erc20Lift;
    DemurrageCircles public mastercopyDemurrageCircles;
    InflationaryCircles public mastercopyInflationaryCircles;

    constructor(uint256 _inflationDayZero, uint256 _bootstrapTime) {
        // deploy mastercopies
        masterCopyVault = new StandardVault();
        mastercopyDemurrageCircles = new DemurrageCircles();
        mastercopyInflationaryCircles = new InflationaryCircles();

        // deploy mocks
        hub = new MockHub(_inflationDayZero, _bootstrapTime);
        erc20Lift = new MockERC20Lift(address(mastercopyDemurrageCircles), address(mastercopyInflationaryCircles));

        // the following only depend on knowing hub, so we can deploy with mocking
        nameRegistry = new NameRegistry(IHubV2(address(hub)));
        treasury = new StandardTreasury(IHubV2(address(hub)), address(masterCopyVault));

        // we don't care to set migration so leave that as 0x01
        hub.setSiblings(address(1), nameRegistry, erc20Lift, address(treasury));
        erc20Lift.setSiblings(IHubV2(address(hub)), nameRegistry);
    }
}
