// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Stamp.sol";
import "./interfaces/IAccountOwnershipStamp.sol";

contract AccountOwnershipStamp is Stamp, IAccountOwnershipStamp {
    /// @inheritdoc IAccountOwnershipStamp
    string public override PLATFORM;

    mapping(string username => uint256 stampId) private _usedUsernames;
    mapping(uint256 stampId => string username) private _tokenUsernames;

    constructor(
        address _signer,
        string memory _platform
    ) Stamp("Account Ownership Stamp", "AOS", "0.1.0", _signer) {
        PLATFORM = _platform;
    }

    /// @inheritdoc IAccountOwnershipStamp
    function mintStamp(
        string calldata username,
        uint256 deadline,
        bytes calldata signature
    ) external override returns (uint256) {
        if (msg.sender == address(0)) revert InvalidRecipient();
        if (_usedUsernames[username] != 0)
            revert UsernameAlreadyRegistered(
                username,
                _usedUsernames[username],
                msg.sender
            );

        bytes memory encodedData = abi.encode(
            PLATFORM,
            username,
            msg.sender,
            deadline
        );

        uint256 tokenId = _mintStamp(
            msg.sender,
            encodedData,
            signature,
            deadline
        );

        _usedUsernames[username] = tokenId;
        _tokenUsernames[tokenId] = username;

        emit AccountOwner(PLATFORM, username, tokenId, msg.sender);

        return tokenId;
    }

    /// @inheritdoc Stamp
    function getTypedDataHash(
        bytes memory data
    ) internal pure override returns (bytes32) {
        (
            string memory platform,
            string memory id,
            address recipient,
            uint256 deadline
        ) = abi.decode(data, (string, string, address, uint256));

        return
            keccak256(
                abi.encode(
                    keccak256(
                        "AccountOwnership(string platform,string id,address recipient,uint256 deadline)"
                    ),
                    keccak256(bytes(platform)),
                    keccak256(bytes(id)),
                    recipient,
                    deadline
                )
            );
    }

    /// @notice Retrieves the username associated with a token ID
    /// @param tokenId The ID of the token
    /// @return The username associated with the token ID
    function getTokenId(uint256 tokenId) external view returns (string memory) {
        return _tokenUsernames[tokenId];
    }
}
