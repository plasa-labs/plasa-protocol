// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { Points } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IMultipleFollowerSincePoints } from "./interfaces/IMultipleFollowerSincePoints.sol";

/// @title MultipleFollowerSincePoints - A non-transferable token based on multiple follower durations
/// @notice This contract calculates points based on how long a user has been a follower across multiple accounts
/// @dev Inherits from Points and implements IMultipleFollowerSincePoints, using multiple IFollowerSinceStamp for duration calculation
contract MultipleFollowerSincePoints is Points, IMultipleFollowerSincePoints {
	StampInfo[] private _stamps;

	constructor(
		address[] memory _stampAddresses,
		uint256[] memory _multipliers,
		string memory _name,
		string memory _symbol
	) Points(_name, _symbol, 18) {
		if (_stampAddresses.length != _multipliers.length) revert ArrayLengthMismatch();
		for (uint256 i = 0; i < _stampAddresses.length; i++) {
			_stamps.push(StampInfo(IFollowerSinceStamp(_stampAddresses[i]), _multipliers[i]));
		}
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function stamps() public view returns (StampInfo[] memory) {
		return _stamps;
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function stampByIndex(uint256 index) public view returns (StampInfo memory) {
		require(index < _stamps.length, "Index out of bounds");
		return _stamps[index];
	}

	/// @inheritdoc Points
	function _balanceAtTimestamp(
		address account,
		uint256 timestamp
	) internal view override returns (uint256) {
		uint256 totalPoints;
		uint256 stampCount = _stamps.length;

		for (uint256 i; i < stampCount; ) {
			totalPoints += _calculatePointsForStamp(_stamps[i], account, timestamp);
			unchecked {
				++i;
			}
		}
		return totalPoints;
	}

	/// @inheritdoc Points
	function _totalSupplyAtTimestamp(uint256 timestamp) internal view override returns (uint256) {
		uint256 totalPoints;
		uint256 stampCount = _stamps.length;

		for (uint256 i; i < stampCount; ) {
			totalPoints += _calculateTotalPointsForStamp(_stamps[i], timestamp);
			unchecked {
				++i;
			}
		}
		return totalPoints;
	}

	/// @dev Calculates points for a specific stamp and account at a given timestamp
	/// @param stampInfo The StampInfo struct containing stamp and multiplier information
	/// @param account The address of the account to calculate points for
	/// @param timestamp The timestamp at which to calculate points
	/// @return The calculated points for the stamp and account
	function _calculatePointsForStamp(
		StampInfo storage stampInfo,
		address account,
		uint256 timestamp
	) private view returns (uint256) {
		uint256 followerSince = stampInfo.stamp.getFollowerSinceTimestamp(account);
		if (followerSince != 0 && followerSince <= timestamp) {
			uint256 points = _calculatePointsAtTimestamp(followerSince, timestamp);
			return points * stampInfo.multiplier;
		}
		return 0;
	}

	/// @dev Calculates total points for a specific stamp at a given timestamp
	/// @param stampInfo The StampInfo struct containing stamp and multiplier information
	/// @param timestamp The timestamp at which to calculate total points
	/// @return The calculated total points for the stamp
	function _calculateTotalPointsForStamp(
		StampInfo storage stampInfo,
		uint256 timestamp
	) private view returns (uint256) {
		uint256 totalPoints;
		uint256 stampTotalSupply = stampInfo.stamp.totalSupply();

		for (uint256 j = 1; j <= stampTotalSupply; ) {
			uint256 followerSince = stampInfo.stamp.followStartTimestamp(j);
			if (followerSince != 0 && followerSince <= timestamp) {
				uint256 points = _calculatePointsAtTimestamp(followerSince, timestamp);
				totalPoints += points * stampInfo.multiplier;
			}
			unchecked {
				++j;
			}
		}
		return totalPoints;
	}

	/// @dev Calculates points based on the duration of following using a square root formula
	/// @param followerSince The timestamp when the user started following
	/// @param timestamp The current timestamp
	/// @return The calculated points
	function _calculatePointsAtTimestamp(
		uint256 followerSince,
		uint256 timestamp
	) private pure returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		return (Math.sqrt(durationInSeconds * 1e18) * 1e9) / 293938769;
	}
}
