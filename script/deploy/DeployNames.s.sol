// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";

import { Names } from "../../src/names/Names.sol";

contract DeployNames is Script {
	function setUp() external {}

	function run() external {
		uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
		uint256 superAdminPrivateKey = vm.envUint("SUPER_ADMIN_PRIVATE_KEY");

		address deployer = vm.addr(deployerPrivateKey);
		address superAdmin = vm.addr(superAdminPrivateKey);

		console.log("Deployer address:", deployer);
		console.log("Super Admin address:", superAdmin);

		vm.startBroadcast(deployerPrivateKey);

		Names names = new Names(superAdmin);
		console.log("Names contract address:", address(names));

		vm.stopBroadcast();

		vm.startBroadcast(superAdminPrivateKey);

		names.mintName("admin");

		vm.stopBroadcast();
	}
}
