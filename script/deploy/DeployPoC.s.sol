// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
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

		// Deploy FollowerSincePoints
		FollowerSincePoints followerPoints = new FollowerSincePoints(
			address(followerStamp),
			args.pointsName,
			args.pointsSymbol
		);
		console.log("FollowerSincePoints deployed at:", address(followerPoints));

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

		vm.stopBroadcast();
	}
}
