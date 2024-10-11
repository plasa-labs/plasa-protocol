// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Stamp.sol";

contract AccountOwnershipStamp is Stamp {
    string public PLATFORM;

    error InvalidRecipient();

    constructor(
        address _signer,
        string memory _platform
    ) Stamp("Account Ownership Stamp", "AOS", "0.1.0", _signer) {
        PLATFORM = _platform;
    }

    function mintStamp(
        string calldata id,
        uint256 deadline,
        bytes calldata signature
    ) external returns (uint256) {
        if (msg.sender == address(0)) revert InvalidRecipient();

        bytes memory encodedData = abi.encode(
            PLATFORM,
            id,
            msg.sender,
            deadline
        );

        return _mintStamp(msg.sender, encodedData, signature, deadline);
    }

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
}
