// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {MintPolicy} from "src/groups/BaseMintPolicy.sol";

interface IMockMintPolicyWithSelectorClashes {
    function upgradeToAndCall(address _newImplementation, bytes memory _data)
        external
        returns (address, bytes memory);
    function renounceUpgradeability() external returns (bool);
}

contract MockMintPolicyWithSelectorClashes is MintPolicy {
    // External functions implemented to simulate clashes with proxy native selectors

    function implementation() external pure returns (address) {
        return address(0xff);
    }

    function upgradeToAndCall(address _newImplementation, bytes memory _data)
        external
        pure
        returns (address, bytes memory)
    {
        return (_newImplementation, _data);
    }

    function renounceUpgradeability() external pure returns (bool) {
        return true;
    }
}
