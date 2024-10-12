// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title FollowerSincePoints - A non-transferable token based on follower duration
/// @notice This contract calculates points based on how long a user has been a follower
/// @dev Inherits from Points and uses IFollowerSinceStamp for duration calculation
contract FollowerSincePoints is Points {
	IFollowerSinceStamp public immutable followerStamp;
	uint256 public immutable POINTS_PER_SECOND;

	/// @notice Initializes the FollowerPoints contract
	/// @param _followerStamp The address of the IFollowerSinceStamp contract
	/// @param _name The name of the token
	/// @param _symbol The symbol of the token
	/// @param _pointsPerSecond The number of points earned per second (in wei, 18 decimal places)
	constructor(
		address _followerStamp,
		string memory _name,
		string memory _symbol,
		uint256 _pointsPerSecond
	) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
		POINTS_PER_SECOND = _pointsPerSecond;
	}

	/// @notice Calculates the balance of points for a given account
	/// @dev Uses a square root formula based on the duration of following
	/// @param account The address to calculate the balance for
	/// @return uint256 The number of points the account has earned
	function balanceOf(address account) public view override returns (uint256) {
		uint256 followerSince = followerStamp.getFollowerSinceTimestamp(account);
		if (followerSince == 0) {
			return 0;
		}
		return _calculatePoints(followerSince);
	}

	/// @notice Returns the total supply of points
	/// @dev Calculates the total points for all followers using the followStartTimestamp
	/// @return uint256 The total supply of points
	function totalSupply() public view override returns (uint256) {
		uint256 totalPoints = 0;
		uint256 totalFollowers = followerStamp.totalSupply();

		for (uint256 i = 1; i <= totalFollowers; i++) {
			uint256 followerSince = followerStamp.followStartTimestamp(i);
			if (followerSince == 0) {
				continue;
			}
			totalPoints += _calculatePoints(followerSince);
		}

		return totalPoints;
	}

	/// @dev Calculates points based on the duration of following using a square root formula
	/// @param followerSince The timestamp when the user started following
	/// @return uint256 The calculated points
	function _calculatePoints(uint256 followerSince) private view returns (uint256) {
		// Calculate the duration of following in seconds
		uint256 durationInSeconds = block.timestamp - followerSince;

		// Calculate points using a square root formula:
		// points = sqrt(durationInSeconds * POINTS_PER_SECOND)
		// This creates a non-linear growth in points over time:
		// - New followers gain points quickly at first
		// - Long-term followers continue to gain points, but at a slower rate
		// The square root ensures that the point growth is more balanced over time
		return Math.sqrt(durationInSeconds * POINTS_PER_SECOND);
	}
}
