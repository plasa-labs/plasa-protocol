// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

abstract contract Stamp is ERC721Enumerable, EIP712 {
    using ECDSA for bytes32;

    // Signer address
    address public immutable signer;

    constructor(
        string memory stampName,
        string memory stampSymbol,
        string memory eip712version,
        address _signer
    ) ERC721(stampName, stampSymbol) EIP712("Plasa Stamps", eip712version) {
        signer = _signer;
    }

    // Abstract function to be implemented by child contracts
    function getTypedDataHash(
        bytes memory data
    ) public view virtual returns (bytes32);

    // Custom error for when a user has already minted a stamp
    error AlreadyMintedStamp(address user, uint256 stampId);
    // New custom error for invalid signature
    error InvalidSignature();

    // Internal minting function
    function _mintStamp(
        address to,
        bytes calldata data,
        bytes calldata signature
    ) internal virtual returns (uint256) {
        if (!_verify(data, signature)) {
            revert InvalidSignature();
        }

        if (balanceOf(to) > 0) {
            revert AlreadyMintedStamp(to, tokenOfOwnerByIndex(to, 0));
        }

        uint256 newStampId = totalSupply() + 1;
        _safeMint(to, newStampId);

        return newStampId;
    }

    // Signature verification
    function _verify(
        bytes calldata data,
        bytes calldata signature
    ) internal view returns (bool) {
        return
            signer ==
            _hashTypedDataV4(getTypedDataHash(data)).recover(signature);
    }

    // Override required by Solidity
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721Enumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
