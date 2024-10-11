// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../circles/BatchedDemurrage.sol";
import "./ERC20Permit.sol";

contract ERC20InflationaryBalances is ERC20Permit, BatchedDemurrage, IERC20 {
    // State variables

    uint256 internal _totalSupply;

    mapping(address => uint256) private _balances;

    // Constructor

    // External functions

    function transfer(address _to, uint256 _amount) external returns (bool) {
        _transfer(msg.sender, _to, _amount);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _amount) external returns (bool) {
        _spendAllowance(_from, msg.sender, _amount);
        _transfer(_from, _to, _amount);
        return true;
    }

    function approve(address _spender, uint256 _amount) external returns (bool) {
        _approve(msg.sender, _spender, _amount);
        return true;
    }

    function increaseAllowance(address _spender, uint256 _addedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][_spender];
        _approve(msg.sender, _spender, currentAllowance + _addedValue);
        return true;
    }

    function decreaseAllowance(address _spender, uint256 _subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[msg.sender][_spender];
        if (_subtractedValue >= currentAllowance) {
            _approve(msg.sender, _spender, 0);
        } else {
            unchecked {
                _approve(msg.sender, _spender, currentAllowance - _subtractedValue);
            }
        }
        return true;
    }

    function balanceOf(address _account) external view returns (uint256) {
        return _balances[_account];
    }

    function allowance(address _owner, address _spender) external view returns (uint256) {
        return _allowances[_owner][_spender];
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    // Internal functions

    function _transfer(address _from, address _to, uint256 _amount) internal {
        uint256 fromBalance = _balances[_from];
        if (fromBalance < _amount) {
            revert ERC20InsufficientBalance(_from, fromBalance, _amount);
        }
        unchecked {
            _balances[_from] = fromBalance - _amount;
            // rely on total supply not having overflowed
            _balances[_to] += _amount;
        }
        emit Transfer(_from, _to, _amount);
    }

    function _mintFromDemurragedAmount(address _owner, uint256 _demurragedAmount) internal returns (uint256) {
        uint256 inflationaryAmount = convertDemurrageToInflationaryValue(_demurragedAmount, day(block.timestamp));
        // here ensure total supply does not overflow
        _totalSupply += inflationaryAmount;
        unchecked {
            _balances[_owner] += inflationaryAmount;
        }
        emit Transfer(address(0), _owner, inflationaryAmount);

        return inflationaryAmount;
    }

    function _burn(address _owner, uint256 _amount) internal {
        uint256 ownerBalance = _balances[_owner];
        if (ownerBalance < _amount) {
            revert ERC20InsufficientBalance(_owner, ownerBalance, _amount);
        }
        unchecked {
            _balances[_owner] = ownerBalance - _amount;
            // rely on total supply tracking complete sum of balances
            _totalSupply -= _amount;
        }
        emit Transfer(_owner, address(0), _amount);
    }
}
