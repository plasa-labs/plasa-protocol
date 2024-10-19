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
		string spaceName;
		string spaceDescription;
		string spaceImageUrl;
		uint256 minPointsToAddOpenQuestionOption;
		// Fixed Question args
		string fixedQuestionTitle;
		string fixedQuestionDescription;
		uint256 fixedQuestionDeadline;
		string[] fixedQuestionOptionTitles;
		string[] fixedQuestionOptionDescriptions;
	}

	function getArgs() public view returns (DeploymentArgs memory) {
		address[] memory superAdmins = new address[](1);
		superAdmins[0] = vm.envAddress("SUPER_ADMIN_ADDRESS");

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
			spaceName: "Base",
			spaceDescription: "The (un)official community space for Base Onchain community",
			spaceImageUrl: "https://raw.githubusercontent.com/base-org/brand-kit/refs/heads/main/logo/in-product/Base_Network_Logo.png",
			minPointsToAddOpenQuestionOption: 100,
			// Fixed Question args
			fixedQuestionTitle: "Where should the next Onchain Summit be held?",
			fixedQuestionDescription: "Vote for the location of the next Onchain Summit",
			fixedQuestionDeadline: block.timestamp + 7 days,
			fixedQuestionOptionTitles: new string[](3),
			fixedQuestionOptionDescriptions: new string[](3)
		});

		args.fixedQuestionOptionTitles[0] = "Buenos Aires";
		args.fixedQuestionOptionTitles[1] = "San Francisco";
		args.fixedQuestionOptionTitles[2] = "Lisbon";

		args.fixedQuestionOptionDescriptions[0] = "The vibrant capital of Argentina";
		args.fixedQuestionOptionDescriptions[1] = "The tech hub of Silicon Valley";
		args.fixedQuestionOptionDescriptions[2] = "The historic capital of Portugal";

		return args;
	}
}
