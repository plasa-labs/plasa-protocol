// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points, IPoints } from "./Points.sol";
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
	constructor(address _followerStamp, string memory _name, string memory _symbol) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
	}

	/// @inheritdoc Points
	/// @dev Calculates the balance for a user at a specific timestamp based on their follower duration
	function _balanceAtTimestamp(address user, uint256 timestamp) internal view override returns (uint256) {
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
	function _isInvalidFollowerTimestamp(uint256 followerSince, uint256 timestamp) private pure returns (bool) {
		return followerSince == 0 || followerSince > timestamp;
	}

	/// @notice Calculates points based on the duration of following using a square root formula
	/// @dev Uses a square root calculation for non-linear growth curve:
	///      - 1 day (86400 seconds) ≈ 1 point
	///      - 4 days (345600 seconds) ≈ 2 points
	///      - Formula: sqrt(durationInSeconds) / sqrt(86400)
	/// @param followerSince Timestamp when the user started following
	/// @param timestamp Current timestamp for calculation
	/// @return uint256 Calculated points, scaled to 18 decimal places
	function _calculatePointsAtTimestamp(uint256 followerSince, uint256 timestamp) private pure returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		return (Math.sqrt(durationInSeconds) * 1e18) / Math.sqrt(86400);
	}

	/// @inheritdoc IPoints
	function getTopHolders(uint256 start, uint256 end) public view override(IPoints, Points) returns (Holder[] memory) {
		// Get total number of stamps
		uint256 totalStamps = followerStamp.totalSupply();
		if (totalStamps == 0 || start >= end) {
			return new Holder[](0);
		}

		// Create temporary array to store all holders with non-zero balances
		Holder[] memory holders = new Holder[](totalStamps);
		uint256 actualHolderCount = 0;
		uint256 currentTimestamp = block.timestamp;

		// Collect all holders with non-zero balances
		for (uint256 i = 1; i <= totalStamps; ) {
			address owner = followerStamp.ownerOf(i);
			uint256 balance = _balanceAtTimestamp(owner, currentTimestamp);

			if (balance > 0) {
				holders[actualHolderCount] = Holder({ user: owner, balance: balance });
				unchecked {
					++actualHolderCount;
				}
			}
			unchecked {
				++i;
			}
		}

		// If no holders with balance, return empty array
		if (actualHolderCount == 0) {
			return new Holder[](0);
		}

		// Sort holders by balance (bubble sort for simplicity)
		// Can be optimized with quicksort for larger datasets
		for (uint256 i = 0; i < actualHolderCount - 1; ) {
			for (uint256 j = 0; j < actualHolderCount - i - 1; ) {
				if (holders[j].balance < holders[j + 1].balance) {
					Holder memory temp = holders[j];
					holders[j] = holders[j + 1];
					holders[j + 1] = temp;
				}
				unchecked {
					++j;
				}
			}
			unchecked {
				++i;
			}
		}

		// Calculate the actual slice size
		uint256 sliceSize = end > actualHolderCount ? actualHolderCount - start : end - start;
		if (start >= actualHolderCount) {
			return new Holder[](0);
		}

		// Create and fill result array with the requested slice
		Holder[] memory result = new Holder[](sliceSize);
		for (uint256 i = 0; i < sliceSize; ) {
			result[i] = holders[start + i];
			unchecked {
				++i;
			}
		}

		return result;
	}
}
