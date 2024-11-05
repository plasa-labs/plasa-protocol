// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { INames } from "../../names/INames.sol";

/// @title IPlasa Interface
/// @dev This interface defines the functions for user registration and username retrieval in the Plasa system.
interface IPlasa {
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
}
