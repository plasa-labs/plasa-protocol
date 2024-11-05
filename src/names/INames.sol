// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

/// @title INames - ERC721 Name Registration Interface
/// @notice Interface for a decentralized name registration system using NFTs
/// @dev Extends IERC721Enumerable to provide name registration and management functionality
interface INames is IERC721Enumerable {
	/// @notice Emitted when a new name is minted
	/// @param user Address of the user minting the name
	/// @param tokenId ID of the minted NFT
	/// @param name The registered name
	event NameMinted(address indexed user, uint256 indexed tokenId, string indexed name);

	/// @notice Emitted when the contract URI is updated
	/// @param newURI New URI for contract metadata
	event ContractURIUpdated(string newURI);

	/// @notice Emitted when the token URI is updated
	/// @param newURI New URI for token metadata
	event TokenURIUpdated(string newURI);

	/// @notice Error thrown when name exceeds maximum allowed length
	error LongName();

	/// @notice Error thrown when name is shorter than minimum required length
	error ShortName();

	/// @notice Error thrown when attempting to register an already taken name
	/// @param name The name that was attempted to be registered
	/// @param owner Current owner of the name
	error NameAlreadyTaken(string name, address owner);

	/// @notice Error thrown when a user attempts to register multiple names
	/// @param user Address of the user
	/// @param name Current name of the user
	error UserAlreadyHasName(address user, string name);

	/// @notice Mints a new name token
	/// @dev Creates a new NFT representing the name ownership
	/// @param name The name to register
	/// @return mintedTokenId The ID of the newly minted NFT
	/// @custom:throws LongName If name length exceeds maximum
	/// @custom:throws ShortName If name length is below minimum
	/// @custom:throws NameAlreadyTaken If name is already registered
	/// @custom:throws UserAlreadyHasName If caller already owns a name
	function mintName(string memory name) external returns (uint256 mintedTokenId);

	/// @notice Retrieves the owner address for a given name
	/// @param name The name to query
	/// @return user The address that owns the name (zero address if unregistered)
	function nameToUser(string memory name) external view returns (address user);

	/// @notice Retrieves the registered name for a given user
	/// @param user The address to query
	/// @return name The user's registered name (empty string if none)
	function userToName(address user) external view returns (string memory name);

	/// @notice Retrieves the name associated with a token ID
	/// @param tokenId The ID of the name token
	/// @return name The name associated with the token
	function tokenIdToName(uint256 tokenId) external view returns (string memory name);

	/// @notice Checks if a name is available for registration
	/// @param name The name to check
	/// @return bool True if the name is available, false otherwise
	function isAvailable(string memory name) external view returns (bool);

	/// @notice Checks if an address has a registered name
	/// @param user The address to check
	/// @return bool True if the address has a name, false otherwise
	function hasName(address user) external view returns (bool);

	/// @notice Returns the contract-level metadata URI
	/// @return URI string for contract metadata
	function contractURI() external view returns (string memory);

	/// @notice The minimum allowed length for names
	/// @return uint256 Minimum name length (3)
	function MINIMAL_NAME_LENGTH() external view returns (uint256);

	/// @notice The maximum allowed length for names
	/// @return uint256 Maximum name length (30)
	function MAX_NAME_LENGTH() external view returns (uint256);

	/// @notice Updates the contract-level metadata URI
	/// @param _newURI New URI string for contract metadata
	function updateContractURI(string memory _newURI) external;

	/// @notice Updates the token-level metadata URI
	/// @param _newURI New URI string for token metadata
	function updateTokenURI(string memory _newURI) external;
}
