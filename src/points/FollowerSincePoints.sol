// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points } from "./Points.sol";
import { IFollowerSincePoints } from "./interfaces/IFollowerSincePoints.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title FollowerSincePoints - Non-transferable token based on follower duration
/// @notice Calculates and manages points based on how long a user has been a follower
/// @dev Inherits from Points and implements IFollowerSincePoints
contract FollowerSincePoints is IFollowerSincePoints, Points {
	/// @inheritdoc IFollowerSincePoints
	IFollowerSinceStamp public immutable override followerStamp;

	/// @notice Initializes the FollowerSincePoints contract
	/// @param _followerStamp Address of the IFollowerSinceStamp contract
	/// @param _name Name of the token
	/// @param _symbol Symbol of the token
	constructor(
		address _followerStamp,
		string memory _name,
		string memory _symbol
	) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
	}

	/// @inheritdoc Points
	/// @dev Calculates the balance for a user at a specific timestamp based on their follower duration
	function _balanceAtTimestamp(
		address user,
		uint256 timestamp
	) internal view override returns (uint256) {
		uint256 followerSince = followerStamp.getFollowerSinceTimestamp(user);
		if (_isInvalidFollowerTimestamp(followerSince, timestamp)) {
			return 0;
		}
		return _calculatePointsAtTimestamp(followerSince, timestamp);
	}

	/// @inheritdoc Points
	/// @dev Calculates the total supply of points at a specific timestamp
	function _totalSupplyAtTimestamp(uint256 timestamp) internal view override returns (uint256) {
		uint256 totalPoints;
		uint256 totalStamps = followerStamp.totalSupply();
		IFollowerSinceStamp stamp = followerStamp; // Cache the followerStamp reference

		for (uint256 i = 1; i <= totalStamps; ) {
			uint256 followerSince = stamp.followStartTimestamp(i);
			if (followerSince != 0 && followerSince <= timestamp) {
				unchecked {
					totalPoints += _calculatePointsAtTimestamp(followerSince, timestamp);
				}
			}
			unchecked {
				++i;
			}
		}

		return totalPoints;
	}

	/// @dev Checks if the follower timestamp is invalid
	/// @param followerSince Timestamp when the user started following
	/// @param timestamp Timestamp to compare against
	/// @return bool True if the follower timestamp is invalid, false otherwise
	function _isInvalidFollowerTimestamp(
		uint256 followerSince,
		uint256 timestamp
	) private pure returns (bool) {
		return followerSince == 0 || followerSince > timestamp;
	}

	/// @notice Calculates points based on the duration of following using a square root formula
	/// @dev Uses a square root calculation for non-linear growth curve:
	///      - Longer following duration accumulates more points at a decreasing rate
	///      - Formula: sqrt(durationInSeconds * 1e18) * 1e9 / 293938769
	///      - 1e18 multiplication before sqrt maintains precision
	///      - 1e9 multiplication after sqrt scales the result
	///      - 293938769 division adjusts growth rate and final values
	/// @dev Note: block.timestamp can be slightly manipulated by miners (up to ~900 seconds)
	/// @param followerSince Timestamp when the user started following
	/// @param timestamp Current timestamp for calculation
	/// @return uint256 Calculated points, scaled to 18 decimal places
	function _calculatePointsAtTimestamp(
		uint256 followerSince,
		uint256 timestamp
	) private pure returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		return (Math.sqrt(durationInSeconds * 1e18) * 1e9) / 293938769;
	}
}
