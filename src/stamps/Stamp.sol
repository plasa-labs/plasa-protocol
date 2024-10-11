// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IStamp.sol";

/// @title Stamp
/// @notice Abstract contract for non-transferable ERC721 tokens (stamps) with signature-based minting
abstract contract Stamp is ERC721Enumerable, EIP712, IStamp {
    using ECDSA for bytes32;

    /// @notice Address authorized to sign minting requests
    address public immutable override signer;

    constructor(
        string memory stampName,
        string memory stampSymbol,
        string memory eip712version,
        address _signer
    ) ERC721(stampName, stampSymbol) EIP712("Plasa Stamps", eip712version) {
        signer = _signer;
    }

    /// @notice Computes the typed data hash for signature verification
    /// @param data The encoded data to be hashed
    /// @return The computed hash
    function getTypedDataHash(
        bytes memory data
    ) internal view virtual returns (bytes32);

    /// @notice Internal function to mint a new stamp
    /// @dev Checks deadline, verifies signature, ensures one stamp per address, and mints
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

        return newStampId;
    }

    /// @notice Verifies the signature for minting authorization
    /// @dev Uses EIP712 for structured data hashing and signature recovery
    function _verifySignature(
        bytes memory data,
        bytes calldata signature
    ) internal view returns (bool) {
        return
            signer ==
            _hashTypedDataV4(getTypedDataHash(data)).recover(signature);
    }

    // ============================
    // Overrides to Disable Transfers
    // ============================

    /// @dev Disable approvals
    function _approve(address, uint256, address, bool) internal pure override {
        revert NonTransferableStamp();
    }

    /// @dev Disable setting approval for all
    function _setApprovalForAll(address, address, bool) internal pure override {
        revert NonTransferableStamp();
    }

    /// @dev Override _update to prevent transfers
    /// @notice Only allows minting, reverts on transfer attempts
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal virtual override returns (address) {
        // Only allow minting (auth == address(0)), revert on transfer attempts
        if (auth != address(0)) {
            revert NonTransferableStamp();
        }

        return super._update(to, tokenId, auth);
    }
}
