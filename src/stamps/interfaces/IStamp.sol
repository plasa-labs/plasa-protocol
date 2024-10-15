// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import { IStampView } from "./IStampView.sol";

/// @title IStamp Interface
/// @notice This interface defines the contract for a non-transferable ERC721 token called "Stamp"
/// @dev Inherits from IERC721Enumerable, adding custom functionality for minting and ownership
interface IStamp is IERC721Enumerable, IStampView {
	/// @notice Thrown when a user attempts to mint a stamp they already own
	/// @param user The address of the user
	/// @param stampId The ID of the existing stamp
	error AlreadyMintedStamp(address user, uint256 stampId);

	/// @notice Thrown when the provided signature is invalid
	error InvalidSignature();

	/// @notice Thrown when the deadline for minting has expired
	/// @param deadline The timestamp of the deadline
	/// @param currentTimestamp The current block timestamp
	error DeadlineExpired(uint256 deadline, uint256 currentTimestamp);

	/// @notice Thrown when attempting to transfer, approve, or perform any operation that would change token ownership
	error NonTransferableStamp();

	/// @notice Thrown when querying the mint date of a non-existent token
	/// @param tokenId The ID of the non-existent token
	error TokenDoesNotExist(uint256 tokenId);

	/// @notice Returns the address of the signer authorized to sign minting requests
	/// @return The address of the authorized signer
	function signer() external view returns (address);

	/// @notice Retrieves the minting date of a specific token
	/// @param tokenId The ID of the token to query
	/// @return The timestamp when the token was minted
	/// @dev Reverts with TokenDoesNotExist if the token does not exist
	function getMintDate(uint256 tokenId) external view returns (uint256);

	// Note: The following functions are not explicitly defined here but are inherited from IERC721Enumerable:
	// - tokenOfOwnerByIndex(address owner, uint256 index) → uint256
	// - totalSupply() → uint256
	// - tokenByIndex(uint256 index) → uint256
}
