// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { OpenQuestion } from "../../src/questions/OpenQuestion.sol";
import { AddOpenQuestionArgs } from "./AddOpenQuestionArgs.sol";
import { Plasa } from "../../src/plasa/Plasa.sol";

contract AddOpenQuestion is Script {
	function deployQuestion(
		address spaceAddress,
		address pointsAddress,
		AddOpenQuestionArgs.QuestionArgs memory args,
		address plasaAddress
	) private returns (OpenQuestion) {
		return
			new OpenQuestion(
				spaceAddress,
				pointsAddress,
				args.title,
				args.description,
				args.tags,
				args.deadline,
				plasaAddress
			);
	}

	function run() public {
		uint256 superAdminPrivateKey = vm.envUint("SUPER_ADMIN_PRIVATE_KEY");
		address superAdmin = vm.addr(superAdminPrivateKey);
		console.log("Super Admin address:", superAdmin);

		AddOpenQuestionArgs deployArgs = new AddOpenQuestionArgs();
		AddOpenQuestionArgs.DeploymentArgs memory args = deployArgs.getArgs();

		// Get Space contract instance
		Space space = Space(args.spaceAddress);
		address pointsAddress = address(0);
		address plasaAddress = args.plasaAddress;

		vm.startBroadcast(superAdminPrivateKey);

		// Deploy Open Question
		OpenQuestion question = deployQuestion(args.spaceAddress, pointsAddress, args.question, plasaAddress);

		// Add question to space
		space.addQuestion(address(question));

		vm.stopBroadcast();

		// Log deployed contract address
		console.log("Open Question deployed at:", address(question));
	}
}
