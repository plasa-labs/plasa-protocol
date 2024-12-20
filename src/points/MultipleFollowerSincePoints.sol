// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points, IPoints } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IMultipleFollowerSincePoints } from "./interfaces/IMultipleFollowerSincePoints.sol";

/// @title MultipleFollowerSincePoints - A non-transferable token based on multiple follower durations
/// @notice This contract calculates points based on how long a user has been a follower across multiple accounts
/// @dev Inherits from Points and implements IMultipleFollowerSincePoints
contract MultipleFollowerSincePoints is Points, IMultipleFollowerSincePoints {
	// State Variables
	StampInfo[] private _stamps;
	uint256 private immutable _stampCount;

	/// @notice Initializes the contract with multiple follower stamps and their multipliers
	/// @param _stampAddresses Array of follower stamp contract addresses
	/// @param _multipliers Array of multipliers corresponding to each stamp
	/// @param _name Name of the token
	/// @param _symbol Symbol of the token
	constructor(
		address[] memory _stampAddresses,
		uint256[] memory _multipliers,
		string memory _name,
		string memory _symbol,
		address _plasaContract
	) Points(_name, _symbol, 18, _plasaContract) {
		if (_stampAddresses.length != _multipliers.length) revert ArrayLengthMismatch();
		for (uint256 i = 0; i < _stampAddresses.length; ++i) {
			_stamps.push(StampInfo(IFollowerSinceStamp(_stampAddresses[i]), _multipliers[i]));
		}
		_stampCount = _stampAddresses.length;
	}

	// External Functions

	/// @inheritdoc IMultipleFollowerSincePoints
	function stamps() external view returns (StampInfo[] memory) {
		return _stamps;
	}

	/// @inheritdoc IMultipleFollowerSincePoints
	function getMultipleFollowerSincePointsView(
		address user
	) external view returns (MultipleFollowerSincePointsView memory) {
		return MultipleFollowerSincePointsView({ points: getPointsView(user), stamps: _getPointsStampViews(user) });
	}

	// Internal Functions

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

	// Private Functions

	/// @dev Calculates points for a specific stamp and account at a given timestamp
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
	function _calculatePointsAtTimestamp(
		uint256 followerSince,
		uint256 timestamp
	) internal pure virtual returns (uint256) {
		uint256 durationInSeconds = timestamp - followerSince;
		// Convert duration to days with 18 decimal precision
		// 1e18 * duration / seconds_per_day
		return (durationInSeconds * 1e18) / 86400;
	}

	function _getPointsStampViews(address user) private view returns (PointsStampView[] memory) {
		PointsStampView[] memory views = new PointsStampView[](_stampCount);

		for (uint256 i = 0; i < _stampCount; ) {
			StampInfo storage stampInfo = _stamps[i];
			IFollowerSinceStamp stamp = stampInfo.stamp;

			// Get the stamp view from the stamp contract
			IFollowerSinceStamp.StampView memory stampView = stamp.getStampView(user);

			// Calculate points for this stamp
			uint256 followerSince = stamp.getFollowerSinceTimestamp(user);
			uint256 points = 0;
			if (followerSince != 0 && followerSince <= block.timestamp) {
				points = _calculatePointsAtTimestamp(followerSince, block.timestamp) * stampInfo.multiplier;
			}

			// Create the points stamp data
			PointsStampData memory data = PointsStampData({
				contractAddress: address(stamp),
				stampType: stampView.data.stampType,
				name: stampView.data.name,
				symbol: stampView.data.symbol,
				totalSupply: stampView.data.totalSupply,
				specific: stampView.data.specific,
				multiplier: stampInfo.multiplier
			});

			// Create the points stamp user data
			PointsStampUser memory userData = PointsStampUser({
				owns: stampView.user.owns,
				stampId: stampView.user.stampId,
				mintingTimestamp: stampView.user.mintingTimestamp,
				specific: stampView.user.specific,
				points: points
			});

			// Combine into final view
			views[i] = PointsStampView({ data: data, user: userData });

			unchecked {
				++i;
			}
		}

		return views;
	}

	function _getStampsView(address user) private view returns (PointsStampView[] memory) {
		return _getPointsStampViews(user);
	}

	/// @inheritdoc Points
	function _getTotalUniqueHolders() internal view override returns (uint256 maxHolders) {
		// Sum up all stamp supplies for a conservative upper bound
		for (uint256 i; i < _stampCount; ) {
			unchecked {
				maxHolders += _stamps[i].stamp.totalSupply();
				++i;
			}
		}
	}

	/// @inheritdoc Points
	function _collectHolders(Holder[] memory holders) internal view override returns (uint256 totalHolders) {
		// Use a fixed-size mapping in memory for deduplication
		bytes32[] memory seenAddresses = new bytes32[](_getTotalUniqueHolders());
		uint256 seenCount;

		for (uint256 i; i < _stampCount; ) {
			uint256 stampSupply = _stamps[i].stamp.totalSupply();
			for (uint256 j = 1; j <= stampSupply; ) {
				address owner = _stamps[i].stamp.ownerOf(j);
				bytes32 ownerHash = keccak256(abi.encodePacked(owner));

				// Check if holder already processed
				bool isDuplicate;
				for (uint256 k; k < seenCount; ) {
					if (seenAddresses[k] == ownerHash) {
						isDuplicate = true;
						break;
					}
					unchecked {
						++k;
					}
				}

				if (!isDuplicate) {
					seenAddresses[seenCount] = ownerHash;
					unchecked {
						++seenCount;
					}
					holders[totalHolders] = Holder({ user: owner, balance: balanceOf(owner) });
					unchecked {
						++totalHolders;
					}
				}
				unchecked {
					++j;
				}
			}
			unchecked {
				++i;
			}
		}
	}
}
