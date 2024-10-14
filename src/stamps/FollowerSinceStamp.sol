// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp } from "./Stamp.sol";
import { IFollowerSinceStamp } from "./interfaces/IFollowerSinceStamp.sol";

/// @title FollowerSinceStamp
/// @notice A contract for minting NFTs that represent a user's follower status since a specific date
/// @dev Inherits from Stamp and implements IFollowerSinceStamp interface
contract FollowerSinceStamp is Stamp, IFollowerSinceStamp {
	/// @inheritdoc IFollowerSinceStamp
	string public override PLATFORM;

	/// @inheritdoc IFollowerSinceStamp
	string public override FOLLOWED;

	/// @inheritdoc IFollowerSinceStamp
	mapping(uint256 stampId => uint256 timestamp) public override followStartTimestamp;

	/// @notice Mapping to track if a follower has already minted a stamp
	mapping(string => bool) public hasFollowerMinted;

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

	/// @inheritdoc IFollowerSinceStamp
	function mintStamp(
		string calldata follower,
		uint256 since,
		uint256 deadline,
		bytes calldata signature
	) external override returns (uint256) {
		if (msg.sender == address(0)) revert InvalidRecipient();
		if (bytes(follower).length == 0) revert InvalidFollower();
		if (hasFollowerMinted[follower]) revert FollowerAlreadyMinted();

		bytes memory encodedData = abi.encode(PLATFORM, FOLLOWED, follower, since, msg.sender, deadline);

		uint256 stampId = _mintStamp(msg.sender, encodedData, signature, deadline);

		// Store the "since" timestamp for the stamp
		followStartTimestamp[stampId] = since;

		// Mark the follower as having minted a stamp
		hasFollowerMinted[follower] = true;

		emit FollowerSince(PLATFORM, FOLLOWED, follower, since, stampId, msg.sender);

		return stampId;
	}

	/// @inheritdoc IFollowerSinceStamp
	function getFollowerSinceTimestamp(address follower) external view override returns (uint256) {
		try this.tokenOfOwnerByIndex(follower, 0) returns (uint256 stampId) {
			return followStartTimestamp[stampId];
		} catch {
			return 0;
		}
	}

	/// @notice Generates a hash of the typed data for signature verification
	/// @dev Overrides the base Stamp contract's getTypedDataHash function
	/// @inheritdoc Stamp
	function _getTypedDataHash(bytes memory data) internal pure override returns (bytes32) {
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
