// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoints } from "./IPoints.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";
import { IPointsStampView } from "./IPointsStampView.sol";

/// @title IMultipleFollowerSincePoints - Interface for managing points based on multiple follower durations
/// @notice This interface defines the contract for a non-transferable token system that awards points based on multiple follower duration criteria
/// @dev Extends IPoints interface with additional functions specific to managing multiple follower-since stamps and their corresponding point multipliers
interface IMultipleFollowerSincePoints is IPoints, IPointsStampView {
	/// @notice Custom error thrown when input arrays have mismatched lengths
	/// @dev This error is used in functions that expect arrays of equal length
	error ArrayLengthMismatch();

	/// @notice Struct to encapsulate information about each follower stamp and its point multiplier
	/// @dev Combines an IFollowerSinceStamp with its corresponding point multiplier for efficient storage and retrieval
	struct StampInfo {
		IFollowerSinceStamp stamp; /// @dev The follower-since stamp contract
		uint256 multiplier; /// @dev The point multiplier associated with this stamp
	}

	/// @notice Struct combining PointsView and PointsStampView for a comprehensive view
	/// @dev Provides a complete snapshot of the Points system and a user's stamps
	struct MultipleFollowerSincePointsView {
		PointsView points; /// @dev General data about the Points system
		PointsStampView[] stamps; /// @dev Array of PointsStampView structs for each registered stamp
	}

	/// @notice Retrieves the complete array of stamp information
	/// @dev This function returns all registered stamps and their multipliers used in the contract
	/// @return An array of StampInfo structs containing all registered stamps and their corresponding multipliers
	function stamps() external view returns (StampInfo[] memory);

	/// @notice Retrieves a comprehensive view of the Points system and a specific user's data
	/// @dev This function should return all relevant information about the Points system and the specified user
	/// @param user The address of the user to query
	/// @return A MultipleFollowerSincePointsView struct containing both system-wide and user-specific information
	function getMultipleFollowerSincePointsView(
		address user
	) external view returns (MultipleFollowerSincePointsView memory);
}
