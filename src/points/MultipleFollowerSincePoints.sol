// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IMultipleFollowerSincePoints } from "./interfaces/IMultipleFollowerSincePoints.sol";

/// @title MultipleFollowerSincePoints - A non-transferable token based on multiple follower durations
/// @notice This contract calculates points based on how long a user has been a follower across multiple accounts
/// @dev Inherits from Points and implements IMultipleFollowerSincePoints, using multiple IFollowerSinceStamp for duration calculation
contract MultipleFollowerSincePoints is Points, IMultipleFollowerSincePoints {
	StampInfo[] private _stamps;
	uint256 private immutable _stampCount;

	constructor(
		address[] memory _stampAddresses,
		uint256[] memory _multipliers,
		string memory _name,
		string memory _symbol
	) Points(_name, _symbol, 18) {
		if (_stampAddresses.length != _multipliers.length) revert ArrayLengthMismatch();
		for (uint256 i = 0; i < _stampAddresses.length; ++i) {
			_stamps.push(StampInfo(IFollowerSinceStamp(_stampAddresses[i]), _multipliers[i]));
		}
		_stampCount = _stampAddresses.length;
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function stamps() external view returns (StampInfo[] memory) {
		return _stamps;
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function stampByIndex(uint256 index) external view returns (StampInfo memory) {
		if (index >= _stamps.length) revert IndexOutOfBounds();
		return _stamps[index];
	}

	/// @inheritdoc Points
	function _balanceAtTimestamp(address account, uint256 timestamp) internal view override returns (uint256) {
		uint256 totalPoints;

		for (uint256 i; i < _stampCount; ) {
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

		for (uint256 i; i < _stampCount; ) {
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
			return _calculatePointsAtTimestamp(followerSince, timestamp) * stampInfo.multiplier;
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

		if (stampTotalSupply == 0) return 0;

		IFollowerSinceStamp stamp = stampInfo.stamp;

		for (uint256 j = 1; j <= stampTotalSupply; ) {
			uint256 followerSince = stamp.followStartTimestamp(j);
			if (followerSince != 0 && followerSince <= timestamp) {
				totalPoints += _calculatePointsAtTimestamp(followerSince, timestamp) * stampInfo.multiplier;
			}
			unchecked {
				++j;
			}
		}
		return totalPoints;
	}

	/// @notice Calculates points based on the duration of following using a linear formula
	/// @dev Uses a linear calculation:
	///      - 1 day (86400 seconds) = 1 point
	///      - 2 days (172800 seconds) = 2 points
	///      - Formula: durationInSeconds / 86400
	/// @param followerSince Timestamp when the user started following
	/// @param timestamp Current timestamp for calculation
	/// @return uint256 Calculated points, scaled to 18 decimal places
	function _calculatePointsAtTimestamp(uint256 followerSince, uint256 timestamp) private pure returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		// Convert duration to days with 18 decimal precision
		// 1e18 * duration / seconds_per_day
		return (durationInSeconds * 1e18) / 86400;
	}

	/// @notice Gets the top holders between specified indices
	/// @param start The starting index (inclusive)
	/// @param end The ending index (exclusive)
	/// @return addresses Array of addresses sorted by point balance
	/// @return balances Array of corresponding point balances
	function getTopHolders(
		uint256 start,
		uint256 end
	) external view returns (address[] memory addresses, uint256[] memory balances) {
		if (start >= end) revert IndexOutOfBounds();

		// Get total unique holders
		uint256 totalHolders = 0;
		uint256 stampTotalSupply;
		address[] memory tempHolders = new address[](_getTotalUniqueHolders());

		// Collect unique holders across all stamps
		for (uint256 i; i < _stampCount; ) {
			stampTotalSupply = _stamps[i].stamp.totalSupply();
			for (uint256 j = 1; j <= stampTotalSupply; ) {
				address holder = _stamps[i].stamp.ownerOf(j);
				if (!_isAddressInArray(tempHolders, holder, totalHolders)) {
					tempHolders[totalHolders++] = holder;
				}
				unchecked {
					++j;
				}
			}
			unchecked {
				++i;
			}
		}

		// If no holders, return empty arrays
		if (totalHolders == 0) {
			return (new address[](0), new uint256[](0));
		}

		// Validate start index
		if (start >= totalHolders) revert IndexOutOfBounds();

		// Adjust end if it exceeds total holders
		end = Math.min(end, totalHolders);
		uint256 length = end - start;

		// Create return arrays
		addresses = new address[](length);
		balances = new uint256[](length);

		// Create temporary arrays for sorting
		address[] memory sortedAddresses = new address[](totalHolders);
		uint256[] memory sortedBalances = new uint256[](totalHolders);

		// Get balances and sort
		for (uint256 i = 0; i < totalHolders; ) {
			sortedAddresses[i] = tempHolders[i];
			sortedBalances[i] = balanceOf(tempHolders[i]);
			unchecked {
				++i;
			}
		}

		// Replace insertion sort with optimized quicksort for larger datasets
		if (totalHolders > 10) {
			_quickSort(sortedAddresses, sortedBalances, 0, int256(totalHolders - 1));
		} else {
			// Keep insertion sort for small arrays
			for (uint256 i = 1; i < totalHolders; ) {
				uint256 j = i;
				while (j > 0 && sortedBalances[j - 1] < sortedBalances[j]) {
					(sortedBalances[j], sortedBalances[j - 1]) = (sortedBalances[j - 1], sortedBalances[j]);
					(sortedAddresses[j], sortedAddresses[j - 1]) = (sortedAddresses[j - 1], sortedAddresses[j]);
					unchecked {
						--j;
					}
				}
				unchecked {
					++i;
				}
			}
		}

		// Copy requested range to return arrays
		for (uint256 i = 0; i < length; ) {
			addresses[i] = sortedAddresses[start + i];
			balances[i] = sortedBalances[start + i];
			unchecked {
				++i;
			}
		}
	}

	/// @dev Helper function to check if address exists in array
	function _isAddressInArray(address[] memory array, address addr, uint256 length) private pure returns (bool) {
		for (uint256 i = 0; i < length; ) {
			if (array[i] == addr) return true;
			unchecked {
				++i;
			}
		}
		return false;
	}

	/// @dev Helper function to get total unique holders across all stamps
	/// @return maxHolders A conservative estimate of maximum possible unique holders
	function _getTotalUniqueHolders() private view returns (uint256 maxHolders) {
		// Find the stamp with maximum supply as a better estimate
		for (uint256 i; i < _stampCount; ) {
			uint256 supply = _stamps[i].stamp.totalSupply();
			maxHolders = Math.max(maxHolders, supply);
			unchecked {
				++i;
			}
		}
	}

	/// @dev Quicksort implementation for more efficient sorting of larger arrays
	function _quickSort(address[] memory addresses, uint256[] memory balances, int256 left, int256 right) private pure {
		if (left >= right) return;

		int256 i = left;
		int256 j = right;
		uint256 pivot = balances[uint256(left + (right - left) / 2)];

		while (i <= j) {
			while (balances[uint256(i)] > pivot) i++;
			while (balances[uint256(j)] < pivot) j--;

			if (i <= j) {
				(balances[uint256(i)], balances[uint256(j)]) = (balances[uint256(j)], balances[uint256(i)]);
				(addresses[uint256(i)], addresses[uint256(j)]) = (addresses[uint256(j)], addresses[uint256(i)]);
				i++;
				j--;
			}
		}

		if (left < j) _quickSort(addresses, balances, left, j);
		if (i < right) _quickSort(addresses, balances, i, right);
	}
}
