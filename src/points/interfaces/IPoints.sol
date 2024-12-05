// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IPointsView } from "./IPointsView.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC20Metadata } from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import { IStamp } from "../../stamps/interfaces/IStamp.sol";

/// @title IPoints - Interface for a non-transferable ERC20-like token
/// @notice This interface defines the functions for a non-transferable token system
interface IPoints is IERC20Metadata, IPointsView {
	event StampAdded(address indexed stampAddress, uint256 multiplier);

	/// @notice Struct representing a holder with their address and balance
	struct Holder {
		address user;
		uint256 balance;
	}

	/// @notice Struct to encapsulate information about each stamp and its point multiplier
	/// @dev Combines an IStamp with its corresponding point multiplier for efficient storage and retrieval
	struct StampInfo {
		IStamp stamp; /// @dev The stamp contract
		uint256 multiplier; /// @dev The point multiplier associated with this stamp
	}

	/// @notice Error thrown when attempting to transfer tokens
	error NonTransferable();

	/// @notice Error thrown when attempting to access an out of bounds index
	error IndexOutOfBounds();

	/// @notice Custom error thrown when input arrays have mismatched lengths
	/// @dev This error is used in functions that expect arrays of equal length
	error ArrayLengthMismatch();

	/// @notice Returns the balance of a user at a specific timestamp
	/// @param user The address of the user
	/// @param timestamp The timestamp at which to check the balance
	/// @return The balance of the user at the given timestamp
	function balanceAtTimestamp(address user, uint256 timestamp) external view returns (uint256);

	/// @notice Returns the total supply at a specific timestamp
	/// @param timestamp The timestamp at which to check the total supply
	/// @return The total supply at the given timestamp
	function totalSupplyAtTimestamp(uint256 timestamp) external view returns (uint256);

	/// @notice Returns the top holders between specified indices
	/// @param start The starting index (inclusive)
	/// @param end The ending index (exclusive)
	/// @return Array of holders sorted by point balance
	function getTopHolders(uint256 start, uint256 end) external view returns (HolderData[] memory);

	/// @notice Returns all registered stamps and their multipliers
	/// @return Array of StampInfo structs
	function getStamps() external view returns (StampInfo[] memory);
}
