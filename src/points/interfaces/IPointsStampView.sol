// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStampView } from "../../stamps/interfaces/IStampView.sol";

/// @title IPointsStampView - View interface for stamps that award points
/// @notice This interface defines the structure for viewing stamps that are associated with points
/// @dev Extends the concept of StampView to include point-related information
interface IPointsStampView {
	/// @notice Struct containing general data about a points-awarding stamp
	/// @dev Extends StampData with point multiplier information
	struct PointsStampData {
		address contractAddress; /// @dev Address of the contract that issued the stamp
		IStampView.StampType stampType; /// @dev Type of the stamp
		string name; /// @dev Name of the stamp
		string symbol; /// @dev Symbol or short identifier for the stamp
		uint256 totalSupply; /// @dev Total number of this stamp type issued
		bytes specific; /// @dev Additional data specific to the stamp type
		uint256 multiplier; /// @dev The point multiplier associated with this stamp
	}

	/// @notice Struct containing user-specific data for a points-awarding stamp
	/// @dev Extends StampUser with points calculation
	struct PointsStampUser {
		bool owns; /// @dev Whether the user owns this stamp
		uint256 stampId; /// @dev Unique identifier of the stamp for this user
		uint256 mintingTimestamp; /// @dev Timestamp when the stamp was minted for this user
		bytes specific; /// @dev Additional data specific to the stamp type
		uint256 points; /// @dev Current points awarded to the user for this stamp
	}

	/// @notice Struct combining points stamp data and user-specific data
	/// @dev Provides a complete view of a points-awarding stamp for a specific user
	struct PointsStampView {
		PointsStampData data; /// @dev General stamp and points data
		PointsStampUser user; /// @dev User-specific stamp and points data
	}
}
