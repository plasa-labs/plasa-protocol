// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { ISpace } from "../../src/spaces/interfaces/ISpace.sol";
import { DeployPoCArgs } from "./DeployPoCArgs.s.sol";
import { IFollowerSinceStamp } from "../../src/stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../src/points/interfaces/IFollowerSincePoints.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints } from "../../src/points/FollowerSincePoints.sol";
import { Plasa } from "../../src/plasa/Plasa.sol";
import { FixedQuestion } from "../../src/voting/FixedQuestion.sol";

contract DeployPoC is Script {
	function run() public {
		uint256 deployerPrivateKey = vm.envUint("DEPLOYER_PRIVATE_KEY");

		// Create an instance of DeployPoCArgs with the deployer's address
		address deployer = vm.addr(deployerPrivateKey);
		console.log("Deployer address:", deployer);

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		FollowerSinceStamp stamp = new FollowerSinceStamp(args.stampSigner, args.stampPlatform, args.stampFollowed);

		FollowerSincePoints points = new FollowerSincePoints(address(stamp), args.pointsName, args.pointsSymbol);

		Space space = new Space(
			args.initialSuperAdmins,
			args.spaceName,
			args.spaceDescription,
			args.spaceImageUrl,
			address(points),
			args.minPointsToAddOpenQuestionOption
		);

		// Deploy Plasa
		// Set space initial super admin as Plasa owner
		Plasa plasa = new Plasa(args.initialSuperAdmins[0]);

		// Stop the broadcast with the deployer's private key
		vm.stopBroadcast();

		// Start a new broadcast with the initial super admin's private key
		uint256 superAdminPrivateKey = vm.envUint("SUPER_ADMIN_PRIVATE_KEY");
		vm.startBroadcast(superAdminPrivateKey);

		plasa.addStamp(address(stamp));
		plasa.addSpace(address(space));

		// Deploy a fixed question using the super admin's private key
		FixedQuestion fixedQuestion = new FixedQuestion(
			address(space),
			args.fixedQuestionTitle,
			args.fixedQuestionDescription,
			args.fixedQuestionDeadline,
			args.fixedQuestionOptionTitles,
			args.fixedQuestionOptionDescriptions
		);

		// Add the question to the space
		space.addQuestion(address(fixedQuestion));

		// Stop the broadcast with the super admin's private key
		vm.stopBroadcast();
	}
}
