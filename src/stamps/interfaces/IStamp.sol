// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import { IStampView } from "./IStampView.sol";

/// @title IStamp Interface
/// @notice This interface defines the contract for a non-transferable ERC721 token called "Stamp"
/// @dev Inherits from IERC721Enumerable and IStampView, adding custom functionality for minting and ownership
interface IStamp is IERC721Enumerable, IStampView {
	/// @notice Thrown when a user attempts to mint a stamp they already own
	/// @param user The address of the user attempting to mint
	/// @param stampId The ID of the existing stamp
	error AlreadyMintedStamp(address user, uint256 stampId);

	/// @notice Thrown when the provided signature for minting is invalid
	error InvalidSignature();

	/// @notice Thrown when the deadline for minting has expired
	/// @param deadline The timestamp of the minting deadline
	/// @param currentTimestamp The current block timestamp
	error DeadlineExpired(uint256 deadline, uint256 currentTimestamp);

	/// @notice Thrown when attempting to transfer, approve, or perform any operation that would change token ownership
	error NonTransferableStamp();

	/// @notice Thrown when querying the mint date of a non-existent token
	/// @param tokenId The ID of the non-existent token
	error TokenDoesNotExist(uint256 tokenId);

	/// @notice Returns the address of the signer authorized to sign minting requests
	/// @return The address of the authorized signer
	/// @dev This function should be implemented to return the current authorized signer's address
	function signer() external view returns (address);

	/// @notice Retrieves the minting date of a specific token
	/// @param tokenId The ID of the token to query
	/// @return The timestamp when the token was minted
	function mintingTimestamps(uint256 tokenId) external view returns (uint256);

	/// @notice Retrieves the type of stamp
	/// @return The type of stamp
	function stampType() external view returns (IStampView.StampType);

	// The following functions are inherited from IERC721Enumerable:

	/// @notice Returns the token ID at a given index of the tokens list of the requested owner
	/// @param owner Address owning the tokens list to be accessed
	/// @param index Index of the token to be returned
	/// @return The token ID at the given index of the tokens list owned by the requested address
	// function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256);

	/// @notice Returns the total amount of tokens stored by the contract
	/// @return The total number of tokens
	// function totalSupply() external view returns (uint256);

	/// @notice Returns a token ID at a given index of all the tokens stored by the contract
	/// @param index Index of the token to be returned
	/// @return The token ID at the given index
	// function tokenByIndex(uint256 index) external view returns (uint256);
}
