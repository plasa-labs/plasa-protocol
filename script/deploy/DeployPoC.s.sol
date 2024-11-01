// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { ISpace } from "../../src/spaces/interfaces/ISpace.sol";
import { DeployPoCArgs } from "./DeployPoCArgs.sol";
import { IFollowerSinceStamp } from "../../src/stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../src/points/interfaces/IFollowerSincePoints.sol";
import { IMultipleFollowerSincePoints } from "../../src/points/interfaces/IMultipleFollowerSincePoints.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints } from "../../src/points/FollowerSincePoints.sol";
import { MultipleFollowerSincePoints } from "../../src/points/MultipleFollowerSincePoints.sol";
import { Plasa } from "../../src/plasa/Plasa.sol";
import { FixedQuestion } from "../../src/questions/FixedQuestion.sol";

contract DeployPoC is Script {
	function deploySpace1(
		DeployPoCArgs.CommonArgs memory common,
		DeployPoCArgs.Space1Args memory args
	) private returns (Space, FollowerSincePoints, FollowerSinceStamp) {
		FollowerSinceStamp stamp = new FollowerSinceStamp(common.stampSigner, args.stampPlatform, args.stampFollowed);
		FollowerSincePoints points = new FollowerSincePoints(address(stamp), args.pointsName, args.pointsSymbol);
		Space space = new Space(
			common.initialSuperAdmins,
			args.name,
			args.description,
			args.imageUrl,
			address(points),
			common.minPointsToAddOpenQuestionOption
		);
		return (space, points, stamp);
	}

	function deploySpace2(
		DeployPoCArgs.CommonArgs memory common,
		DeployPoCArgs.Space2Args memory args
	) private returns (Space, MultipleFollowerSincePoints, FollowerSinceStamp[] memory) {
		FollowerSinceStamp[] memory stamps = new FollowerSinceStamp[](args.stampPlatforms.length);
		address[] memory stampAddresses = new address[](args.stampPlatforms.length);

		for (uint256 i = 0; i < args.stampPlatforms.length; i++) {
			stamps[i] = new FollowerSinceStamp(common.stampSigner, args.stampPlatforms[i], args.stampFollowed[i]);
			stampAddresses[i] = address(stamps[i]);
		}

		MultipleFollowerSincePoints points = new MultipleFollowerSincePoints(
			stampAddresses,
			args.stampMultipliers,
			args.pointsName,
			args.pointsSymbol
		);

		Space space = new Space(
			common.initialSuperAdmins,
			args.name,
			args.description,
			args.imageUrl,
			address(points),
			common.minPointsToAddOpenQuestionOption
		);

		return (space, points, stamps);
	}

	function deployQuestion(
		address spaceAddress,
		address pointsAddress,
		DeployPoCArgs.QuestionArgs memory args
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

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy Plasa
		Plasa plasa = new Plasa(superAdmin);

		// Deploy Space 1
		(Space space1, FollowerSincePoints points1, FollowerSinceStamp stamp1) = deploySpace1(args.common, args.space1);

		// Deploy Space 2
		(Space space2, MultipleFollowerSincePoints points2, FollowerSinceStamp[] memory stamps2) = deploySpace2(
			args.common,
			args.space2
		);

		// Deploy questions
		FixedQuestion question1 = deployQuestion(address(space1), address(points1), args.question1);

		FixedQuestion question2 = deployQuestion(address(space2), address(points2), args.question2);

		vm.stopBroadcast();

		// Switch to super admin for adding stamps, spaces, and questions
		vm.startBroadcast(superAdminPrivateKey);

		// Add stamps, spaces, and questions to Plasa and respective spaces
		plasa.addStamp(address(stamp1));
		plasa.addSpace(address(space1));
		space1.addQuestion(address(question1));

		for (uint256 i = 0; i < stamps2.length; i++) {
			plasa.addStamp(address(stamps2[i]));
		}
		plasa.addSpace(address(space2));
		space2.addQuestion(address(question2));

		vm.stopBroadcast();

		// Log deployed contract addresses
		console.log("Plasa deployed at:", address(plasa));
		console.log("Space 1 deployed at:", address(space1));
		console.log("Space 2 deployed at:", address(space2));
		console.log("Question 1 deployed at:", address(question1));
		console.log("Question 2 deployed at:", address(question2));
	}
}
