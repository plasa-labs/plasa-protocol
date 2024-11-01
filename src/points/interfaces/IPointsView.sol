// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPointsView - View interface for a non-transferable ERC20-like token system
/// @notice This interface defines the read-only functions for querying the state of a non-transferable token system
/// @dev Implement this interface for contracts that need to provide a view into the Points system
interface IPointsView {
	struct Holder {
		address user;
		uint256 balance;
	}

	/// @notice Struct containing basic information about the Points contract
	/// @dev This struct should be used to return general data about the Points system
	struct PointsData {
		address contractAddress; /// @notice The address of the Points contract
		string name; /// @notice The name of the Points token
		string symbol; /// @notice The symbol of the Points token
		uint256 totalSupply; /// @notice The total supply of Points
		Holder[] top10Holders; /// @notice The top 10 holders of the Points
	}

	/// @notice Struct containing user-specific information
	/// @dev This struct should be used to return data specific to a user's Points account
	struct PointsUser {
		uint256 currentBalance; /// @notice The current balance of Points for the user
	}

	/// @notice Struct combining PointsData and PointsUser for a comprehensive view
	/// @dev This struct provides a complete snapshot of the Points system and a user's status
	struct PointsView {
		PointsData data; /// @notice General data about the Points system
		PointsUser user; /// @notice User-specific data
	}

	/// @notice Retrieves a comprehensive view of the Points system and a specific user's data
	/// @dev This function should return all relevant information about the Points system and the specified user
	/// @param user The address of the user to query
	/// @return A PointsView struct containing both system-wide and user-specific information
	function getPointsView(address user) external view returns (PointsView memory);
}
