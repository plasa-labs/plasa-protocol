// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { INames } from "../../names/INames.sol";
import { IPlasaView } from "./IPlasaView.sol";

/// @title IPlasa Interface
/// @dev This interface defines the functions for user registration and username retrieval in the Plasa system.
interface IPlasa is IPlasaView {
	/// @notice Struct to hold username data.
	/// @param user The address of the user.
	/// @param name The username of the user.
	struct UsernameData {
		address user;
		string name;
	}

	/// @notice Checks if a user is registered in the Plasa system.
	/// @param user The address of the user to check.
	/// @return bool Returns true if the user is registered, false otherwise.
	function isRegistered(address user) external view returns (bool);

	/// @notice Retrieves the username associated with a registered user.
	/// @param user The address of the user whose username is to be retrieved.
	/// @return string memory The username of the user.
	function getUsername(address user) external view returns (string memory);

	/// @notice Sets the names contract address.
	/// @param _namesContract The address of the new names contract.
	function setNamesContract(address _namesContract) external;

	/// @notice The names contract interface.
	/// @return INames Returns the names contract.
	function names() external view returns (INames);

	/// @notice Retrieves the username data associated with an array of user addresses.
	/// @param user The address of the user whose username is to be retrieved.
	/// @return UsernameData The username data of the user.
	function getUsernameData(address user) external view returns (UsernameData memory);

	/// @notice Retrieves the usernames associated with an array of user addresses.
	/// @param users The addresses of the users whose usernames are to be retrieved.
	/// @return UsernameData[] memory An array of UsernameData structures corresponding to the input addresses.
	function getUsernamesData(address[] memory users) external view returns (UsernameData[] memory);
}
