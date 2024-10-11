// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IStamp.sol";

interface IFollowerSinceStamp is IStamp {
    /// @notice Thrown when the recipient address is invalid
    error InvalidRecipient();

    /// @notice Thrown when the follower identifier is invalid
    error InvalidFollower();

    /// @notice The platform identifier for this stamp
    function PLATFORM() external view returns (string memory);

    /// @notice The identifier of the followed account
    function FOLLOWED() external view returns (string memory);

    /// @notice Mints a new follower since stamp
    /// @param follower The identifier of the follower
    /// @param since The timestamp since when the user has been following
    /// @param deadline The timestamp after which the signature is no longer valid
    /// @param signature The signature authorizing the minting
    /// @return The ID of the newly minted stamp
    function mintStamp(
        string calldata follower,
        uint256 since,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256);

    /// @notice Emitted when a new follower since stamp is minted
    /// @param platform The platform identifier
    /// @param followed The identifier of the followed account
    /// @param follower The identifier of the follower
    /// @param since The timestamp since when the user has been following
    /// @param stampId The ID of the minted stamp
    /// @param owner The address of the stamp owner
    event FollowerSince(
        string platform,
        string followed,
        string follower,
        uint256 since,
        uint256 stampId,
        address owner
    );
}
