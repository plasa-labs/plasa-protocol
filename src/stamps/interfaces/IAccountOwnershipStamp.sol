// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IStamp.sol";

interface IAccountOwnershipStamp is IStamp {
    /// @notice Thrown when the recipient address is invalid
    error InvalidRecipient();

    /// @notice Thrown when a username is already registered
    /// @param username The username that was attempted to be registered
    /// @param stampId The ID of the existing stamp for this username
    /// @param owner The address of the current owner of the username
    error UsernameAlreadyRegistered(
        string username,
        uint256 stampId,
        address owner
    );

    /// @notice The platform identifier for this stamp
    function PLATFORM() external view returns (string memory);

    /// @notice Mints a new account ownership stamp
    /// @param id The username to be registered
    /// @param deadline The timestamp after which the signature is no longer valid
    /// @param signature The signature authorizing the minting
    /// @return The ID of the newly minted stamp
    function mintStamp(
        string calldata id,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256);

    /// @notice Emitted when a new account ownership stamp is minted
    /// @param platform The platform identifier
    /// @param username The registered username
    /// @param stampId The ID of the minted stamp
    /// @param owner The address of the stamp owner
    event AccountOwner(
        string platform,
        string username,
        uint256 stampId,
        address owner
    );
}
