// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../../src/hub/Hub.sol";

contract MockHub is Hub {
    uint256 private constant INVITATION_COST = 100 * 1e18;

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
    function setSiblings(
        address _migration,
        INameRegistry _nameRegistry,
        IERC20Lift _liftERC20,
        address _standardTreasury
    ) external {
        migration = _migration;
        nameRegistry = INameRegistry(_nameRegistry);
        liftERC20 = IERC20Lift(_liftERC20);
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

    // Mock migration function to bypass onlyMigration modifier
    function mockMigrate(address _owner, address[] calldata _avatars, uint256[] calldata _amounts) external {
        if (avatars[_owner] == address(0)) {
            revert CirclesAvatarMustBeRegistered(_owner, 1);
        }
        if (_avatars.length != _amounts.length) {
            revert CirclesArraysLengthMismatch(_avatars.length, _amounts.length, 0);
        }

        uint256 cost = INVITATION_COST * _ensureAvatarsRegistered(_avatars);

        if (block.timestamp > invitationOnlyTime && cost > 0) {
            if (!isHuman(_owner)) {
                revert CirclesHubMustBeHuman(_owner, 4);
            }
            _burnAndUpdateTotalSupply(_owner, toTokenId(_owner), cost);
        }

        for (uint256 i = 0; i < _avatars.length; i++) {
            _mintAndUpdateTotalSupply(_owner, toTokenId(_avatars[i]), _amounts[i], "");
        }
    }

    // Getter for invitationOnlyTime
    function getInvitationOnlyTime() external view returns (uint256) {
        return invitationOnlyTime;
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
