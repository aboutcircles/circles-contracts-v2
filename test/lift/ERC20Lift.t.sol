// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.13;

import {Test} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";
import "forge-std/console.sol";
import "../../src/circles/Demurrage.sol";
import "../setup/TimeCirclesSetup.sol";
import "../setup/AvatarCreation.sol";
import "../hub/MockDeployment.sol";
import "../hub/MockHub.sol";
import "../../src/errors/Errors.sol";

contract ERC20LiftTest is Test, TimeCirclesSetup, AvatarCreation, ICirclesErrors, ICirclesCompactErrors {
    // State variables

    MockDeployment public mockDeployment;
    MockHub public hub;
    ERC20Lift public lift;

    address public alice;
    address public bob;
    address public nonUser;

    DemurrageCircles public aliceERC20;

    event ERC20WrapperDeployed(address indexed avatar, address indexed erc20Wrapper, CirclesType circlesType);
    event ProxyCreation(address proxy, address masterCopy);

    // Constructor

    constructor() AvatarCreation(2) {}

    // Setup

    function setUp() public {
        // Set time in 2021
        startTime();

        // Mock deployment
        mockDeployment = new MockDeployment(INFLATION_DAY_ZERO, 365 days);
        hub = mockDeployment.hub();
        lift = mockDeployment.erc20Lift();

        alice = addresses[0];
        bob = addresses[1];
        nonUser = makeAddr("nonUser");

        // register Alice and Bob
        // Alice registers short name
        vm.startPrank(alice);
        hub.registerHumanUnrestricted();
        mockDeployment.nameRegistry().registerShortName();
        vm.stopPrank();
        vm.prank(bob);
        hub.registerHumanUnrestricted();
        
        // skip time and mint
        skipTime(14 days);
        vm.prank(alice);
        hub.personalMintWithoutV1Check();
        vm.prank(bob);
        hub.personalMintWithoutV1Check();
    }

    // Tests

    function testEnsureERC20InvalidType() public {
        uint256 invalidType = type(uint256).max;
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(CirclesInvalidParameter.selector, invalidType, 0));
        address(lift).call(abi.encodeWithSelector(lift.ensureERC20.selector, alice, invalidType));
    }

    function testEnsureERC20NotHubOrHumanOrGroup() public {
        vm.prank(nonUser);
        vm.expectRevert(abi.encodeWithSelector(CirclesErrorOneAddressArg.selector, nonUser, 0x26));
        lift.ensureERC20(nonUser, CirclesType.Demurrage);
    }

    function testEnsureERC20() public {
        address expectedAddress = 0xDF3DA9c97F5DB9B89dce95A05B1e2a04a00A59D3;
        vm.prank(alice);
        vm.expectEmit(true, true, true, true);
        emit ERC20WrapperDeployed(alice, expectedAddress, CirclesType.Demurrage);
        emit ProxyCreation(expectedAddress, lift.masterCopyERC20Wrapper(uint256(CirclesType.Demurrage)));
        address deployedAddress = lift.ensureERC20(alice, CirclesType.Demurrage);
        assertEq(deployedAddress, expectedAddress);
        assertEq(lift.erc20Circles(CirclesType.Demurrage, alice), expectedAddress);
    }

    /// todo: Not sure if the rest of the tests even belong here in the first place

    function testSelfWrap() public withTokenDeployed {
        uint256 aliceBalance = hub.balanceOf(alice, uint256(uint160(alice)));
        
        vm.prank(alice);
        hub.wrap(alice, 10 * CRC, CirclesType.Demurrage);

        assertEq(aliceERC20.balanceOf(alice), 10 * CRC);
        assertEq(hub.balanceOf(alice, uint256(uint160(alice))), aliceBalance - 10 * CRC);
    }

    function testSimpleSelfWrap() public withTokenDeployed {
        uint256 aliceBalance = hub.balanceOf(alice, uint256(uint160(alice)));
        
        vm.prank(alice);
        hub.safeTransferFrom(alice, address(aliceERC20), uint256(uint160(alice)), 5 * CRC, "");

        assertEq(aliceERC20.balanceOf(alice), 5 * CRC);
        assertEq(hub.balanceOf(alice, uint256(uint160(alice))), aliceBalance - 5 * CRC);
    }

    function testForeignWrap() public withTokenDeployed {
        vm.prank(alice);
        hub.safeTransferFrom(alice, bob, uint256(uint160(alice)), 5 * CRC, "");
        vm.prank(bob);
        hub.wrap(alice, 5 * CRC, CirclesType.Demurrage);
        assertEq(aliceERC20.balanceOf(bob), 5 * CRC);
    }

    function testSimpleForeignWrap() public withTokenDeployed {
        vm.prank(alice);
        hub.safeTransferFrom(alice, bob, uint256(uint160(alice)), 5 * CRC, "");
        vm.prank(bob);
        hub.safeTransferFrom(bob, address(aliceERC20), uint256(uint160(alice)), 5 * CRC, "");
        assertEq(aliceERC20.balanceOf(bob), 5 * CRC);
    }

    modifier withTokenDeployed() {
        vm.prank(alice);
        aliceERC20 = DemurrageCircles(mockDeployment.erc20Lift().ensureERC20(alice, CirclesType.Demurrage));
        _;
    }
}
