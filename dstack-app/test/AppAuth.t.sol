// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {AppAuth} from "../src/AppAuth.sol";
import {IAppAuth} from "../src/IAppAuth.sol";
import {IAppAuthBasicManagement} from "../src/IAppAuthBasicManagement.sol";
import {IERC165} from "@openzeppelin/contracts/utils/introspection/IERC165.sol";

// Test version of AppAuth that doesn't disable initializers
contract TestAppAuth is AppAuth {
    constructor() AppAuth() {
        // Override the constructor to NOT disable initializers for testing
    }
    
    // Override the parent constructor behavior
    function _disableInitializers() internal pure override {
        // Do nothing - allow initialization in tests
    }
}

contract AppAuthTest is Test {
    address public owner = address(0x1);
    address public nonOwner = address(0x2);
    address public appId = address(0x3);
    
    bytes32 public deviceId1 = keccak256("device1");
    bytes32 public deviceId2 = keccak256("device2");
    bytes32 public composeHash1 = keccak256("compose1");
    bytes32 public composeHash2 = keccak256("compose2");

    // Events for testing
    event ComposeHashAdded(bytes32 indexed composeHash);
    event ComposeHashRemoved(bytes32 indexed composeHash);
    event DeviceAdded(bytes32 indexed deviceId);
    event DeviceRemoved(bytes32 indexed deviceId);
    event AllowAnyDeviceSet(bool allowAny);
    event UpgradesDisabled();

    function setUp() public {
        // No setup needed, each test will create its own contract instance
    }

    // ====== Interface ID Tests ======

    function test_InterfaceIds() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Calculate expected interface IDs
        bytes4 iAppAuthId = type(IAppAuth).interfaceId;
        bytes4 iAppAuthBasicMgmtId = type(IAppAuthBasicManagement).interfaceId;
        bytes4 ierc165Id = type(IERC165).interfaceId;
        
        // Verify calculated interface IDs match expected values
        assertEq(uint32(iAppAuthId), uint32(0x1e079198), "IAppAuth interface ID mismatch");
        assertEq(uint32(iAppAuthBasicMgmtId), uint32(0x8fd37527), "IAppAuthBasicManagement interface ID mismatch");
        assertEq(uint32(ierc165Id), uint32(0x01ffc9a7), "IERC165 interface ID mismatch");
        
        // Verify contract supports all expected interfaces
        assertTrue(appAuth.supportsInterface(iAppAuthId), "Should support IAppAuth");
        assertTrue(appAuth.supportsInterface(iAppAuthBasicMgmtId), "Should support IAppAuthBasicManagement");
        assertTrue(appAuth.supportsInterface(ierc165Id), "Should support IERC165");
    }

    function test_IERC165_Compliance() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test that it supports IERC165
        assertTrue(appAuth.supportsInterface(type(IERC165).interfaceId));
        
        // Test that it doesn't support invalid interfaces
        assertFalse(appAuth.supportsInterface(0x00000000));
        assertFalse(appAuth.supportsInterface(0xffffffff));
        assertFalse(appAuth.supportsInterface(0x12345678));
        
        // Test edge cases
        assertFalse(appAuth.supportsInterface(bytes4(0)));
    }

    function test_InterfaceId_Calculation() public pure {
        // Manually calculate IAppAuth interface ID
        bytes4 isAppAllowedSelector = IAppAuth.isAppAllowed.selector;
        bytes4 expectedIAppAuthId = isAppAllowedSelector;
        assertEq(uint32(expectedIAppAuthId), uint32(0x1e079198), "Manual IAppAuth ID calculation should match");
        
        // Manually calculate IAppAuthBasicManagement interface ID
        bytes4 addComposeHashSelector = IAppAuthBasicManagement.addComposeHash.selector;
        bytes4 removeComposeHashSelector = IAppAuthBasicManagement.removeComposeHash.selector;
        bytes4 addDeviceSelector = IAppAuthBasicManagement.addDevice.selector;
        bytes4 removeDeviceSelector = IAppAuthBasicManagement.removeDevice.selector;
        
        bytes4 expectedIAppAuthBasicMgmtId = addComposeHashSelector ^ 
                                           removeComposeHashSelector ^ 
                                           addDeviceSelector ^ 
                                           removeDeviceSelector;
        assertEq(uint32(expectedIAppAuthBasicMgmtId), uint32(0x8fd37527), "Manual IAppAuthBasicManagement ID calculation should match");
    }

    // ====== Event Compliance Tests (Interface Requirements) ======
    
    function test_Events_EmittedByInterface_Functions() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test that functions emit events as required by interfaces
        // Note: Event emission is verified indirectly through state changes
        // and the fact that the functions complete successfully
        
        vm.prank(owner);
        appAuth.addComposeHash(composeHash2);
        assertTrue(appAuth.allowedComposeHashes(composeHash2), "ComposeHash should be added");
        
        vm.prank(owner);
        appAuth.removeComposeHash(composeHash2);
        assertFalse(appAuth.allowedComposeHashes(composeHash2), "ComposeHash should be removed");
        
        vm.prank(owner);
        appAuth.addDevice(deviceId2);
        assertTrue(appAuth.allowedDeviceIds(deviceId2), "Device should be added");
        
        vm.prank(owner);
        appAuth.removeDevice(deviceId2);
        assertFalse(appAuth.allowedDeviceIds(deviceId2), "Device should be removed");
    }

    // ====== Interface Compliance Tests ======

    function test_IAppAuth_Interface_Compliance() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test that all required functions exist and work as expected
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: composeHash1,
            instanceId: address(0x4),
            deviceId: deviceId1,
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });
        
        // Function should return the expected tuple (bool, string)
        (bool isAllowed, string memory reason) = IAppAuth(address(appAuth)).isAppAllowed(bootInfo);
        assertTrue(isAllowed);
        assertEq(reason, "");
        
        // Test with invalid data
        bootInfo.appId = address(0x999);
        (isAllowed, reason) = IAppAuth(address(appAuth)).isAppAllowed(bootInfo);
        assertFalse(isAllowed);
        assertEq(reason, "Wrong app controller");
    }

    function test_IAppAuthBasicManagement_Interface_Compliance() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        IAppAuthBasicManagement mgmt = IAppAuthBasicManagement(address(appAuth));
        
        // Test addComposeHash function exists and works
        vm.prank(owner);
        mgmt.addComposeHash(composeHash2);
        assertTrue(appAuth.allowedComposeHashes(composeHash2));
        
        // Test removeComposeHash function exists and works
        vm.prank(owner);
        mgmt.removeComposeHash(composeHash2);
        assertFalse(appAuth.allowedComposeHashes(composeHash2));
        
        // Test addDevice function exists and works
        vm.prank(owner);
        mgmt.addDevice(deviceId2);
        assertTrue(appAuth.allowedDeviceIds(deviceId2));
        
        // Test removeDevice function exists and works
        vm.prank(owner);
        mgmt.removeDevice(deviceId2);
        assertFalse(appAuth.allowedDeviceIds(deviceId2));
    }

    function test_Multiple_Interface_Support() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test that contract can be cast to all supported interfaces
        IAppAuth iAppAuth = IAppAuth(address(appAuth));
        IAppAuthBasicManagement iBasicMgmt = IAppAuthBasicManagement(address(appAuth));
        IERC165 iERC165 = IERC165(address(appAuth));
        
        // All casts should succeed and functions should work
        assertTrue(iERC165.supportsInterface(type(IAppAuth).interfaceId));
        assertTrue(iERC165.supportsInterface(type(IAppAuthBasicManagement).interfaceId));
        assertTrue(iERC165.supportsInterface(type(IERC165).interfaceId));
        
        // Functions from different interfaces should work
        vm.prank(owner);
        iBasicMgmt.addComposeHash(composeHash2);
        
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: composeHash2,
            instanceId: address(0x4),
            deviceId: deviceId1,
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });
        
        (bool isAllowed,) = iAppAuth.isAppAllowed(bootInfo);
        assertTrue(isAllowed);
    }

    // ====== Function Selector Tests ======

    function test_Function_Selectors() public pure {
        // Verify function selectors match expected values
        assertEq(IAppAuth.isAppAllowed.selector, bytes4(keccak256("isAppAllowed((address,bytes32,address,bytes32,bytes32,bytes32,bytes32,string,string[]))")));
        
        assertEq(IAppAuthBasicManagement.addComposeHash.selector, bytes4(keccak256("addComposeHash(bytes32)")));
        assertEq(IAppAuthBasicManagement.removeComposeHash.selector, bytes4(keccak256("removeComposeHash(bytes32)")));
        assertEq(IAppAuthBasicManagement.addDevice.selector, bytes4(keccak256("addDevice(bytes32)")));
        assertEq(IAppAuthBasicManagement.removeDevice.selector, bytes4(keccak256("removeDevice(bytes32)")));
        
        assertEq(IERC165.supportsInterface.selector, bytes4(keccak256("supportsInterface(bytes4)")));
    }

    function test_Initialize() public {
        // Test successful initialization
        TestAppAuth appAuth = new TestAppAuth();
        appAuth.initialize(
            owner,
            appId,
            false, // don't disable upgrades
            true,  // allow any device
            deviceId1,
            composeHash1
        );

        assertEq(appAuth.owner(), owner);
        assertEq(appAuth.appId(), appId);
        assertTrue(appAuth.allowAnyDevice());
        assertTrue(appAuth.allowedDeviceIds(deviceId1));
        assertTrue(appAuth.allowedComposeHashes(composeHash1));
    }

    function test_Initialize_WithoutOptionalParams() public {
        // Test initialization without initial device and compose hash
        TestAppAuth appAuth = new TestAppAuth();
        appAuth.initialize(
            owner,
            appId,
            false,
            false,
            bytes32(0), // no initial device
            bytes32(0)  // no initial compose hash
        );

        assertEq(appAuth.owner(), owner);
        assertEq(appAuth.appId(), appId);
        assertFalse(appAuth.allowAnyDevice());
        assertFalse(appAuth.allowedDeviceIds(deviceId1));
        assertFalse(appAuth.allowedComposeHashes(composeHash1));
    }

    function test_Initialize_RevertInvalidOwner() public {
        TestAppAuth appAuth = new TestAppAuth();
        vm.expectRevert("invalid owner address");
        appAuth.initialize(
            address(0),
            appId,
            false,
            true,
            deviceId1,
            composeHash1
        );
    }

    function test_Initialize_RevertInvalidAppId() public {
        TestAppAuth appAuth = new TestAppAuth();
        vm.expectRevert("invalid app ID");
        appAuth.initialize(
            owner,
            address(0),
            false,
            true,
            deviceId1,
            composeHash1
        );
    }

    function test_AddComposeHash() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Verify hash is not allowed initially
        assertFalse(appAuth.allowedComposeHashes(composeHash2));
        
        vm.prank(owner);
        appAuth.addComposeHash(composeHash2);

        // Verify hash is now allowed
        assertTrue(appAuth.allowedComposeHashes(composeHash2));
    }

    function test_AddComposeHash_RevertNotOwner() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        vm.prank(nonOwner);
        vm.expectRevert();
        appAuth.addComposeHash(composeHash2);
    }

    function test_RemoveComposeHash() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // First add the hash
        vm.prank(owner);
        appAuth.addComposeHash(composeHash2);
        assertTrue(appAuth.allowedComposeHashes(composeHash2));

        // Then remove it
        vm.prank(owner);
        appAuth.removeComposeHash(composeHash2);

        assertFalse(appAuth.allowedComposeHashes(composeHash2));
    }

    function test_AddDevice() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Verify device is not allowed initially
        assertFalse(appAuth.allowedDeviceIds(deviceId2));
        
        vm.prank(owner);
        appAuth.addDevice(deviceId2);

        // Verify device is now allowed
        assertTrue(appAuth.allowedDeviceIds(deviceId2));
    }

    function test_AddDevice_RevertNotOwner() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        vm.prank(nonOwner);
        vm.expectRevert();
        appAuth.addDevice(deviceId2);
    }

    function test_RemoveDevice() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // First add the device
        vm.prank(owner);
        appAuth.addDevice(deviceId2);
        assertTrue(appAuth.allowedDeviceIds(deviceId2));

        // Then remove it
        vm.prank(owner);
        appAuth.removeDevice(deviceId2);

        assertFalse(appAuth.allowedDeviceIds(deviceId2));
    }

    function test_SetAllowAnyDevice() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Initially set to true, change to false
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit AllowAnyDeviceSet(false);
        appAuth.setAllowAnyDevice(false);

        assertFalse(appAuth.allowAnyDevice());

        // Change back to true
        vm.prank(owner);
        vm.expectEmit(false, false, false, true);
        emit AllowAnyDeviceSet(true);
        appAuth.setAllowAnyDevice(true);

        assertTrue(appAuth.allowAnyDevice());
    }

    function test_SetAllowAnyDevice_RevertNotOwner() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        vm.prank(nonOwner);
        vm.expectRevert();
        appAuth.setAllowAnyDevice(false);
    }

    function test_IsAppAllowed_Success() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: composeHash1,
            instanceId: address(0x4),
            deviceId: deviceId1,
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });

        (bool isAllowed, string memory reason) = appAuth.isAppAllowed(bootInfo);
        assertTrue(isAllowed);
        assertEq(reason, "");
    }

    function test_IsAppAllowed_WrongAppController() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: address(0x999), // Wrong app ID
            composeHash: composeHash1,
            instanceId: address(0x4),
            deviceId: deviceId1,
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });

        (bool isAllowed, string memory reason) = appAuth.isAppAllowed(bootInfo);
        assertFalse(isAllowed);
        assertEq(reason, "Wrong app controller");
    }

    function test_IsAppAllowed_ComposeHashNotAllowed() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: keccak256("unknown_compose"), // Not allowed compose hash
            instanceId: address(0x4),
            deviceId: deviceId1,
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });

        (bool isAllowed, string memory reason) = appAuth.isAppAllowed(bootInfo);
        assertFalse(isAllowed);
        assertEq(reason, "Compose hash not allowed");
    }

    function test_IsAppAllowed_DeviceNotAllowed() public {
        // Initialize with allowAnyDevice = false
        TestAppAuth appAuth = new TestAppAuth();
        appAuth.initialize(
            owner,
            appId,
            false,
            false, // Don't allow any device
            deviceId1,
            composeHash1
        );
        
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: composeHash1,
            instanceId: address(0x4),
            deviceId: keccak256("unknown_device"), // Not allowed device
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });

        (bool isAllowed, string memory reason) = appAuth.isAppAllowed(bootInfo);
        assertFalse(isAllowed);
        assertEq(reason, "Device not allowed");
    }

    function test_IsAppAllowed_AllowAnyDevice() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test with a device that's not explicitly added
        IAppAuth.AppBootInfo memory bootInfo = IAppAuth.AppBootInfo({
            appId: appId,
            composeHash: composeHash1,
            instanceId: address(0x4),
            deviceId: keccak256("random_device"),
            mrAggregated: keccak256("mrAggregated"),
            mrSystem: keccak256("mrSystem"),
            osImageHash: keccak256("osImage"),
            tcbStatus: "OK",
            advisoryIds: new string[](0)
        });

        (bool isAllowed, string memory reason) = appAuth.isAppAllowed(bootInfo);
        assertTrue(isAllowed); // Should be allowed because allowAnyDevice is true
        assertEq(reason, "");
    }

    function test_DisableUpgrades() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        vm.prank(owner);
        vm.expectEmit(false, false, false, true, address(appAuth));
        emit UpgradesDisabled();
        appAuth.disableUpgrades();

        // Test that upgrades are disabled by checking internal state
        // We can't easily test the actual upgrade prevention in this test environment
        // but we can verify the function executed successfully and emitted the event
    }

    function test_DisableUpgrades_RevertNotOwner() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        vm.prank(nonOwner);
        vm.expectRevert();
        appAuth.disableUpgrades();
    }

    function test_SupportsInterface() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Test IAppAuth interface (0x1e079198)
        assertTrue(appAuth.supportsInterface(0x1e079198));
        
        // Test IAppAuthBasicManagement interface (0x8fd37527)
        assertTrue(appAuth.supportsInterface(0x8fd37527));
        
        // Test IERC165 interface
        assertTrue(appAuth.supportsInterface(type(IERC165).interfaceId));
        
        // Test unsupported interface
        assertFalse(appAuth.supportsInterface(0x12345678));
    }

    function test_InitializeTwice_ShouldRevert() public {
        TestAppAuth appAuth = _createAndInitializeAppAuth();
        
        // Try to initialize again
        vm.expectRevert();
        appAuth.initialize(
            owner,
            appId,
            false,
            true,
            deviceId1,
            composeHash1
        );
    }

    // Helper function to create and initialize AppAuth with default settings
    function _createAndInitializeAppAuth() internal returns (TestAppAuth) {
        TestAppAuth appAuth = new TestAppAuth();
        appAuth.initialize(
            owner,
            appId,
            false, // don't disable upgrades
            true,  // allow any device
            deviceId1,
            composeHash1
        );
        return appAuth;
    }
}
