// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStamp } from "./IStamp.sol";

/// @title IFollowerSinceStamp
/// @notice Interface for the FollowerSinceStamp contract
interface IFollowerSinceStamp is IStamp {
	/// @notice Emitted when a new follower since stamp is minted
	/// @param platform The platform where the following relationship exists
	/// @param followed The account being followed
	/// @param since The timestamp when the following relationship started
	/// @param stampId The ID of the minted stamp
	/// @param recipient The address receiving the stamp
	event FollowerSince(
		string indexed platform,
		string indexed followed,
		uint256 since,
		uint256 indexed stampId,
		address recipient
	);

	/// @notice Error thrown when an invalid recipient address is provided
	error InvalidRecipient();

	/// @notice The platform where the following relationship exists
	function PLATFORM() external view returns (string memory);

	/// @notice The account being followed
	function FOLLOWED() external view returns (string memory);

	/// @notice Mapping of stamp IDs to their follow start timestamps
	function followStartTimestamp(uint256 stampId) external view returns (uint256);

	/// @notice Mints a new follower since stamp
	/// @param since The timestamp when the following relationship started
	/// @param deadline The deadline for the signature to be valid
	/// @param signature The signature authorizing the mint
	/// @return The ID of the minted stamp
	function mintWithSignature(uint256 since, uint256 deadline, bytes calldata signature) external returns (uint256);

	/// @notice Mints a new follower since stamp by the minter
	/// @param user The address of the follower
	/// @param since The timestamp when the following relationship started
	/// @return The ID of the minted stamp
	function mintByMinter(address user, uint256 since) external returns (uint256);

	/// @notice Retrieves the follower since timestamp for a given address
	/// @param user The address of the follower
	/// @return The timestamp when the following relationship started, or 0 if not found
	function getFollowerSinceTimestamp(address user) external view returns (uint256);
}
