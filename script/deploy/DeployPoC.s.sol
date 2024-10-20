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
import { FixedQuestion } from "../../src/voting/FixedQuestion.sol";

contract DeployPoC is Script {
	function run() public {
		uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

		address deployer = vm.addr(deployerPrivateKey);
		console.log("Deployer address:", deployer);

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy Plasa
		Plasa plasa = new Plasa(args.initialSuperAdmins[0]);

		// Deploy Space 1 with FollowerSincePoints
		FollowerSinceStamp stamp1 = new FollowerSinceStamp(args.stampSigner, args.stamp1Platform, args.stamp1Followed);
		FollowerSincePoints points1 = new FollowerSincePoints(address(stamp1), args.points1Name, args.points1Symbol);
		Space space1 = new Space(
			args.initialSuperAdmins,
			args.space1Name,
			args.space1Description,
			args.space1ImageUrl,
			address(points1),
			args.minPointsToAddOpenQuestionOption
		);

		// Deploy Space 2 with MultipleFollowerSincePoints
		FollowerSinceStamp[] memory stamps2 = new FollowerSinceStamp[](args.stamp2Platforms.length);
		address[] memory stampAddresses2 = new address[](args.stamp2Platforms.length);
		for (uint256 i = 0; i < args.stamp2Platforms.length; i++) {
			stamps2[i] = new FollowerSinceStamp(args.stampSigner, args.stamp2Platforms[i], args.stamp2Followed[i]);
			stampAddresses2[i] = address(stamps2[i]);
		}
		MultipleFollowerSincePoints points2 = new MultipleFollowerSincePoints(
			stampAddresses2,
			args.stamp2Multipliers,
			args.points2Name,
			args.points2Symbol
		);
		Space space2 = new Space(
			args.initialSuperAdmins,
			args.space2Name,
			args.space2Description,
			args.space2ImageUrl,
			address(points2),
			args.minPointsToAddOpenQuestionOption
		);

		// Deploy question for Space 1
		FixedQuestion question1 = new FixedQuestion(
			address(space1),
			args.question1Title,
			args.question1Description,
			args.question1Deadline,
			args.question1OptionTitles,
			args.question1OptionDescriptions
		);

		// Deploy question for Space 2
		FixedQuestion question2 = new FixedQuestion(
			address(space2),
			args.question2Title,
			args.question2Description,
			args.question2Deadline,
			args.question2OptionTitles,
			args.question2OptionDescriptions
		);

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
