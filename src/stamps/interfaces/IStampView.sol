// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IStampView Interface
/// @notice This interface defines the structure and function for viewing stamp data
/// @dev Implement this interface to create a contract that provides stamp viewing functionality
interface IStampView {
	/// @notice Enum representing different types of stamps
	/// @dev Add new stamp types here as needed
	enum StampType {
		Null,
		AccountOwnership,
		FollowerSince
	}

	/// @notice Struct containing general data about a stamp
	/// @dev This struct holds common properties for all stamp types
	struct StampData {
		address contractAddress; /// @dev Address of the contract that issued the stamp
		StampType stampType; /// @dev Type of the stamp
		string name; /// @dev Name of the stamp
		string symbol; /// @dev Symbol or short identifier for the stamp
		uint256 totalSupply; /// @dev Total number of this stamp type issued
		bytes specific; /// @dev Additional data specific to the stamp type
	}

	/// @notice Struct containing user-specific data for a stamp
	/// @dev This struct holds data relevant to a specific user's ownership of a stamp
	struct StampUser {
		bool owns; /// @dev Whether the user owns this stamp
		uint256 stampId; /// @dev Unique identifier of the stamp for this user
		uint256 mintingTimestamp; /// @dev Timestamp when the stamp was minted for this user
		uint256 currentValue; /// @dev The value of the stamp for this user
		bytes specific; /// @dev Additional data specific to the stamp type
	}

	/// @notice Struct combining stamp data and user-specific data
	/// @dev This struct provides a complete view of a stamp for a specific user
	struct StampView {
		StampData data; /// @dev General stamp data
		StampUser user; /// @dev User-specific stamp data
	}

	/// @notice Retrieves the stamp view for a given user
	/// @dev This function should return all stamp-related data for the specified user
	/// @param user The address of the user whose stamp view is being requested
	/// @return A StampView struct containing the stamp data and user-specific information
	function getStampView(address user) external view returns (StampView memory);
}
