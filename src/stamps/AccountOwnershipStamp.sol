// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp } from "./Stamp.sol";
import { IAccountOwnershipStamp } from "./interfaces/IAccountOwnershipStamp.sol";

/// @title AccountOwnershipStamp
/// @notice A contract for minting and managing account ownership stamps on specific platforms
/// @dev Inherits from Stamp and implements IAccountOwnershipStamp
contract AccountOwnershipStamp is Stamp, IAccountOwnershipStamp {
	/// @notice The platform this stamp is associated with (e.g., "Twitter", "GitHub")
	string public override PLATFORM;

	/// @notice Mapping to track used usernames and their associated stamp IDs
	mapping(string username => uint256 stampId) private _usedUsernames;
	/// @notice Mapping to store usernames for each stamp ID
	mapping(uint256 stampId => string username) private _tokenUsernames;

	/// @notice Initializes the contract with a signer and platform name
	/// @param _signer The address authorized to sign mint requests
	/// @param _platform The platform name for this stamp
	constructor(address _signer, string memory _platform) Stamp("Account Ownership Stamp", "AOS", "0.1.0", _signer) {
		PLATFORM = _platform;
	}

	/// @inheritdoc IAccountOwnershipStamp
	function getAccountOwnershipStampView(
		address user
	) external view returns (AccountOwnershipStampView memory stampView) {
		stampView.stampAddress = address(this);
		stampView.totalSupply = totalSupply();
		stampView.stampName = name();
		stampView.stampSymbol = symbol();
		stampView.platform = PLATFORM;

		uint256 balance = balanceOf(user);
		stampView.userHasStamp = balance > 0;

		if (stampView.userHasStamp) {
			uint256 _userStampId = tokenOfOwnerByIndex(user, 0);
			stampView.userStampId = _userStampId;
			stampView.userUsername = _tokenUsernames[_userStampId];
			stampView.userMintingDate = _mintDates[_userStampId];
		}
	}

	/// @notice Mints a new stamp for a given username
	/// @dev Verifies the signature and ensures the username is not already registered
	/// @param username The username to mint the stamp for
	/// @param deadline The expiration timestamp for the signature
	/// @param signature The cryptographic signature authorizing the mint
	/// @return The ID of the newly minted stamp
	function mintStamp(
		string calldata username,
		uint256 deadline,
		bytes calldata signature
	) external override returns (uint256) {
		if (msg.sender == address(0)) revert InvalidRecipient();
		if (_usedUsernames[username] != 0)
			revert UsernameAlreadyRegistered(username, _usedUsernames[username], msg.sender);

		bytes memory encodedData = abi.encode(PLATFORM, username, msg.sender, deadline);

		uint256 tokenId = _mintStamp(msg.sender, encodedData, signature, deadline);

		_usedUsernames[username] = tokenId;
		_tokenUsernames[tokenId] = username;

		emit AccountOwner(PLATFORM, username, tokenId, msg.sender);

		return tokenId;
	}

	/// @notice Generates a hash of the typed data for signature verification
	/// @dev Overrides the base Stamp contract's implementation
	/// @param data The encoded data containing platform, username, recipient, and deadline
	/// @return The keccak256 hash of the encoded data
	function _getTypedDataHash(bytes memory data) internal pure override returns (bytes32) {
		(string memory platform, string memory id, address recipient, uint256 deadline) = abi.decode(
			data,
			(string, string, address, uint256)
		);

		return
			keccak256(
				abi.encode(
					keccak256("AccountOwnership(string platform,string id,address recipient,uint256 deadline)"),
					keccak256(bytes(platform)),
					keccak256(bytes(id)),
					recipient,
					deadline
				)
			);
	}

	/// @notice Retrieves the username associated with a token ID
	/// @param tokenId The ID of the token
	/// @return The username associated with the token ID
	function getTokenId(uint256 tokenId) external view returns (string memory) {
		return _tokenUsernames[tokenId];
	}
}
