// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721, ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { IStamp } from "./interfaces/IStamp.sol";

/// @title Stamp
/// @notice Abstract contract for non-transferable ERC721 tokens (stamps) with signature-based minting
/// @dev Inherits from ERC721Enumerable for token enumeration, EIP712 for structured data signing, and IStamp interface
abstract contract Stamp is ERC721Enumerable, EIP712, IStamp {
	using ECDSA for bytes32;

	/// @notice Address authorized to sign minting requests
	/// @dev Immutable to ensure it cannot be changed after deployment
	address public immutable override signer;

	/// @notice Mapping to store the minting date for each token
	mapping(uint256 => uint256) internal _mintDates;

	/// @notice Initializes the Stamp contract
	/// @param stampName Name of the stamp collection
	/// @param stampSymbol Symbol of the stamp collection
	/// @param eip712version Version string for EIP712 domain separator
	/// @param _signer Address authorized to sign minting requests
	constructor(
		string memory stampName,
		string memory stampSymbol,
		string memory eip712version,
		address _signer
	) ERC721(stampName, stampSymbol) EIP712("Plasa Stamps", eip712version) {
		signer = _signer;
	}

	/// @inheritdoc IStamp
	function getMintDate(uint256 tokenId) public view override returns (uint256) {
		if (_mintDates[tokenId] == 0) revert TokenDoesNotExist(tokenId);
		return _mintDates[tokenId];
	}

	/// @notice Computes the typed data hash for signature verification
	/// @dev Must be implemented by derived contracts to define the structure of the signed data
	/// @param data The encoded data to be hashed
	/// @return The computed hash
	function _getTypedDataHash(bytes memory data) internal view virtual returns (bytes32);

	/// @notice Internal function to mint a new stamp
	/// @dev Checks deadline, verifies signature, ensures one stamp per address, and mints
	/// @param to Address to mint the stamp to
	/// @param data Encoded data for signature verification
	/// @param signature Signature authorizing the mint
	/// @param deadline Timestamp after which the signature is no longer valid
	/// @return The ID of the newly minted stamp
	function _mintStamp(
		address to,
		bytes memory data,
		bytes calldata signature,
		uint256 deadline
	) internal virtual returns (uint256) {
		// Check if the deadline has passed
		if (block.timestamp > deadline) {
			revert DeadlineExpired(deadline, block.timestamp);
		}

		// Verify the signature
		if (!_verifySignature(data, signature)) {
			revert InvalidSignature();
		}

		// Ensure the recipient doesn't already have a stamp
		if (balanceOf(to) > 0) {
			revert AlreadyMintedStamp(to, tokenOfOwnerByIndex(to, 0));
		}

		// Mint the new stamp
		uint256 newStampId = totalSupply() + 1;
		_safeMint(to, newStampId);
		_mintDates[newStampId] = block.timestamp;

		return newStampId;
	}

	/// @notice Verifies the signature for minting authorization
	/// @dev Uses EIP712 for structured data hashing and signature recovery
	/// @param data Encoded data that was signed
	/// @param signature Signature to verify
	/// @return Boolean indicating whether the signature is valid
	function _verifySignature(bytes memory data, bytes calldata signature) internal view returns (bool) {
		return signer == _hashTypedDataV4(_getTypedDataHash(data)).recover(signature);
	}

	// ============================
	// Overrides to Disable Transfers
	// ============================

	/// @notice Disable approvals
	/// @dev Overrides OpenZeppelin's _approve function to prevent token approvals
	function _approve(address, uint256, address, bool) internal pure override {
		revert NonTransferableStamp();
	}

	/// @notice Disable setting approval for all
	/// @dev Overrides OpenZeppelin's _setApprovalForAll function to prevent operator approvals
	function _setApprovalForAll(address, address, bool) internal pure override {
		revert NonTransferableStamp();
	}

	/// @notice Override _update to prevent transfers
	/// @dev Only allows minting (when auth is address(0)), reverts on transfer attempts
	/// @param to Address to mint to or transfer to (only minting is allowed)
	/// @param tokenId ID of the token being minted or transferred
	/// @param auth Address initiating the update (address(0) for minting)
	/// @return The address of the previous owner (always address(0) for minting)
	function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
		// Only allow minting (auth == address(0)), revert on transfer attempts
		if (auth != address(0)) {
			revert NonTransferableStamp();
		}

		return super._update(to, tokenId, auth);
	}
}
