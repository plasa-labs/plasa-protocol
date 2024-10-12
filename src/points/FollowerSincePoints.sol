// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Points } from "./Points.sol";
import { IFollowerSincePoints } from "./interfaces/IFollowerSincePoints.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title FollowerSincePoints - A non-transferable token based on follower duration
/// @notice This contract calculates points based on how long a user has been a follower
/// @dev Inherits from Points and implements IFollowerSincePoints
contract FollowerSincePoints is Points, IFollowerSincePoints {
	/// @inheritdoc IFollowerSincePoints
	IFollowerSinceStamp public immutable override followerStamp;

	/// @notice Initializes the FollowerSincePoints contract
	/// @param _followerStamp The address of the IFollowerSinceStamp contract
	/// @param _name The name of the token
	/// @param _symbol The symbol of the token
	constructor(
		address _followerStamp,
		string memory _name,
		string memory _symbol
	) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
	}

	/// @inheritdoc IFollowerSincePoints
	function balanceOf(
		address account
	) public view override(IERC20, IFollowerSincePoints) returns (uint256) {
		uint256 followerSince = followerStamp.getFollowerSinceTimestamp(account);
		if (followerSince == 0) {
			return 0;
		}
		return _calculatePoints(followerSince);
	}

	/// @inheritdoc IFollowerSincePoints
	function totalSupply() public view override(IERC20, IFollowerSincePoints) returns (uint256) {
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

	/// @notice Calculates points based on the duration of following using a square root formula
	/// @dev This function uses a square root calculation to determine points, which creates a
	///      non-linear growth curve. The longer a user has been following, the more points they
	///      accumulate, but at a decreasing rate.
	/// @dev The calculation uses block.timestamp, which can be manipulated by miners to a small
	///      degree (usually up to 900 seconds). This manipulation is generally not significant
	///      for long-term following durations but could affect very recent followers.
	/// @dev The formula used is: sqrt(durationInSeconds * 1e18) * 1e9 / 293938769
	///      - Multiplication by 1e18 before sqrt to maintain precision
	///      - Multiplication by 1e9 after sqrt to scale the result
	///      - Division by 293938769 to adjust the growth rate and final values
	/// @param followerSince The timestamp when the user started following
	/// @return uint256 The calculated points, scaled to 18 decimal places
	function _calculatePoints(uint256 followerSince) private view returns (uint256) {
		// Calculate the duration of following in seconds
		uint256 durationInSeconds = block.timestamp - followerSince;

		// Calculate and return the points using the square root formula
		// The divisor (293938769) is carefully chosen to achieve desired point values
		return (Math.sqrt(durationInSeconds * 1e18) * 1e9) / 293938769;
	}
}
