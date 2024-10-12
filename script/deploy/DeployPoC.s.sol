// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console, console2 } from "forge-std/Script.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints } from "../../src/points/FollowerSincePoints.sol";
import { FixedQuestion } from "../../src/voting/FixedQuestion.sol";
import { DeployPoCArgs } from "./DeployPoCArgs.s.sol";

contract DeployPoC is Script {
	function run() public {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

		// Create an instance of DeployPoCArgs with the deployer's address
		address deployer = vm.addr(deployerPrivateKey);
		console.log("Deployer address:", deployer);

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy FollowerSinceStamp
		FollowerSinceStamp followerStamp = new FollowerSinceStamp(
			args.stampSigner,
			args.stampPlatform,
			args.stampFollowed
		);
		console.log("FollowerSinceStamp deployed at:", address(followerStamp));
		console.log("FollowerSinceStamp parameters:");
		console.log("  stampSigner:", args.stampSigner);
		console.log("  stampPlatform:", args.stampPlatform);
		console.log("  stampFollowed:", args.stampFollowed);

		// Deploy FollowerSincePoints
		FollowerSincePoints followerPoints = new FollowerSincePoints(
			address(followerStamp),
			args.pointsName,
			args.pointsSymbol
		);
		console.log("FollowerSincePoints deployed at:", address(followerPoints));
		console.log("FollowerSincePoints parameters:");
		console.log("  followerStamp:", address(followerStamp));
		console.log("  pointsName:", args.pointsName);
		console.log("  pointsSymbol:", args.pointsSymbol);

		// Deploy FixedQuestion
		FixedQuestion fixedQuestion = new FixedQuestion(
			args.questionOwner,
			args.questionTitle,
			args.questionDescription,
			args.questionDeadline,
			address(followerPoints),
			args.questionOptionTitles,
			args.questionOptionDescriptions
		);
		console.log("FixedQuestion deployed at:", address(fixedQuestion));
		console.log("FixedQuestion parameters:");
		console.log("  questionOwner:", args.questionOwner);
		console.log("  questionTitle:", args.questionTitle);
		console.log("  questionDescription:", args.questionDescription);
		console.log("  questionDeadline:", args.questionDeadline);
		console.log("  followerPoints:", address(followerPoints));

		console.log("  questionOptionTitles:");
		for (uint i = 0; i < args.questionOptionTitles.length; i++) {
			console.log("    [%d]: %s", i, args.questionOptionTitles[i]);
		}

		console.log("  questionOptionDescriptions:");
		for (uint i = 0; i < args.questionOptionDescriptions.length; i++) {
			console.log("    [%d]: %s", i, args.questionOptionDescriptions[i]);
		}

		vm.stopBroadcast();

		// Log deployment addresses and arguments in JSON format
		console.log("DEPLOYMENT_LOG_START");
		console.log("{");
		console.log('  "DeployerAddress": "%s",', deployer);
		console.log('  "FollowerSinceStamp": {');
		console.log('    "address": "%s",', address(followerStamp));
		console.log('    "arguments": {');
		console.log('      "stampSigner": "%s",', args.stampSigner);
		console.log('      "stampPlatform": "%s",', args.stampPlatform);
		console.log('      "stampFollowed": "%s"', args.stampFollowed);
		console.log("    }");
		console.log("  },");
		console.log('  "FollowerSincePoints": {');
		console.log('    "address": "%s",', address(followerPoints));
		console.log('    "arguments": {');
		console.log('      "followerStamp": "%s",', address(followerStamp));
		console.log('      "pointsName": "%s",', args.pointsName);
		console.log('      "pointsSymbol": "%s"', args.pointsSymbol);
		console.log("    }");
		console.log("  },");
		console.log('  "FixedQuestion": {');
		console.log('    "address": "%s",', address(fixedQuestion));
		console.log('    "arguments": {');
		console.log('      "questionOwner": "%s",', args.questionOwner);
		console.log('      "questionTitle": "%s",', args.questionTitle);
		console.log('      "questionDescription": "%s",', args.questionDescription);
		console.log('      "questionDeadline": %d,', args.questionDeadline);
		console.log('      "followerPoints": "%s",', address(followerPoints));
		console.log('      "questionOptionTitles": [');
		for (uint i = 0; i < args.questionOptionTitles.length; i++) {
			if (i < args.questionOptionTitles.length - 1) {
				console.log('        "%s",', args.questionOptionTitles[i]);
			} else {
				console.log('        "%s"', args.questionOptionTitles[i]);
			}
		}
		console.log("      ],");
		console.log('      "questionOptionDescriptions": [');
		for (uint i = 0; i < args.questionOptionDescriptions.length; i++) {
			if (i < args.questionOptionDescriptions.length - 1) {
				console.log('        "%s",', args.questionOptionDescriptions[i]);
			} else {
				console.log('        "%s"', args.questionOptionDescriptions[i]);
			}
		}
		console.log("      ]");
		console.log("    }");
		console.log("  }");
		console.log("}");
		console.log("DEPLOYMENT_LOG_END");
	}
}
