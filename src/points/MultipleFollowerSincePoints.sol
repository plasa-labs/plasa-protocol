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
	/// @notice Custom error for when the input arrays have mismatched lengths
	StampInfo[] private _stamps;

	/// @notice Initializes the MultipleFollowerSincePoints contract
	/// @param _stampAddresses An array of IFollowerSinceStamp addresses
	/// @param _multipliers An array of multipliers corresponding to each stamp
	/// @param _name The name of the token
	/// @param _symbol The symbol of the token
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

	/// @inheritdoc IMultipleFollowerSincePoints
	function balanceOf(
		address account
	) public view override(IMultipleFollowerSincePoints, IERC20) returns (uint256) {
		uint256 totalPoints = 0;
		for (uint256 i = 0; i < _stamps.length; i++) {
			uint256 followerSince = _stamps[i].stamp.getFollowerSinceTimestamp(account);
			if (followerSince != 0) {
				totalPoints += _calculatePoints(followerSince) * _stamps[i].multiplier;
			}
		}
		return totalPoints;
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function totalSupply()
		public
		view
		override(IMultipleFollowerSincePoints, IERC20)
		returns (uint256)
	{
		uint256 totalPoints = 0;
		for (uint256 i = 0; i < _stamps.length; i++) {
			uint256 stampTotalSupply = _stamps[i].stamp.totalSupply();
			for (uint256 j = 1; j <= stampTotalSupply; j++) {
				uint256 followerSince = _stamps[i].stamp.followStartTimestamp(j);
				if (followerSince != 0) {
					totalPoints += _calculatePoints(followerSince) * _stamps[i].multiplier;
				}
			}
		}
		return totalPoints;
	}

	/// @dev Calculates points based on the duration of following using a square root formula
	/// @param followerSince The timestamp when the user started following
	/// @return The calculated points
	function _calculatePoints(uint256 followerSince) private view returns (uint256) {
		// Calculate the duration of following in seconds
		uint256 durationInSeconds = block.timestamp - followerSince;

		// Apply the square root formula to calculate points:
		// 1. Multiply duration by 1e18 to increase precision before taking the square root
		// 2. Take the square root of the scaled duration
		// 3. Multiply by 1e9 to further adjust the scale
		// 4. Divide by 293938769 (approximately sqrt(365 days * 86400 seconds/day) * 1e9)
		//    This normalization factor ensures that 1 year of following equals roughly 1e18 points
		return (Math.sqrt(durationInSeconds * 1e18) * 1e9) / 293938769;
	}
}
