// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";

/// @title IMultipleFollowerSincePoints - Interface for MultipleFollowerSincePoints contract
/// @notice Defines the interface for a non-transferable token based on multiple follower durations
/// @dev Inherits from IERC20 and defines additional functions specific to MultipleFollowerSincePoints
interface IMultipleFollowerSincePoints is IERC20 {
	/// @notice Custom error for when the input arrays have mismatched lengths
	error ArrayLengthMismatch();

	/// @notice Struct to store information about each follower stamp
	/// @dev Combines a FollowerSinceStamp with its corresponding point multiplier
	struct StampInfo {
		IFollowerSinceStamp stamp;
		uint256 multiplier;
	}

	/// @notice Retrieves the array of all stamp information
	/// @dev This function returns all stamps and their multipliers used in the contract
	/// @return An array of StampInfo structs containing all stamps and their multipliers
	function stamps() external view returns (StampInfo[] memory);

	/// @notice Returns the stamp information at a specific index
	/// @dev Throws an error if the index is out of bounds
	/// @param index The index of the stamp in the array
	/// @return The StampInfo struct at the given index
	function stampByIndex(uint256 index) external view returns (StampInfo memory);

	/// @notice Calculates the balance of points for a given account
	/// @dev Iterates through all stamps, calculates points for each, and applies the multiplier
	/// @param account The address of the account to check
	/// @return The total points balance for the account, summed across all stamps
	function balanceOf(address account) external view returns (uint256);

	/// @notice Calculates the total supply of points across all stamps
	/// @dev Iterates through all stamps and all followers, calculating points for each
	/// @return The total supply of points, summed across all stamps and all followers
	function totalSupply() external view returns (uint256);
}
