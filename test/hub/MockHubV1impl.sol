// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import "./../../src/migration/IHub.sol"; // Import the IHubV1 interface;
import "./../migration/MockToken.sol";

contract MockHubV1 is IHubV1 {
    /// @dev modifier allowing function to be only called by the token owner
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    // State variables

    bool private manuallyStopped; // true if this token has been stopped by it's owner
    address public immutable owner; // the safe that deployed this token

    // simplify to boolean trust
    mapping(address => mapping(address => bool)) public trusts;

    mapping(address => address) public userToToken;
    mapping(address => address) public tokenToUser;

    // Mock the functions of IHubV1 as needed for your test

    function signup() external {
        require(address(userToToken[msg.sender]) == address(0), "You can't sign up twice");

        Token token = new Token(msg.sender);
        userToToken[msg.sender] = address(token);
        tokenToUser[address(token)] = msg.sender;
        // every user must trust themselves with a weight of 100
        // this is so that all users accept their own token at all times
        trust(msg.sender, 100);
    }

    function stop() public onlyOwner {
        manuallyStopped = true;
    }

    function signupBonus() external view override returns (uint256) {
        return 1000 * 1e18; // Example bonus
    }

    function organizationSignup() external override {}

    function symbol() external view override returns (string memory) {
        return "MOCK"; // Example symbol
    }

    function name() external view override returns (string memory) {
        return "MockHubV1"; // Example name
    }

    function limits(address, address) external override returns (uint256) {
        return 0;
    }

    function trust(address _trustee, uint256 _limit) public {
        trusts[msg.sender][_trustee] = _limit > 0 ? true : false;
    }

    function deployedAt() external view override returns (uint256) {
        return block.timestamp;
    }

    function initialIssuance() external view override returns (uint256) {
        return 1000 * 1e18;
    }

    function issuance() external view override returns (uint256) {
        return 100 * 1e18;
    }

    function issuanceByStep(uint256) external view override returns (uint256) {
        return 100 * 1e18;
    }

    function inflate(uint256, uint256) external view override returns (uint256) {
        return 100 * 1e18;
    }

    function inflation() external view override returns (uint256) {
        return 2 * 1e18;
    }

    function divisor() external view override returns (uint256) {
        return 1e18;
    }

    function period() external view override returns (uint256) {
        return 1 days;
    }

    function periods() external view override returns (uint256) {
        return 1;
    }

    function timeout() external view override returns (uint256) {
        return 7 days;
    }
}
