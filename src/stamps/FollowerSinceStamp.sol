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
		string memory _followed,
		address _minter
	)
		Stamp(
			IStampView.StampType.FollowerSince,
			string.concat(_followed, " ", _platform, " Follower"),
			"FOLLOW",
			"0.1.0",
			_signer,
			_minter
		)
	{
		PLATFORM = _platform;
		FOLLOWED = _followed;
	}

	/// @inheritdoc IFollowerSinceStamp
	function mintWithSignature(
		uint256 since,
		uint256 deadline,
		bytes calldata signature
	) external override returns (uint256) {
		if (msg.sender == address(0)) revert InvalidRecipient();

		bytes memory encodedData = abi.encode(PLATFORM, FOLLOWED, since, msg.sender, deadline);

		uint256 stampId = _mintWithSignature(msg.sender, encodedData, signature, deadline);

		_processMint(stampId, msg.sender, since);

		return stampId;
	}

	/// @inheritdoc IFollowerSinceStamp
	function mintByMinter(address user, uint256 since) external returns (uint256) {
		uint256 stampId = _mintByMinter(user);

		_processMint(stampId, user, since);

		return stampId;
	}

	/// @dev Internal function to process the minting of a follower since stamp
	/// @param stampId The ID of the minted stamp
	/// @param user The address of the follower
	/// @param since The timestamp when the following relationship started
	function _processMint(uint256 stampId, address user, uint256 since) private {
		followStartTimestamp[stampId] = since;

		emit FollowerSince(PLATFORM, FOLLOWED, since, stampId, user);
	}

	function _stampValueAtTimestamp(uint256 stampId, uint256 timestamp) internal view override returns (uint256) {
		return timestamp - followStartTimestamp[stampId];
	}

	/// @inheritdoc IFollowerSinceStamp
	function getFollowerSinceTimestamp(address user) public view returns (uint256) {
		if (balanceOf(user) == 0) return 0;
		return followStartTimestamp[tokenOfOwnerByIndex(user, 0)];
	}

	/// @inheritdoc Stamp
	function _specificData() internal view override returns (bytes memory) {
		return abi.encode(PLATFORM, FOLLOWED);
	}

	/// @inheritdoc Stamp
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
