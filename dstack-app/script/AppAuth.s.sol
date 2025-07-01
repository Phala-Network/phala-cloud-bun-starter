// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AppAuth} from "../src/AppAuth.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract AppAuthScript is Script {
    AppAuth public appAuthImpl;
    AppAuth public appAuth;
    ERC1967Proxy public proxy;

    function setUp() public {}

    function run() public {
        address initialOwner = vm.envOr("INITIAL_OWNER", msg.sender);
        address appId = vm.envAddress("APP_ID");
        bool disableUpgrades = vm.envOr("DISABLE_UPGRADES", false);
        bool allowAnyDevice = vm.envOr("ALLOW_ANY_DEVICE", true);
        bytes32 initialDeviceId = vm.envOr("INITIAL_DEVICE_ID", bytes32(0x1111111111111111111111111111111111111111111111111111111111111111));
        bytes32 initialComposeHash = vm.envOr("INITIAL_COMPOSE_HASH", bytes32(0x2222222222222222222222222222222222222222222222222222222222222222));

        console.log("=== AppAuth Deployment Parameters ===");
        console.log("Initial Owner:", initialOwner);
        console.log("Msg Sender:", msg.sender);
        console.log("App ID:", appId);
        console.log("Disable Upgrades:", disableUpgrades);
        console.log("Allow Any Device:", allowAnyDevice);
        console.log("Initial Device ID:");
        console.logBytes32(initialDeviceId);
        console.log("Initial Compose Hash:");
        console.logBytes32(initialComposeHash);

        vm.startBroadcast();

        console.log("\n=== Step 1: Deploying AppAuth Implementation ===");
        appAuthImpl = new AppAuth();
        console.log("AppAuth implementation deployed at:", address(appAuthImpl));

        console.log("\n=== Step 2: Preparing Initialization Data ===");
        bytes memory initData = abi.encodeWithSelector(
            AppAuth.initialize.selector,
            initialOwner,
            appId,
            disableUpgrades,
            allowAnyDevice,
            initialDeviceId,
            initialComposeHash
        );
        console.log("Initialization data prepared");

        console.log("\n=== Step 3: Deploying UUPS Proxy ===");
        proxy = new ERC1967Proxy(address(appAuthImpl), initData);
        appAuth = AppAuth(address(proxy));
        
        console.log("UUPS Proxy deployed at:", address(proxy));
        console.log("AppAuth accessible at:", address(appAuth));
        
        console.log("\n=== Step 4: Verifying Deployment ===");
        console.log("App ID:", appAuth.appId());
        console.log("Owner:", appAuth.owner());
        console.log("Allow any device:", appAuth.allowAnyDevice());
        
        if (initialDeviceId != bytes32(0)) {
            bool deviceAllowed = appAuth.allowedDeviceIds(initialDeviceId);
            console.log("Initial device allowed:", deviceAllowed);
        }
        
        if (initialComposeHash != bytes32(0)) {
            bool hashAllowed = appAuth.allowedComposeHashes(initialComposeHash);
            console.log("Initial compose hash allowed:", hashAllowed);
        }
        
        console.log("\n=== Step 5: Interface Support Check ===");
        console.log("Supports IAppAuth (0x1e079198):", appAuth.supportsInterface(0x1e079198));
        console.log("Supports IAppAuthBasicManagement (0x8fd37527):", appAuth.supportsInterface(0x8fd37527));
        console.log("Supports IERC165 (0x01ffc9a7):", appAuth.supportsInterface(0x01ffc9a7));

        console.log("\n=== Deployment Summary ===");
        console.log("AppAuth Implementation:", address(appAuthImpl));
        console.log("UUPS Proxy Address:", address(proxy));
        console.log("Ready for KMS Auth registration!");
        console.log("\nNext steps:");
        console.log("1. Register with KMS Auth:");
        console.log("   cast send $KMS_CONTRACT_ADDRESS 'registerApp(address)' %s --private-key $PRIVATE_KEY --rpc-url $RPC_URL", address(proxy));
        console.log("2. Verify registration:");
        console.log("   cast call $KMS_CONTRACT_ADDRESS 'apps(uint256)' '1' --rpc-url $RPC_URL");

        vm.stopBroadcast();
    }
}
