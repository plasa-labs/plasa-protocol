// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";

contract DeployPoCArgs is Script {
	struct DeploymentArgs {
		// Space args
		address[] initialSuperAdmins;
		address[] initialAdmins;
		address[] initialModerators;
		address stampSigner;
		string stampPlatform;
		string stampFollowed;
		string spaceName;
		string spaceDescription;
		string spaceImageUrl;
		string pointsName;
	}

	function getArgs() public view returns (DeploymentArgs memory) {
		address[] memory superAdmins = new address[](1);
		superAdmins[0] = vm.envAddress("SUPER_ADMIN_ADDRESS");

		// address[] memory superAdmins = new address[](1);
		// superAdmins[0] = vm.envAddress("SUPER_ADMIN_ADDRESS");

		// address[] memory admins = new address[](1);
		// admins[0] = vm.envAddress("ADMIN_ADDRESS");

		// address[] memory moderators = new address[](1);
		// modulators[0] = vm.envAddress("MODERATOR_ADDRESS");

		DeploymentArgs memory args = DeploymentArgs({
			initialSuperAdmins: superAdmins,
			initialAdmins: new address[](0),
			initialModerators: new address[](0),
			stampSigner: vm.envAddress("EIP712_SIGNER_ADDRESS"),
			stampPlatform: "Instagram",
			stampFollowed: "base_onchain",
			spaceName: "Base",
			spaceDescription: "The (un)official community space for Base Onchain community",
			spaceImageUrl: "https://raw.githubusercontent.com/base-org/brand-kit/refs/heads/main/logo/in-product/Base_Network_Logo.png",
			pointsName: "BASE"
		});

		return args;
	}
}
