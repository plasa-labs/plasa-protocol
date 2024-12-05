// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ERC721, ERC721Enumerable } from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import { IStamp } from "./interfaces/IStamp.sol";
import { IStampView } from "./interfaces/IStampView.sol";

// import { ISpace } from "../spaces/interfaces/ISpace.sol";

/// @title Stamp - Non-transferable ERC721 tokens with signature-based minting
/// @notice This contract implements non-transferable ERC721 tokens called "Stamps" with signature-based minting
/// @dev Inherits from ERC721Enumerable for token enumeration, EIP712 for structured data signing, and IStamp interface
abstract contract Stamp is ERC721Enumerable, EIP712, IStamp {
	using ECDSA for bytes32;

	/// @inheritdoc IStamp
	address public immutable override signer;

	/// @inheritdoc IStamp
	mapping(uint256 => uint256) public mintingTimestamps;

	/// @inheritdoc IStamp
	IStampView.StampType public stampType;

	// /// @notice The address of the space this stamp is associated with
	// ISpace public space;

	/// @notice The address authorized to mint stamps
	address public minter;

	/// @notice Initializes the Stamp contract
	/// @dev Sets up the ERC721 token, EIP712 domain separator, and stamp-specific properties
	/// @param _stampType The type of stamp
	/// @param stampName Name of the stamp collection
	/// @param stampSymbol Symbol of the stamp collection
	/// @param eip712version Version string for EIP712 domain separator
	/// @param _signer Address authorized to sign minting requests
	constructor(
		IStampView.StampType _stampType,
		string memory stampName,
		string memory stampSymbol,
		string memory eip712version,
		address _signer,
		address _minter
	) ERC721(stampName, stampSymbol) EIP712("Plasa Stamps", eip712version) {
		signer = _signer;
		stampType = _stampType;
		minter = _minter;
	}

	/// @notice Computes the typed data hash for signature verification
	/// @dev Must be implemented by derived contracts to define the structure of the signed data
	/// @param data The encoded data to be hashed
	/// @return bytes32 The computed hash
	function _getTypedDataHash(bytes memory data) internal pure virtual returns (bytes32);

	/// @notice Internal function to mint a new stamp
	/// @dev Checks deadline, verifies signature, ensures one stamp per address, and mints
	/// @param to Address to mint the stamp to
	/// @param data Encoded data for signature verification
	/// @param signature Signature authorizing the mint
	/// @param deadline Timestamp after which the signature is no longer valid
	/// @return uint256 The ID of the newly minted stamp
	function _mintWithSignature(
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
		return _mint(to);
	}

	/// @notice Internal function to mint a new stamp by the minter
	/// @dev Checks if the sender is the minter, then mints the stamp
	/// @param to Address to mint the stamp to
	/// @return uint256 The ID of the newly minted stamp
	function _mintByMinter(address to) internal virtual returns (uint256) {
		if (msg.sender != minter) revert InvalidMinter();

		// Mint the new stamp
		return _mint(to);
	}

	/// @notice Internal function to mint a new stamp
	/// @dev Mints the stamp and sets the minting timestamp
	/// @param to Address to mint the stamp to
	/// @return uint256 The ID of the newly minted stamp
	function _mint(address to) private returns (uint256) {
		uint256 newStampId = totalSupply() + 1;
		_safeMint(to, newStampId);
		mintingTimestamps[newStampId] = block.timestamp;

		return newStampId;
	}

	/// @notice Verifies the signature for minting authorization
	/// @dev Uses EIP712 for structured data hashing and signature recovery
	/// @param data Encoded data that was signed
	/// @param signature Signature to verify
	/// @return bool Indicating whether the signature is valid
	function _verifySignature(bytes memory data, bytes calldata signature) private view returns (bool) {
		return signer == _hashTypedDataV4(_getTypedDataHash(data)).recover(signature);
	}

	function _stampValueAtTimestamp(uint256 stampId, uint256 timestamp) internal view virtual returns (uint256);

	function stampValueAtTimestamp(uint256 stampId, uint256 timestamp) public view returns (uint256) {
		_requireOwned(stampId);
		return _stampValueAtTimestamp(stampId, timestamp);
	}

	function userValueAtTimestamp(address user, uint256 timestamp) public view returns (uint256) {
		if (balanceOf(user) == 0) return 0;
		uint256 _stampId = tokenOfOwnerByIndex(user, 0);
		return _stampValueAtTimestamp(_stampId, timestamp);
	}

	/// @inheritdoc IStamp
	function currentStampValue(uint256 stampId) external view returns (uint256) {
		return stampValueAtTimestamp(stampId, block.timestamp);
	}

	/// @inheritdoc IStamp
	function currentUserValue(address user) external view returns (uint256) {
		return userValueAtTimestamp(user, block.timestamp);
	}

	/// @inheritdoc IStamp
	function currentTotalValue() external view returns (uint256) {
		return totalValueAtTimestamp(block.timestamp);
	}

	function totalValueAtTimestamp(uint256 timestamp) public view returns (uint256) {
		uint256 totalValue;
		uint256 supply = totalSupply();

		for (uint256 i = 1; i <= supply; ) {
			totalValue += stampValueAtTimestamp(i, timestamp);

			unchecked {
				++i;
			}
		}
		return totalValue;
	}

	function _specificData() internal view virtual returns (bytes memory);

	function _specificUser(address user) internal view virtual returns (bytes memory);

	function _stampData() private view returns (IStampView.StampData memory) {
		return IStampView.StampData(address(this), stampType, name(), symbol(), totalSupply(), _specificData());
	}

	/// @notice Returns the user's stamp data
	/// @dev This function is used to get the user's stamp data
	/// @param user The address of the user
	/// @return IStampView.StampUser memory The user's stamp data
	function _stampUser(address user) private view returns (IStampView.StampUser memory) {
		if (balanceOf(user) == 0) {
			return IStampView.StampUser(false, 0, 0, 0, bytes(""));
		}
		uint256 tokenId = tokenOfOwnerByIndex(user, 0);
		return
			IStampView.StampUser(
				true,
				tokenId,
				mintingTimestamps[tokenId],
				_stampValueAtTimestamp(tokenId, block.timestamp),
				_specificUser(user)
			);
	}

	/// @inheritdoc IStampView
	function getStampView(address user) external view returns (IStampView.StampView memory) {
		return IStampView.StampView(_stampData(), _stampUser(user));
	}

	// ==============================
	// Overrides to Disable Transfers
	// ==============================

	/// @notice Disable approvals
	/// @dev Overrides OpenZeppelin's _approve function to prevent token approvals
	/// @inheritdoc ERC721
	function _approve(address, uint256, address, bool) internal pure override {
		revert NonTransferableStamp();
	}

	/// @notice Disable setting approval for all
	/// @dev Overrides OpenZeppelin's _setApprovalForAll function to prevent operator approvals
	/// @inheritdoc ERC721
	function _setApprovalForAll(address, address, bool) internal pure override {
		revert NonTransferableStamp();
	}

	/// @notice Override _update to prevent transfers
	/// @dev Only allows minting (when auth is address(0)), reverts on transfer attempts
	/// @param to Address to mint to or transfer to (only minting is allowed)
	/// @param tokenId ID of the token being minted or transferred
	/// @param auth Address initiating the update (address(0) for minting)
	/// @return address The address of the previous owner (always address(0) for minting)
	function _update(address to, uint256 tokenId, address auth) internal virtual override returns (address) {
		// Only allow minting (auth == address(0)), revert on transfer attempts
		if (auth != address(0)) {
			revert NonTransferableStamp();
		}

		return super._update(to, tokenId, auth);
	}
}
