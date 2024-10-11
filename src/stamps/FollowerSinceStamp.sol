// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp } from "./Stamp.sol";
import { IFollowerSinceStamp } from "./interfaces/IFollowerSinceStamp.sol";

/// @title FollowerSinceStamp
/// @notice A contract for minting NFTs that represent a user's follower status since a specific date
/// @dev Inherits from Stamp and implements IFollowerSinceStamp interface
contract FollowerSinceStamp is Stamp, IFollowerSinceStamp {
	/// @notice The platform where the following relationship exists (e.g., "Twitter", "Instagram")
	/// @inheritdoc IFollowerSinceStamp
	string public override PLATFORM;

	/// @notice The account being followed
	/// @inheritdoc IFollowerSinceStamp
	string public override FOLLOWED;

	/// @notice Mapping to store the "since" timestamp for each follower
	mapping(address => uint256) public followerSince;

	/// @notice Initializes the FollowerSinceStamp contract
	/// @param _signer The address authorized to sign mint requests
	/// @param _platform The platform where the following relationship exists
	/// @param _followed The account being followed
	constructor(
		address _signer,
		string memory _platform,
		string memory _followed
	) Stamp("Follower Since Stamp", "FSS", "0.1.0", _signer) {
		PLATFORM = _platform;
		FOLLOWED = _followed;
	}

	/// @notice Mints a new Follower Since Stamp NFT
	/// @dev Verifies the signature and mints the stamp if valid
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

		uint256 tokenId = _mintStamp(msg.sender, encodedData, signature, deadline);

		// Store the "since" timestamp for the follower
		followerSince[msg.sender] = since;

		emit FollowerSince(PLATFORM, FOLLOWED, follower, since, tokenId, msg.sender);

		return tokenId;
	}

	/// @notice Generates a hash of the typed data for signature verification
	/// @dev Overrides the base Stamp contract's getTypedDataHash function
	/// @inheritdoc Stamp
	function getTypedDataHash(bytes memory data) internal pure override returns (bytes32) {
		(
			string memory platform,
			string memory followed,
			string memory follower,
			uint256 since,
			address recipient,
			uint256 deadline
		) = abi.decode(data, (string, string, string, uint256, address, uint256));

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
