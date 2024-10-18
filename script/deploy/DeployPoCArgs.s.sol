// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";

contract DeployPoCArgs is Script {
	struct DeploymentArgs {
		// Stamp args
		address stampSigner;
		string stampPlatform;
		string stampFollowed;
		// Points args
		string pointsName;
		string pointsSymbol;
		// Space args
		address[] initialSuperAdmins;
		address[] initialAdmins;
		address[] initialModerators;
		string spaceName;
		string spaceDescription;
		string spaceImageUrl;
		uint256 minPointsToAddOpenQuestionOption;
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
			// Stamp args
			stampSigner: vm.envAddress("EIP712_SIGNER_ADDRESS"),
			stampPlatform: "Instagram",
			stampFollowed: "base_onchain",
			// Points args
			pointsName: "Base Onchain Points",
			pointsSymbol: "ONCHAIN",
			// Space args
			initialSuperAdmins: superAdmins,
			initialAdmins: new address[](0),
			initialModerators: new address[](0),
			spaceName: "Base",
			spaceDescription: "The (un)official community space for Base Onchain community",
			spaceImageUrl: "https://raw.githubusercontent.com/base-org/brand-kit/refs/heads/main/logo/in-product/Base_Network_Logo.png",
			minPointsToAddOpenQuestionOption: 100
		});

		return args;
	}
}
