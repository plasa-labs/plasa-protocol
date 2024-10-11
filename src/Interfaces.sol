// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

error InvalidSignature(address expectedSigner, address actualSigner);

interface IAccountOwnershipStamp {
    function mintStamp(
        string memory username,
        uint256 deadline,
        bytes memory signature
    ) external;
}

interface IFollowerStamp {
    function mintStamp(
        uint256 since,
        uint256 deadline,
        bytes memory signature
    ) external;
}
