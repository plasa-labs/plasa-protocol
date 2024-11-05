// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { INames } from "./INames.sol";
import { ERC721 } from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import { ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { IERC721Metadata } from "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

/// @title Names - Decentralized Name Registration System
/// @author [Your Name/Organization]
/// @notice This contract implements a decentralized name registration system where users can mint unique names as NFTs
/// @dev Extends ERC721Enumerable for enumerable NFT functionality and implements custom INames interface
/// @custom:security-contact security@yourproject.com
contract Names is ERC721Enumerable, INames, Ownable {
	/// @notice URI for contract metadata
	/// @dev Used for OpenSea and other marketplaces to display collection information
	/// @inheritdoc INames
	string public contractURI;

	/// @notice Base URI for token metadata
	/// @dev Used as the base for all token URIs
	string private _tokenURI;

	/// @notice Counter for generating unique token IDs
	/// @dev Increments by 1 for each new mint
	uint256 private _tokenIds;

	/// @notice Minimum allowed length for a name
	/// @dev Prevents extremely short names
	/// @inheritdoc INames
	uint256 public constant MINIMAL_NAME_LENGTH = 3;

	/// @notice Maximum allowed length for a name
	/// @dev Prevents excessive gas costs and maintains reasonable name lengths
	/// @inheritdoc INames
	uint256 public constant MAX_NAME_LENGTH = 30;

	// State mappings
	/// @notice Maps name strings to their owner addresses
	/// @dev Primary lookup for name ownership
	/// @inheritdoc INames
	mapping(string name => address user) public nameToUser;
	/// @inheritdoc INames
	mapping(address user => string name) public userToName;
	/// @inheritdoc INames
	mapping(uint256 tokenId => string name) public tokenIdToName;

	/// @notice Initializes the Names contract with basic metadata
	/// @dev Sets initial URIs and configures base contract parameters
	constructor(address _owner) Ownable(_owner) ERC721("Plasa Names", "NAME") ERC721Enumerable() {
		contractURI = "some-contract-uri";
		_tokenURI = "some-token-uri";
	}

	/// @notice Updates the contract-level metadata URI
	/// @dev Only callable by contract owner
	/// @param _newURI New URI for contract metadata
	/// @inheritdoc INames
	function updateContractURI(string memory _newURI) public onlyOwner {
		contractURI = _newURI;
		emit ContractURIUpdated(_newURI);
	}

	/// @inheritdoc INames
	function updateTokenURI(string memory _newURI) public onlyOwner {
		_tokenURI = _newURI;
		emit TokenURIUpdated(_newURI);
	}

	/// @inheritdoc IERC721Metadata
	function tokenURI(uint256 /* tokenId */) public view override returns (string memory) {
		return _tokenURI;
	}

	/// @notice Internal function to mint a new name token
	/// @dev Handles validation and state updates for name minting
	/// @param _user Address to mint the name for
	/// @param _name Name to be minted
	/// @return mintedTokenId The ID of the newly minted token
	/// @custom:security Validates name availability and length constraints
	function _mintName(address _user, string memory _name) internal returns (uint256 mintedTokenId) {
		if (hasName(_user)) {
			revert UserAlreadyHasName(_user, userToName[_user]);
		}

		if (!isAvailable(_name)) {
			revert NameAlreadyTaken(_name, nameToUser[_name]);
		}

		uint256 nameLength = bytes(_name).length;

		if (nameLength < MINIMAL_NAME_LENGTH) {
			revert ShortName();
		}

		if (nameLength > MAX_NAME_LENGTH) {
			revert LongName();
		}

		mintedTokenId = _tokenIds++;
		_mint(_user, mintedTokenId);

		nameToUser[_name] = _user;
		userToName[_user] = _name;
		tokenIdToName[mintedTokenId] = _name;

		emit NameMinted(_user, mintedTokenId, _name);
	}

	/// @inheritdoc INames
	function mintName(string memory name) public returns (uint256 mintedTokenId) {
		return _mintName(msg.sender, name);
	}

	/// @inheritdoc INames
	function isAvailable(string memory name) public view returns (bool) {
		return nameToUser[name] == address(0);
	}

	/// @inheritdoc INames
	function hasName(address user) public view returns (bool) {
		return balanceOf(user) != 0;
	}
}
