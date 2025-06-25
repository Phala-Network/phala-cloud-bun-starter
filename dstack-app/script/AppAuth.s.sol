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
        address initialOwner = vm.envAddress("INITIAL_OWNER");
        address appId = vm.envAddress("APP_ID");
        bool disableUpgrades = vm.envBool("DISABLE_UPGRADES");
        bool allowAnyDevice = vm.envBool("ALLOW_ANY_DEVICE");
        bytes32 initialDeviceId = vm.envBytes32("INITIAL_DEVICE_ID");
        bytes32 initialComposeHash = vm.envBytes32("INITIAL_COMPOSE_HASH");

        vm.startBroadcast();

        console.log("Deploying AppAuth implementation...");
        appAuthImpl = new AppAuth();
        console.log("AppAuth implementation deployed at:", address(appAuthImpl));

        bytes memory initData = abi.encodeWithSelector(
            AppAuth.initialize.selector,
            initialOwner,
            appId,
            disableUpgrades,
            allowAnyDevice,
            initialDeviceId,
            initialComposeHash
        );

        console.log("Deploying UUPS proxy...");
        proxy = new ERC1967Proxy(address(appAuthImpl), initData);
        appAuth = AppAuth(address(proxy));
        
        console.log("UUPS Proxy deployed at:", address(proxy));
        console.log("AppAuth accessible at:", address(appAuth));
        
        console.log("Verifying deployment...");
        console.log("Sender:", msg.sender);
        console.log("App ID:", appAuth.appId());
        console.log("Owner:", appAuth.owner());
        console.log("Allow any device:", appAuth.allowAnyDevice());

        vm.stopBroadcast();
    }
}
