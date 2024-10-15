// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Stamp, IStampView } from "./Stamp.sol";
import { IFollowerSinceStamp } from "./interfaces/IFollowerSinceStamp.sol";

/// @title FollowerSinceStamp
/// @notice A contract for minting NFTs that represent a user's follower status since a specific date
/// @dev Inherits from Stamp and implements IFollowerSinceStamp interface
contract FollowerSinceStamp is Stamp, IFollowerSinceStamp {
	/// @inheritdoc IFollowerSinceStamp
	string public override FOLLOWED;

	/// @inheritdoc IFollowerSinceStamp
	mapping(uint256 stampId => uint256 timestamp) public override followStartTimestamp;

	/// @notice Initializes the FollowerSinceStamp contract
	/// @param _space The address of the space this stamp is associated with
	/// @param _signer The address authorized to sign mint requests
	/// @param _platform The platform where the following relationship exists
	/// @param _followed The account being followed
	constructor(
		address _space,
		address _signer,
		string memory _platform,
		string memory _followed
	)
		Stamp(
			_space,
			string.concat(_followed, " ", _platform, " Follower"),
			"FOLLOW",
			"0.1.0",
			_signer,
			IStampView.StampType.FollowerSince,
			_platform
		)
	{
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

		bytes memory encodedData = abi.encode(PLATFORM, FOLLOWED, follower, since, msg.sender, deadline);

		uint256 stampId = _mintStamp(msg.sender, encodedData, signature, deadline);

		// Store the "since" timestamp for the stamp
		followStartTimestamp[stampId] = since;

		emit FollowerSince(PLATFORM, FOLLOWED, follower, since, stampId, msg.sender);

		return stampId;
	}

	/// @inheritdoc IFollowerSinceStamp
	function getFollowerSinceTimestamp(address follower) public view override returns (uint256) {
		try this.tokenOfOwnerByIndex(follower, 0) returns (uint256 stampId) {
			return followStartTimestamp[stampId];
		} catch {
			return 0;
		}
	}

	function _specificData() internal view override returns (bytes memory) {
		return abi.encode(FOLLOWED);
	}

	function _specificUser(address user) internal view override returns (bytes memory) {
		return bytes(abi.encode(getFollowerSinceTimestamp(user)));
	}

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
