// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStamp } from "./IStamp.sol";

/// @title IFollowerSinceStamp
/// @notice Interface for the FollowerSinceStamp contract
interface IFollowerSinceStamp is IStamp {
	/// @dev Struct to hold comprehensive view data for a FollowerSinceStamp
	struct FollowerSinceStampView {
		address stampAddress;
		uint256 totalSupply;
		string stampName;
		string stampSymbol;
		string platform;
		string followedAccount;
		bool userHasStamp;
		uint256 userStampId;
		uint256 userMintingDate;
		uint256 userFollowerSince;
		uint256 timeSinceFollow;
	}

	/// @notice Emitted when a new follower since stamp is minted
	/// @param platform The platform where the following relationship exists
	/// @param followed The account being followed
	/// @param follower The follower's identifier
	/// @param since The timestamp when the following relationship started
	/// @param stampId The ID of the minted stamp
	/// @param recipient The address receiving the stamp
	event FollowerSince(
		string indexed platform,
		string indexed followed,
		string follower,
		uint256 since,
		uint256 indexed stampId,
		address recipient
	);

	/// @notice Error thrown when an invalid recipient address is provided
	error InvalidRecipient();

	/// @notice Error thrown when an invalid follower identifier is provided
	error InvalidFollower();

	/// @notice Error thrown when a follower attempts to mint more than one stamp
	error FollowerAlreadyMinted();

	/// @notice The platform where the following relationship exists
	function PLATFORM() external view returns (string memory);

	/// @notice The account being followed
	function FOLLOWED() external view returns (string memory);

	/// @notice Mapping of stamp IDs to their follow start timestamps
	function followStartTimestamp(uint256 stampId) external view returns (uint256);

	/// @notice Mints a new follower since stamp
	/// @param follower The follower's identifier
	/// @param since The timestamp when the following relationship started
	/// @param deadline The deadline for the signature to be valid
	/// @param signature The signature authorizing the mint
	/// @return The ID of the minted stamp
	function mintStamp(
		string calldata follower,
		uint256 since,
		uint256 deadline,
		bytes calldata signature
	) external returns (uint256);

	/// @notice Retrieves the follower since timestamp for a given address
	/// @param follower The address of the follower
	/// @return The timestamp when the following relationship started, or 0 if not found
	function getFollowerSinceTimestamp(address follower) external view returns (uint256);

	/// @notice Retrieves a comprehensive view of the FollowerSinceStamp for a given user
	/// @param user The address of the user to check
	/// @return A FollowerSinceStampView struct containing all relevant information
	function getFollowerSinceStampView(address user) external view returns (FollowerSinceStampView memory);
}
