// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./IStamp.sol";

interface IAccountOwnershipStamp is IStamp {
    // Errors
    error InvalidRecipient();
    error UsernameAlreadyRegistered(
        string username,
        uint256 stampId,
        address owner
    );

    // State variables
    function PLATFORM() external view returns (string memory);

    // Functions
    function mintStamp(
        string calldata id,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256);

    // Events
    event AccountOwner(
        string platform,
        string username,
        uint256 stampId,
        address owner
    );
}
