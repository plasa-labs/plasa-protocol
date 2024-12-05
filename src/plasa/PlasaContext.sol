// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Title: PlasaContext Contract
// Developer Notice: This contract serves as a base for managing user context in the Plasa system.
// It interacts with the IPlasa interface to check user registration and retrieve usernames.

import { IPlasa } from "./interfaces/IPlasa.sol";
import { IPlasaContext } from "./interfaces/IPlasaContext.sol";

/**
 * @title PlasaContext
 * @dev This abstract contract implements the IPlasaContext interface.
 * It provides functionality to check if a user is registered and to retrieve their username.
 */
abstract contract PlasaContext is IPlasaContext {
	// Instance of the IPlasa contract to interact with user data
	IPlasa public plasa;

	/**
	 * @dev Constructor that sets the address of the IPlasa contract.
	 * @param _plasaContract The address of the deployed IPlasa contract.
	 */
	constructor(address _plasaContract) {
		plasa = IPlasa(_plasaContract);
	}

	/**
	 * @dev Modifier that checks if the caller is a registered user.
	 * Reverts with NotRegistered error if the user is not registered.
	 */
	modifier onlyRegistered() {
		if (!_isRegistered(msg.sender)) revert NotRegistered();
		_;
	}

	/**
	 * @dev Internal function to check if a user is registered.
	 * @param user The address of the user to check.
	 * @return bool indicating whether the user is registered.
	 */
	function _isRegistered(address user) internal view returns (bool) {
		return plasa.isRegistered(user);
	}

	/**
	 * @dev Internal function to retrieve the username of a registered user.
	 * @param user The address of the user whose username is to be retrieved.
	 * @return string memory The username of the user.
	 */
	function _getUsername(address user) internal view returns (string memory) {
		return plasa.getUsername(user);
	}

	function _getUsers() internal view returns (address[] memory) {
		return plasa.getAllUsers();
	}
}
