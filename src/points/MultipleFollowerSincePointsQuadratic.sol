// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { MultipleFollowerSincePoints } from "./MultipleFollowerSincePoints.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title MultipleFollowerSincePointsQuadratic - A quadratic version of MultipleFollowerSincePoints
/// @notice This contract calculates points using a quadratic formula instead of linear
/// @dev Inherits from MultipleFollowerSincePoints and overrides only the points calculation
contract MultipleFollowerSincePointsQuadratic is MultipleFollowerSincePoints {
	constructor(
		address[] memory _stampAddresses,
		uint256[] memory _multipliers,
		string memory _name,
		string memory _symbol,
		address _plasaContract
	) MultipleFollowerSincePoints(_stampAddresses, _multipliers, _name, _symbol, _plasaContract) {}

	/// @notice Calculates points based on the duration of following using a square root formula
	/// @dev Uses a square root calculation for non-linear growth curve:
	///      - 1 day (86400 seconds) ≈ 1 point
	///      - 4 days (345600 seconds) ≈ 2 points
	///      - Formula: sqrt(durationInSeconds) / sqrt(86400)
	/// @param followerSince Timestamp when the user started following
	/// @param timestamp Current timestamp for calculation
	/// @return uint256 Calculated points, scaled to 18 decimal places
	function _calculatePointsAtTimestamp(
		uint256 followerSince,
		uint256 timestamp
	) internal pure override returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		uint256 scaledDuration = durationInSeconds * 1e18;
		uint256 scaledDay = 86400 * 1e18;
		return (Math.sqrt(scaledDuration) * 1e18) / Math.sqrt(scaledDay);
	}
}
