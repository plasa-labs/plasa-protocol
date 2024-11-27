// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { ISpaceView } from "../../src/spaces/interfaces/ISpaceView.sol";

contract SpaceViewScript is Script {
	function run() public {
		// Get the space address from environment variable
		address spaceAddress = vm.envAddress("SPACE_ADDRESS");
		// Get the user address from environment variable
		address userAddress = vm.envAddress("USER_ADDRESS");

		console.log("Reading Space View for:");
		console.log("Space:", spaceAddress);
		console.log("User:", userAddress);

		// Create interface instance
		Space space = Space(spaceAddress);

		space.getSpaceView(userAddress);
	}
}
