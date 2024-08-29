// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.4;

import "forge-std/Test.sol";
import "../../src/proxy/Proxy.sol"; // Replace with the correct path to Proxy contract;
import "../../src/proxy/MasterCopyNonUpgradable.sol"; // Replace with the correct path to MasterCopyNonUpgradable;

pragma solidity >=0.8.4;

contract MasterCopyTest is MasterCopyNonUpgradable {
    uint256 public data;
    uint256 public receivedEther; // Add this to track received Ether

    function setData(uint256 _data) external {
        data = _data;
    }

    function getData() external view returns (uint256) {
        return data;
    }

    function getReservedStorageSlot() external view returns (address) {
        return reservedStorageSlotForProxy;
    }

    // Function to accept Ether
    receive() external payable {
        receivedEther += msg.value;
    }
}

contract ProxyTest is Test {
    Proxy public proxy;
    MasterCopyTest public masterCopy;

    function setUp() public {
        // Deploy the MasterCopyNonUpgradable contract
        masterCopy = new MasterCopyTest();

        // Deploy the proxy contract with the master copy address
        proxy = new Proxy(address(masterCopy));
    }

    function testDeployment() public {
        // Verify that the masterCopy address is correctly set in the proxy
        address storedMasterCopy = proxy.masterCopy();
        assertEq(
            storedMasterCopy,
            address(masterCopy),
            "MasterCopy address mismatch"
        );
    }

    function testFallbackDelegation() public {
        // Prepare the calldata for the setData function of MasterCopyTest
        bytes memory data = abi.encodeWithSelector(
            MasterCopyTest.setData.selector,
            42
        );

        // Call the proxy with the data to trigger the fallback function
        (bool success, ) = address(proxy).call(data);
        assertTrue(success, "Fallback function failed");

        // Read the data directly from the proxy's storage, since that's where it's actually stored
        (bool success2, bytes memory returnData) = address(proxy).call(
            abi.encodeWithSelector(MasterCopyTest.getData.selector)
        );
        assertTrue(success2, "Call to getData failed");

        uint256 storedData = abi.decode(returnData, (uint256));
        assertEq(storedData, 42, "Data not correctly set in the proxy");
    }

    function testMasterCopyFunction() public {
        // Ensure that we are querying the correct storage slot in the proxy
        (bool success, bytes memory returnData) = address(proxy).call(
            abi.encodeWithSelector(
                MasterCopyTest.getReservedStorageSlot.selector
            )
        );
        assertTrue(success, "Call to getReservedStorageSlot failed");

        // Since this is the proxy, it will return the masterCopy address (as per the reserved slot)
        address returnedAddress = abi.decode(returnData, (address));
        assertEq(
            returnedAddress,
            address(masterCopy),
            "Reserved storage slot mismatch"
        );
    }

    function testReceiveFunction() public {
        // Send Ether to the proxy contract
        (bool success, ) = address(proxy).call{value: 1 ether}("");
        assertTrue(success, "Receive function failed");

        // Ensure the proxy contract balance is correctly updated
        assertEq(
            address(proxy).balance,
            1 ether,
            "Ether not received correctly"
        );
    }
}
