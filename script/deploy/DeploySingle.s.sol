// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { DeploySingleArgs } from "./DeploySingleArgs.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { MultipleFollowerSincePoints } from "../../src/points/MultipleFollowerSincePoints.sol";
import { FixedQuestion } from "../../src/questions/FixedQuestion.sol";

contract DeploySingle is Script {
	function deployQuestion(
		address spaceAddress,
		address pointsAddress,
		DeploySingleArgs.QuestionArgs memory args
	) private returns (FixedQuestion) {
		return
			new FixedQuestion(
				spaceAddress,
				pointsAddress,
				args.title,
				args.description,
				args.tags,
				args.deadline,
				args.optionTitles,
				args.optionDescriptions
			);
	}

	function run() public {
		uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
		uint256 superAdminPrivateKey = vm.envUint("SUPER_ADMIN_PRIVATE_KEY");

		address superAdmin = vm.addr(superAdminPrivateKey);
		console.log("Deployer address:", vm.addr(deployerPrivateKey));
		console.log("Super Admin address:", superAdmin);

		DeploySingleArgs deployArgs = new DeploySingleArgs();
		DeploySingleArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy Stamps
		FollowerSinceStamp[] memory stamps = new FollowerSinceStamp[](args.space.stampPlatforms.length);
		address[] memory stampAddresses = new address[](args.space.stampPlatforms.length);

		for (uint256 i = 0; i < args.space.stampPlatforms.length; i++) {
			stamps[i] = new FollowerSinceStamp(
				args.common.stampSigner,
				args.space.stampPlatforms[i],
				args.space.stampFollowed[i]
			);
			stampAddresses[i] = address(stamps[i]);
		}

		// Deploy Points
		MultipleFollowerSincePoints points = new MultipleFollowerSincePoints(
			stampAddresses,
			args.space.stampMultipliers,
			args.space.pointsName,
			args.space.pointsSymbol
		);

		// Deploy Space
		Space space = new Space(
			args.common.initialSuperAdmins,
			args.space.name,
			args.space.description,
			args.space.imageUrl,
			address(points),
			args.common.minPointsToAddOpenQuestionOption
		);

		vm.stopBroadcast();

		// Switch to super admin for adding questions
		vm.startBroadcast(superAdminPrivateKey);

		// Deploy Questions
		FixedQuestion question1 = deployQuestion(address(space), address(0), args.question1);
		FixedQuestion question2 = deployQuestion(address(space), address(0), args.question2);

		// Add questions to space
		space.addQuestion(address(question1));
		space.addQuestion(address(question2));

		vm.stopBroadcast();

		// Log deployed contract addresses
		console.log("Space deployed at:", address(space));
		console.log("Points deployed at:", address(points));
		for (uint256 i = 0; i < stamps.length; i++) {
			console.log(string.concat("Stamp ", string(abi.encodePacked(i + 1)), " deployed at:"), address(stamps[i]));
		}
		console.log("Question 1 deployed at:", address(question1));
		console.log("Question 2 deployed at:", address(question2));
	}
}
