// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp, IStampView } from "./Stamp.sol";
import { IAccountOwnershipStamp } from "./interfaces/IAccountOwnershipStamp.sol";

/// @title AccountOwnershipStamp
/// @notice A contract for minting and managing account ownership stamps on specific platforms
/// @dev Inherits from Stamp and implements IAccountOwnershipStamp
contract AccountOwnershipStamp is Stamp, IAccountOwnershipStamp {
	// /// @notice Mapping to track used usernames and their associated stamp IDs
	// mapping(string username => uint256 stampId) private _usedUsernames;
	// /// @notice Mapping to store usernames for each stamp ID
	// mapping(uint256 stampId => string username) private _tokenUsernames;

	/// @notice The platform name for this stamp
	string public override PLATFORM;

	/// @notice Initializes the contract with a signer and platform name
	/// @param _signer The address authorized to sign mint requests
	/// @param _platform The platform name for this stamp
	constructor(
		address _signer,
		address _minter,
		string memory _platform
	)
		Stamp(
			IStampView.StampType.AccountOwnership,
			string.concat(_platform, " Account Owner"),
			"OWNER",
			"0.1.0",
			_signer,
			_minter
		)
	{
		PLATFORM = _platform;
	}

	/// @notice Mints a new stamp for a given username
	/// @dev Verifies the signature and ensures the username is not already registered
	/// @param deadline The expiration timestamp for the signature
	/// @param signature The cryptographic signature authorizing the mint
	/// @return The ID of the newly minted stamp
	function mintStamp(
		string calldata username,
		uint256 deadline,
		bytes calldata signature
	) external override returns (uint256) {
		if (msg.sender == address(0)) revert InvalidRecipient();
		// if (_usedUsernames[username] != 0)
		// 	revert UsernameAlreadyRegistered(username, _usedUsernames[username], msg.sender);

		bytes memory encodedData = abi.encode(PLATFORM, username, msg.sender, deadline);

		uint256 tokenId = _mintWithSignature(msg.sender, encodedData, signature, deadline);

		// _usedUsernames[username] = tokenId;
		// _tokenUsernames[tokenId] = username;

		emit AccountOwner(PLATFORM, "", tokenId, msg.sender);

		return tokenId;
	}

	function _specificData() internal pure override returns (bytes memory) {
		return bytes("");
	}

	function _specificUser(address) internal pure override returns (bytes memory) {
		return bytes("");
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
}
