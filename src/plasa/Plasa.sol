// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Importing necessary contracts and interfaces
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { INames } from "../names/INames.sol";
import { IPlasa, IPlasaView } from "./interfaces/IPlasa.sol";

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

	/**
	 * @dev Retrieves the usernames associated with an array of user addresses.
	 * @param users The addresses of the users whose usernames are to be retrieved.
	 * @return string[] memory An array of usernames corresponding to the input addresses.
	 */
	function getUsernames(address[] memory users) public view returns (string[] memory) {
		string[] memory usernames = new string[](users.length);
		for (uint256 i = 0; i < users.length; i++) {
			usernames[i] = getUsername(users[i]);
		}
		return usernames;
	}

	/**
	 * @dev Retrieves the username data associated with a given user address.
	 * @param user The address of the user whose username data is to be retrieved.
	 * @return UsernameData memory The username data of the user.
	 */
	function getUsernameData(address user) public view returns (UsernameData memory) {
		return UsernameData({ user: user, name: getUsername(user) });
	}

	/**
	 * @dev Retrieves the username data associated with an array of user addresses.
	 * @param users The addresses of the users whose username data is to be retrieved.
	 * @return UsernameData[] memory An array of UsernameData structures corresponding to the input addresses.
	 */
	function getUsernamesData(address[] memory users) public view returns (UsernameData[] memory) {
		UsernameData[] memory usernameData = new UsernameData[](users.length);
		for (uint256 i = 0; i < users.length; i++) {
			usernameData[i] = getUsernameData(users[i]);
		}
		return usernameData;
	}

	/// @inheritdoc IPlasaView
	function getPlasaView(address user) external view returns (PlasaView memory) {
		return
			PlasaView({
				data: PlasaData({ contractAddress: address(this), namesContract: address(names) }),
				user: PlasaUser({ isRegistered: isRegistered(user), username: getUsername(user) })
			});
	}
}
