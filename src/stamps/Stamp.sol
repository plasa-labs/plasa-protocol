// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./interfaces/IStamp.sol";

abstract contract Stamp is ERC721Enumerable, EIP712, IStamp {
    using ECDSA for bytes32;

    /// @inheritdoc IStamp
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
    /// @param to The address to mint the stamp to
    /// @param data The encoded data for signature verification
    /// @param signature The signature authorizing the minting
    /// @param deadline The timestamp after which the signature is no longer valid
    /// @return The ID of the newly minted stamp
    function _mintStamp(
        address to,
        bytes memory data,
        bytes calldata signature,
        uint256 deadline
    ) internal virtual returns (uint256) {
        if (block.timestamp > deadline) {
            revert DeadlineExpired(deadline, block.timestamp);
        }

        if (!_verifySignature(data, signature)) {
            revert InvalidSignature();
        }

        if (balanceOf(to) > 0) {
            revert AlreadyMintedStamp(to, tokenOfOwnerByIndex(to, 0));
        }

        uint256 newStampId = totalSupply() + 1;
        _safeMint(to, newStampId);

        return newStampId;
    }

    /// @notice Verifies the signature for minting authorization
    /// @param data The encoded data to be verified
    /// @param signature The signature to be verified
    /// @return True if the signature is valid, false otherwise
    function _verifySignature(
        bytes memory data,
        bytes calldata signature
    ) internal view returns (bool) {
        return
            signer ==
            _hashTypedDataV4(getTypedDataHash(data)).recover(signature);
    }
}
