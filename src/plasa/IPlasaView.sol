// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStampView } from "../stamps/interfaces/IStampView.sol";
import { ISpaceView } from "../spaces/interfaces/ISpaceView.sol";

/// @title IPlasaView Interface
/// @dev Interface for viewing Plasa data, including user information, stamps, and spaces
interface IPlasaView {
	/// @notice Struct to hold Plasa contract data
	/// @dev Contains the contract address, chain ID, and version information
	struct PlasaData {
		address contractAddress;
		uint256 chainId;
		string version;
	}

	/// @notice Struct to hold Plasa user data
	/// @dev Currently only contains the username, but can be extended in the future
	struct PlasaUser {
		string username;
	}

	/// @notice Struct to hold a complete view of Plasa data
	/// @dev Includes PlasaData, PlasaUser, stamps, and spaces
	struct PlasaView {
		PlasaData data;
		PlasaUser user;
		IStampView.StampView[] stamps;
		ISpaceView.SpacePreview[] spaces;
	}

	/// @notice Retrieves the complete Plasa view for a given user
	/// @dev This function aggregates all Plasa-related data for the specified user
	/// @param user The address of the user to get the Plasa view for
	/// @return A PlasaView struct containing all relevant Plasa data for the user
	function getPlasaView(address user) external view returns (PlasaView memory);
}
