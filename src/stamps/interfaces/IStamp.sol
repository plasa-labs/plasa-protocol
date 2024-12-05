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

	/// @notice Thrown when an invalid minter address is provided
	error InvalidMinter();

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

	/// @notice Retrieves the current value of a specific stamp
	/// @param stampId The ID of the stamp to query
	/// @return The current value of the stamp
	function currentStampValue(uint256 stampId) external view returns (uint256);

	/// @notice Retrieves the current value of a specific user's stamp
	/// @param user The address of the user to query
	/// @return The current value of the user's stamp
	function currentUserValue(address user) external view returns (uint256);

	/// @notice Retrieves the value of a specific stamp at a given timestamp
	/// @param stampId The ID of the stamp to query
	/// @param timestamp The timestamp to query
	/// @return The value of the stamp at the given timestamp
	function stampValueAtTimestamp(uint256 stampId, uint256 timestamp) external view returns (uint256);

	/// @notice Retrieves the value of a specific user's stamp at a given timestamp
	/// @param user The address of the user to query
	/// @param timestamp The timestamp to query
	/// @return The value of the user's stamp at the given timestamp
	function userValueAtTimestamp(address user, uint256 timestamp) external view returns (uint256);

	/// @notice Retrieves the total value of all stamps at a given timestamp
	/// @param timestamp The timestamp to query
	/// @return The total value of all stamps at the given timestamp
	function totalValueAtTimestamp(uint256 timestamp) external view returns (uint256);

	/// @notice Retrieves the current total value of all stamps
	/// @return The current total value of all stamps
	function currentTotalValue() external view returns (uint256);

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
