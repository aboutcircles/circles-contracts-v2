// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract UpgradeableRenounceableProxy is ERC1967Proxy {
    // Errors

    error OnlyAdminError();

    error BlockReceive();

    // Modifier

    modifier onlyAdmin() {
        if (msg.sender != ERC1967Utils.getAdmin()) {
            revert OnlyAdminError();
        }
        _;
    }

    // Constructor

    constructor(address _implementation, bytes memory _data) ERC1967Proxy(_implementation, _data) {
        // set the admin to the deployer
        ERC1967Utils.changeAdmin(msg.sender);
    }

    function implementation() external view returns (address) {
        return _implementation();
    }

    function upgradeToAndCall(address _newImplementation, bytes memory _data) external onlyAdmin {
        ERC1967Utils.upgradeToAndCall(_newImplementation, _data);
    }

    /**
     * @dev It renounces the ability to upgrade the contract, by setting the admin to 0x01.
     */
    function renounceUpgradeability() external onlyAdmin {
        ERC1967Utils.changeAdmin(address(0x01));
    }

    // Fallback function

    receive() external payable {
        revert BlockReceive();
    }
}
