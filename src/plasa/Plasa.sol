// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing necessary contracts and interfaces
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { INames } from "../names/INames.sol";
import { IPlasa } from "./interfaces/IPlasa.sol";

/**
 * @title Plasa Contract
 * @dev This contract manages user names and their registration status.
 * It is owned by a single entity that can update the names contract.
 */
contract Plasa is Ownable, IPlasa {
	// Instance of the INames contract to manage user names
	INames public names;

	/**
	 * @dev Constructor to initialize the contract with an owner and names contract address.
	 * @param _owner The address of the contract owner.
	 * @param _namesContract The address of the INames contract.
	 */
	constructor(address _owner, address _namesContract) Ownable(_owner) {
		names = INames(_namesContract);
	}

	/**
	 * @dev Updates the address of the names contract.
	 * @param _namesContract The new address of the INames contract.
	 */
	function setNamesContract(address _namesContract) external onlyOwner {
		names = INames(_namesContract);
	}

	/**
	 * @dev Checks if a user is registered based on their balance in the names contract.
	 * @param user The address of the user to check.
	 * @return bool indicating whether the user is registered.
	 */
	function isRegistered(address user) public view returns (bool) {
		return names.balanceOf(user) > 0;
	}

	/**
	 * @dev Retrieves the username associated with a given user address.
	 * @param user The address of the user whose username is to be retrieved.
	 * @return string memory The username of the user.
	 */
	function getUsername(address user) public view returns (string memory) {
		return names.userToName(user);
	}
}
