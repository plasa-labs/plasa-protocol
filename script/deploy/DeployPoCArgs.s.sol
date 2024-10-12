// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";

contract DeployPoCArgs is Script {
	struct DeploymentArgs {
		// FollowerSinceStamp args
		address stampSigner;
		string stampPlatform;
		string stampFollowed;
		// FollowerSincePoints args
		string pointsName;
		string pointsSymbol;
		// FixedQuestion args
		address questionOwner;
		string questionTitle;
		string questionDescription;
		uint256 questionDeadline;
		string[] questionOptionTitles;
		string[] questionOptionDescriptions;
	}

	function getArgs() public view returns (DeploymentArgs memory) {
		address deployer = vm.addr(vm.envUint("PRIVATE_KEY"));

		DeploymentArgs memory args = DeploymentArgs({
			// FollowerSinceStamp args
			stampSigner: deployer,
			stampPlatform: "Instagram",
			stampFollowed: "base_onchain",
			// FollowerSincePoints args
			pointsName: "Based Follower Points",
			pointsSymbol: "BFP",
			// FixedQuestion args
			questionOwner: deployer,
			questionTitle: "Location for the Next Onchain Summit",
			questionDescription: "The inaugural Onchain Summit in San Francisco was a resounding success, bringing together blockchain enthusiasts, developers, and industry leaders from around the world. As we look to the future, we want your input on where to host our next groundbreaking event. Each potential location offers unique advantages and opportunities for the crypto community. Consider factors such as local blockchain ecosystems, accessibility, cultural experiences, and potential for fostering global connections. Your vote will help shape the future of this influential gathering and potentially impact the global blockchain landscape. Where should we convene next to continue driving innovation and collaboration in the Web3 space?",
			questionDeadline: block.timestamp + 7 days,
			questionOptionTitles: new string[](3),
			questionOptionDescriptions: new string[](3)
		});

		args.questionOptionTitles[0] = "Buenos Aires, Argentina";
		args.questionOptionTitles[1] = "New York City, USA";
		args.questionOptionTitles[2] = "London, UK";
		args.questionOptionDescriptions[
				0
			] = "Buenos Aires is the capital of Argentina and a vibrant city known for its rich culture, tango, and steak. It's also an emerging crypto hub in Latin America. Obviously the right choice!";
		args.questionOptionDescriptions[
				1
			] = "New York City is the cultural, financial, and media capital of the world.";
		args.questionOptionDescriptions[
				2
			] = "London is a world-class city known for its rich history, museums, and the iconic Big Ben.";

		return args;
	}
}
