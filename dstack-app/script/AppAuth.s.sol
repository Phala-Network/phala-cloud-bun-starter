// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {AppAuth} from "../src/AppAuth.sol";

contract AppAuthScript is Script {
    AppAuth public appAuth;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        appAuth = new AppAuth();

        vm.stopBroadcast();
    }
}
