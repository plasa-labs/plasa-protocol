// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Stamp.sol";
import "./interfaces/IFollowerSinceStamp.sol";

contract FollowerSinceStamp is Stamp, IFollowerSinceStamp {
    /// @inheritdoc IFollowerSinceStamp
    string public override PLATFORM;

    /// @inheritdoc IFollowerSinceStamp
    string public override FOLLOWED;

    constructor(
        address _signer,
        string memory _platform,
        string memory _followed
    ) Stamp("Follower Since Stamp", "FSS", "0.1.0", _signer) {
        PLATFORM = _platform;
        FOLLOWED = _followed;
    }

    /// @inheritdoc IFollowerSinceStamp
    function mintStamp(
        string calldata follower,
        uint256 since,
        uint256 deadline,
        bytes calldata signature
    ) external override returns (uint256) {
        if (msg.sender == address(0)) revert InvalidRecipient();
        if (bytes(follower).length == 0) revert InvalidFollower();

        bytes memory encodedData = abi.encode(
            PLATFORM,
            FOLLOWED,
            follower,
            since,
            msg.sender,
            deadline
        );

        uint256 tokenId = _mintStamp(
            msg.sender,
            encodedData,
            signature,
            deadline
        );

        emit FollowerSince(
            PLATFORM,
            FOLLOWED,
            follower,
            since,
            tokenId,
            msg.sender
        );

        return tokenId;
    }

    /// @inheritdoc Stamp
    function getTypedDataHash(
        bytes memory data
    ) internal pure override returns (bytes32) {
        (
            string memory platform,
            string memory followed,
            string memory follower,
            uint256 since,
            address recipient,
            uint256 deadline
        ) = abi.decode(
                data,
                (string, string, string, uint256, address, uint256)
            );

        return
            keccak256(
                abi.encode(
                    keccak256(
                        "FollowerSince(string platform,string followed,string follower,uint256 since,address recipient,uint256 deadline)"
                    ),
                    keccak256(bytes(platform)),
                    keccak256(bytes(followed)),
                    keccak256(bytes(follower)),
                    since,
                    recipient,
                    deadline
                )
            );
    }
}
