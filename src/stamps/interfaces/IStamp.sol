// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IStamp is IERC721Enumerable {
    // Errors
    error AlreadyMintedStamp(address user, uint256 stampId);
    error InvalidSignature();
    error DeadlineExpired(uint256 deadline, uint256 currentTimestamp);

    // Public variables
    function signer() external view returns (address);

    // Public functions
    function getTypedDataHash(
        bytes memory data
    ) external view returns (bytes32);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
