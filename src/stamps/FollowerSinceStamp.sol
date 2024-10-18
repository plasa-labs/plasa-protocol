// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp, IStampView } from "./Stamp.sol";
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

	/// @notice Initializes the FollowerSinceStamp contract
	/// @param _signer The address authorized to sign mint requests
	/// @param _platform The platform where the following relationship exists
	/// @param _followed The account being followed
	constructor(
		address _signer,
		string memory _platform,
		string memory _followed
	)
		Stamp(
			IStampView.StampType.FollowerSince,
			string.concat(_followed, " ", _platform, " Follower"),
			"FOLLOW",
			"0.1.0",
			_signer
		)
	{
		PLATFORM = _platform;
		FOLLOWED = _followed;
	}

	/// @inheritdoc IFollowerSinceStamp
	function mintStamp(uint256 since, uint256 deadline, bytes calldata signature) external override returns (uint256) {
		if (msg.sender == address(0)) revert InvalidRecipient();

		bytes memory encodedData = abi.encode(PLATFORM, FOLLOWED, since, msg.sender, deadline);

		uint256 stampId = _mintStamp(msg.sender, encodedData, signature, deadline);

		// Store the "since" timestamp for the stamp
		followStartTimestamp[stampId] = since;

		emit FollowerSince(PLATFORM, FOLLOWED, since, stampId, msg.sender);

		return stampId;
	}

	/// @inheritdoc IFollowerSinceStamp
	function getFollowerSinceTimestamp(address user) public view override returns (uint256) {
		try this.tokenOfOwnerByIndex(user, 0) returns (uint256 stampId) {
			return followStartTimestamp[stampId];
		} catch {
			return 0;
		}
	}

	function _specificData() internal view override returns (bytes memory) {
		return abi.encode(PLATFORM, FOLLOWED);
	}

	function _specificUser(address user) internal view override returns (bytes memory) {
		return bytes(abi.encode(getFollowerSinceTimestamp(user)));
	}

	/// @inheritdoc Stamp
	function _getTypedDataHash(bytes memory data) internal pure override returns (bytes32) {
		(string memory platform, string memory followed, uint256 since, address recipient, uint256 deadline) = abi
			.decode(data, (string, string, uint256, address, uint256));

		return
			keccak256(
				abi.encode(
					keccak256(
						"FollowerSince(string platform,string followed,uint256 since,address recipient,uint256 deadline)"
					),
					keccak256(bytes(platform)),
					keccak256(bytes(followed)),
					since,
					recipient,
					deadline
				)
			);
	}
}
