// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IStamp is IERC721Enumerable {
    /// @notice Thrown when a user attempts to mint a stamp they already own
    /// @param user The address of the user
    /// @param stampId The ID of the existing stamp
    error AlreadyMintedStamp(address user, uint256 stampId);

    /// @notice Thrown when the provided signature is invalid
    error InvalidSignature();

    /// @notice Thrown when the deadline for minting has expired
    /// @param deadline The timestamp of the deadline
    /// @param currentTimestamp The current block timestamp
    error DeadlineExpired(uint256 deadline, uint256 currentTimestamp);

    /// @notice The address of the signer authorized to sign minting requests
    function signer() external view returns (address);
}
