// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IStampView {
	enum StampType {
		Null,
		AccountOwnership,
		FollowerSince
	}

	struct StampData {
		address contractAddress;
		StampType stampType;
		string name;
		string symbol;
		string platform;
		uint256 totalSupply;
	}

	struct StampUser {
		bool owns;
		uint256 stampId;
		uint256 mintingTimestamp;
	}

	struct Stamp {
		StampData data;
		StampUser user;
	}

	struct FollowerSinceStampData {
		StampData stampData;
		address followedAccount;
		string space;
	}

	struct FollowerSinceStampUser {
		StampUser stampUser;
		uint256 followTimestamp;
		uint256 timeSinceFollow;
	}

	struct FollowerSinceStamp {
		FollowerSinceStampData data;
		FollowerSinceStampUser user;
	}

	struct AccountOwnershipStamp {
		Stamp stamp;
		string userUsername;
	}

	struct StampView {
		Stamp[] stamps;
		FollowerSinceStamp[] followerSinceStamps;
		AccountOwnershipStamp[] accountOwnershipStamps;
	}

	function getStampView(address user) external view returns (StampView memory);
}
