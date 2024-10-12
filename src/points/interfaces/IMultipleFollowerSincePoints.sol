// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoints } from "./IPoints.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";

/// @title IMultipleFollowerSincePoints - Interface for managing points based on multiple follower durations
/// @notice This interface defines the contract for a non-transferable token system that awards points based on multiple follower duration criteria
/// @dev Extends IPoints interface with additional functions specific to managing multiple follower-since stamps and their corresponding point multipliers
interface IMultipleFollowerSincePoints is IPoints {
	/// @notice Custom error thrown when input arrays have mismatched lengths
	/// @dev This error is used in functions that expect arrays of equal length
	error ArrayLengthMismatch();

	/// @notice Struct to encapsulate information about each follower stamp and its point multiplier
	/// @dev Combines an IFollowerSinceStamp with its corresponding point multiplier for efficient storage and retrieval
	struct StampInfo {
		IFollowerSinceStamp stamp; /// @dev The follower-since stamp contract
		uint256 multiplier; /// @dev The point multiplier associated with this stamp
	}

	/// @notice Retrieves the complete array of stamp information
	/// @dev This function returns all registered stamps and their multipliers used in the contract
	/// @return An array of StampInfo structs containing all registered stamps and their corresponding multipliers
	function stamps() external view returns (StampInfo[] memory);

	/// @notice Fetches the stamp information at a specific index in the stamps array
	/// @dev This function should revert if the provided index is out of bounds
	/// @param index The zero-based index of the stamp in the stamps array
	/// @return A StampInfo struct containing the stamp and multiplier information at the given index
	function stampByIndex(uint256 index) external view returns (StampInfo memory);
}
