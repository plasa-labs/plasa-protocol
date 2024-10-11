// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStamp } from "./IStamp.sol";

/// @title IAccountOwnershipStamp
/// @notice Interface for managing account ownership stamps
/// @dev Extends the IStamp interface with specific functionality for account ownership
interface IAccountOwnershipStamp is IStamp {
	/// @notice Thrown when the recipient address is invalid
	error InvalidRecipient();

	/// @notice Thrown when a username is already registered
	/// @param username The username that was attempted to be registered
	/// @param stampId The ID of the existing stamp for this username
	/// @param owner The address of the current owner of the username
	error UsernameAlreadyRegistered(string username, uint256 stampId, address owner);

	/// @notice The platform identifier for this stamp
	/// @dev This function should return a unique identifier for the platform (e.g., "Twitter", "GitHub")
	function PLATFORM() external view returns (string memory);

	/// @notice Mints a new account ownership stamp
	/// @dev This function is called to create a new stamp proving ownership of an account
	/// @param id The username to be registered
	/// @param deadline The timestamp after which the signature is no longer valid
	/// @param signature The signature authorizing the minting, typically signed by a trusted authority
	/// @return The ID of the newly minted stamp
	function mintStamp(
		string calldata id,
		uint256 deadline,
		bytes calldata signature
	) external returns (uint256);

	/// @notice Emitted when a new account ownership stamp is minted
	/// @dev This event should be emitted after successfully minting a new stamp
	/// @param platform The platform identifier
	/// @param username The registered username
	/// @param stampId The ID of the minted stamp
	/// @param owner The address of the stamp owner
	event AccountOwner(string platform, string username, uint256 stampId, address owner);
}
