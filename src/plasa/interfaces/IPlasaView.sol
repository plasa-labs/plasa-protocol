// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPlasaView Interface
/// @dev This interface defines the functions for viewing Plasa data.
interface IPlasaView {
	/// @notice Struct to hold Plasa data.
	/// @param contractAddress The address of the Plasa contract.
	/// @param namesContract The address of the Names contract.
	struct PlasaData {
		address contractAddress;
		address namesContract;
	}

	/// @notice Struct to hold Plasa user data.
	/// @param isRegistered Whether the user is registered.
	/// @param username The username of the user.
	struct PlasaUser {
		bool isRegistered;
		string username;
	}

	/// @notice Struct to hold Plasa view data.
	/// @param data The Plasa data.
	/// @param user The Plasa user data.
	struct PlasaView {
		PlasaData data;
		PlasaUser user;
	}

	/// @notice Retrieves the Plasa view data.
	/// @param user The address of the user whose Plasa view data is to be retrieved.
	/// @return PlasaView The Plasa view data.
	function getPlasaView(address user) external view returns (PlasaView memory);
}
