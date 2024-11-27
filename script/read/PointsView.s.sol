// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Points } from "../../src/points/Points.sol";
import { IPointsView } from "../../src/points/interfaces/IPointsView.sol";

contract PointsViewScript is Script {
	function run() public {
		// Get the points address from environment variable
		address pointsAddress = vm.envAddress("POINTS_ADDRESS");
		// Get the user address from environment variable
		address userAddress = vm.envAddress("USER_ADDRESS");

		console.log("Reading Points View for:");
		console.log("Points:", pointsAddress);
		console.log("User:", userAddress);

		// Create interface instance
		Points points = Points(pointsAddress);

		points.getPointsView(userAddress);
	}
}
