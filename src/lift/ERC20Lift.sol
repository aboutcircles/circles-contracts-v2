// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "@openzeppelin/contracts/utils/Create2.sol";
import "../errors/Errors.sol";
import "../lift/IERC20Lift.sol";
import "../hub/IHub.sol";
import "../names/INameRegistry.sol";
import "../proxy/ProxyFactory.sol";

contract ERC20Lift is ProxyFactory, IERC20Lift, ICirclesErrors, ICirclesCompactErrors {
    // Constants

    bytes4 public constant ERC20_WRAPPER_SETUP_CALLPREFIX = bytes4(keccak256("setup(address,address,address)"));

    // State variables

    IHubV2 public hub;

    INameRegistry public nameRegistry;

    /**
     * @dev The master copy of the ERC20 demurrage and inflation Circles contract.
     */
    address[2] public masterCopyERC20Wrapper;

    mapping(CirclesType => mapping(address => address)) public erc20Circles;

    // Events

    event ERC20WrapperDeployed(address indexed avatar, address indexed erc20Wrapper, CirclesType circlesType);

    // Constructor

    constructor(
        IHubV2 _hub,
        INameRegistry _nameRegistry,
        address _masterCopyERC20Demurrage,
        address _masterCopyERC20Inflation
    ) {
        if (address(_hub) == address(0)) {
            // Must not be the zero address.
            // revert CirclesAddressCannotBeZero(0);
            revert CirclesErrorNoArgs(0x07);
        }
        if (address(_nameRegistry) == address(0)) {
            // Must not be the zero address.
            // revert CirclesAddressCannotBeZero(1);
            revert CirclesErrorNoArgs(0x08);
        }
        if (_masterCopyERC20Demurrage == address(0)) {
            // Must not be the zero address.
            // revert CirclesAddressCannotBeZero(3);
            revert CirclesErrorNoArgs(0x09);
        }
        if (_masterCopyERC20Inflation == address(0)) {
            // Must not be the zero address.
            // revert CirclesAddressCannotBeZero(4);
            revert CirclesErrorNoArgs(0x0A);
        }

        hub = _hub;

        nameRegistry = _nameRegistry;

        masterCopyERC20Wrapper[uint256(CirclesType.Demurrage)] = _masterCopyERC20Demurrage;
        masterCopyERC20Wrapper[uint256(CirclesType.Inflation)] = _masterCopyERC20Inflation;
    }

    // Public functions

    function ensureERC20(address _avatar, CirclesType _circlesType) public returns (address) {
        if (_circlesType != CirclesType.Demurrage && _circlesType != CirclesType.Inflation) {
            // Must be a valid CirclesType.
            revert CirclesInvalidParameter(uint256(_circlesType), 0);
        }

        if (msg.sender != address(hub)) {
            // if the Hub calls it already has checked valid avatar
            // so when called independent from the Hub, check if the avatar
            // is a registered human or group
            if (!(hub.isHuman(_avatar) || hub.isGroup(_avatar))) {
                // Avatar must be registered (as human or group)
                // revert CirclesAvatarMustBeRegistered(_avatar, 0);
                revert CirclesErrorOneAddressArg(_avatar, 0x26);
            }
        }

        address erc20Wrapper = erc20Circles[_circlesType][_avatar];
        if (erc20Wrapper == address(0)) {
            erc20Wrapper = _deployERC20(masterCopyERC20Wrapper[uint256(_circlesType)], _avatar);
            erc20Circles[_circlesType][_avatar] = erc20Wrapper;

            emit ERC20WrapperDeployed(_avatar, erc20Wrapper, _circlesType);
        }
        return erc20Wrapper;
    }

    // Internal functions

    function _deployERC20(address _masterCopy, address _avatar) internal returns (address) {
        bytes memory wrapperSetupData =
            abi.encodeWithSelector(ERC20_WRAPPER_SETUP_CALLPREFIX, hub, nameRegistry, _avatar);
        address erc20wrapper = address(_createProxy(_masterCopy, wrapperSetupData));
        return erc20wrapper;
    }
}
