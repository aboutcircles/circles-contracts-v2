// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "../../src/hub/Hub.sol";
import "../../src/lift/IERC20Lift.sol";
import "../../src/migration/IHub.sol";
import "../../src/names/INameRegistry.sol";
import "../../src/names/NameRegistry.sol";
import "../../src/treasury/standardVault.sol";
import "../../src/treasury/StandardTreasury.sol";
import "../../src/lift/DemurrageCircles.sol";
import "../../src/lift/InflationaryCircles.sol";
import "../lift/MockERC20Lift.sol";

contract MockHub is Hub {
    // Constructor

    constructor(uint256 _inflationDayZero, uint256 _bootstrapTime)
        Hub(
            IHubV1(address(1)),
            INameRegistry(address(1)),
            address(1),
            IERC20Lift(address(1)),
            address(1),
            _inflationDayZero,
            _bootstrapTime,
            ""
        )
    {}

    // External functions

    function setSiblings(address _migration, address _nameRegistry, address _liftERC20, address _standardTreasury)
        external
    {
        migration = _migration;
        nameRegistry = INameRegistry(_nameRegistry);
        liftERC20 = ERC20Lift(_liftERC20);
        standardTreasury = _standardTreasury;
    }

    function registerHumanUnrestricted() external {
        address human = msg.sender;

        // insert avatar into linked list; reverts if it already exists
        _insertAvatar(human);

        require(avatars[human] != address(0), "MockPathTransferHub: avatar not found");

        // set the last mint time to the current timestamp for invited human
        // and register the v1 Circles contract status as unregistered
        address v1CirclesStatus = address(0);
        MintTime storage mintTime = mintTimes[human];
        mintTime.mintV1Status = v1CirclesStatus;
        mintTime.lastMintTime = uint96(block.timestamp);

        // trust self indefinitely, cannot be altered later
        _trust(human, human, INDEFINITE_FUTURE);
    }

    function personalMintWithoutV1Check() external {
        require(isHuman(msg.sender), "MockPathTransferHub: not a human");
        require(avatars[msg.sender] != address(0), "MockPathTransferHub: avatar not found");
        address human = msg.sender;

        // skips checks in v1 mint for tests

        // mint Circles for the human
        _claimIssuance(human);
    }

    // Public functions

    function accessUnpackCoordinates(bytes calldata _packedData, uint256 _numberOfTriplets)
        public
        pure
        returns (uint16[] memory unpackedCoordinates_)
    {
        return super._unpackCoordinates(_packedData, _numberOfTriplets);
    }

    // Private functions

    function notMocked() private pure {
        assert(false);
    }
}

contract MockDeployment {
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
        hub.setSiblings(address(1), address(nameRegistry), address(erc20Lift), address(treasury));
        erc20Lift.setSiblings(IHubV2(address(hub)), INameRegistry(address(nameRegistry)));
    }
}
