// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { DeployArgs } from "./DeployArgs.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { Points } from "../../src/points/Points.sol";
import { FixedQuestion } from "../../src/questions/FixedQuestion.sol";
import { OpenQuestion } from "../../src/questions/OpenQuestion.sol";
import { Names } from "../../src/names/Names.sol";
import { Plasa } from "../../src/plasa/Plasa.sol";

contract DeploySingle is Script {
	function deployQuestion(
		address spaceAddress,
		address pointsAddress,
		DeployArgs.QuestionArgs memory args,
		address plasaAddress
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
				args.optionDescriptions,
				plasaAddress
			);
	}

	function deployOpenQuestion(
		address spaceAddress,
		address pointsAddress,
		DeployArgs.OpenQuestionArgs memory args,
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
		uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");
		uint256 superAdminPrivateKey = vm.envUint("SUPER_ADMIN_PRIVATE_KEY");

		address superAdmin = vm.addr(superAdminPrivateKey);
		console.log("Deployer address:", vm.addr(deployerPrivateKey));
		console.log("Super Admin address:", superAdmin);

		DeployArgs deployArgs = new DeployArgs();
		DeployArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy Names
		Names names = new Names(superAdmin);

		// Deploy Plasa
		Plasa plasa = new Plasa(superAdmin, address(names));

		// Deploy Stamps
		FollowerSinceStamp[] memory stamps = new FollowerSinceStamp[](args.space.stampPlatforms.length);
		address[] memory stampAddresses = new address[](args.space.stampPlatforms.length);

		for (uint256 i = 0; i < args.space.stampPlatforms.length; i++) {
			stamps[i] = new FollowerSinceStamp(
				args.common.stampSigner,
				args.space.stampPlatforms[i],
				args.space.stampFollowed[i],
				superAdmin
			);
			stampAddresses[i] = address(stamps[i]);
		}

		// Deploy Points
		Points points = new Points(
			args.space.pointsName,
			args.space.pointsSymbol,
			stampAddresses,
			args.space.stampMultipliers,
			address(plasa)
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
		FixedQuestion fixedQuestion1 = deployQuestion(
			address(space),
			address(points),
			args.fixedQuestion1,
			address(plasa)
		);
		FixedQuestion fixedQuestion2 = deployQuestion(
			address(space),
			address(points),
			args.fixedQuestion2,
			address(plasa)
		);
		FixedQuestion fixedQuestion3 = deployQuestion(
			address(space),
			address(points),
			args.fixedQuestion3,
			address(plasa)
		);

		// Deploy Open Questions
		OpenQuestion openQuestion1 = deployOpenQuestion(
			address(space),
			address(points),
			args.openQuestion1,
			address(plasa)
		);
		OpenQuestion openQuestion2 = deployOpenQuestion(
			address(space),
			address(points),
			args.openQuestion2,
			address(plasa)
		);

		// Add questions to space
		space.addQuestion(address(fixedQuestion1));
		space.addQuestion(address(fixedQuestion2));
		space.addQuestion(address(fixedQuestion3));
		space.addQuestion(address(openQuestion1));
		space.addQuestion(address(openQuestion2));

		vm.stopBroadcast();

		// Log deployed contract addresses
		console.log("Space deployed at:", address(space));
		console.log("Points deployed at:", address(points));
		for (uint256 i = 0; i < stamps.length; i++) {
			console.log(string.concat("Stamp ", string(abi.encodePacked(i + 1)), " deployed at:"), address(stamps[i]));
		}
		console.log("Fixed Question 1 deployed at:", address(fixedQuestion1));
		console.log("Fixed Question 2 deployed at:", address(fixedQuestion2));
		console.log("Fixed Question 3 deployed at:", address(fixedQuestion3));
		console.log("Open Question 1 deployed at:", address(openQuestion1));
		console.log("Open Question 2 deployed at:", address(openQuestion2));
	}
}
