// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../errors/Errors.sol";
import "../hub/IHub.sol";
import "./ERC20InflationaryBalances.sol";

abstract contract InflationaryCircles is ERC20InflationaryBalances, ERC1155Holder, ICirclesErrors {
    // Constants

    // State variables

    IHubV2 public hub;

    address public avatar;

    uint256 private _totalSupply;

    // Modifiers

    modifier onlyHub() {
        if (msg.sender != address(hub)) {
            revert CirclesInvalidFunctionCaller(msg.sender, 0);
        }
        _;
    }

    // Constructor

    constructor() {
        // lock the master copy upon construction
        hub = IHubV2(address(0x1));
    }

    // Setup function

    function setup(address _avatar) external {
        require(address(hub) == address(0));
        require(_avatar != address(0));
        hub = IHubV2(msg.sender);
        avatar = _avatar;
        // read inflation day zero from hub
        inflationDayZero = hub.inflationDayZero();

        _setupPermit();
    }

    // External functions

    function unwrap(uint256 _amount) external {
        // _burn(msg.sender, _amount);
        // calculate demurraged amount to return to sender
        // hub.safeTransferFrom(address(this), msg.sender, toTokenId(avatar), _amount, "");
    }

    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Public functions

    function onERC1155Received(address, address _from, uint256 _id, uint256 _amount, bytes memory)
        public
        override
        onlyHub
        returns (bytes4)
    {
        if (_id != toTokenId(avatar)) revert CirclesInvalidCirclesId(_id, 0);
        // calculate inflationary amount to mint to sender
        // uint256 inflationaryAmount =
        // _mint(_from, _amount);
        return this.onERC1155Received.selector;
    }
}