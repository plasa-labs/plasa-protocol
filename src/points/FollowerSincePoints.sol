// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title FollowerSincePoints - A non-transferable token based on follower duration
/// @notice This contract calculates points based on how long a user has been a follower
/// @dev Inherits from Points and uses IFollowerSinceStamp for duration calculation
contract FollowerSincePoints is Points {
	IFollowerSinceStamp public immutable followerStamp;

	/// @notice Initializes the FollowerSincePoints contract
	/// @param _followerStamp The address of the IFollowerSinceStamp contract
	/// @param _name The name of the token
	/// @param _symbol The symbol of the token
	constructor(
		address _followerStamp,
		string memory _name,
		string memory _symbol
	) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
	}

	/// @notice Calculates the balance of points for a given account
	/// @dev Uses a square root formula based on the duration of following
	/// @param account The address to calculate the balance for
	/// @return The number of points the account has earned
	/// @dev Returns 0 if the account is not a follower
	function balanceOf(address account) public view override returns (uint256) {
		uint256 followerSince = followerStamp.getFollowerSinceTimestamp(account);
		if (followerSince == 0) {
			return 0;
		}
		return _calculatePoints(followerSince);
	}

	/// @notice Returns the total supply of points
	/// @dev Calculates the total points for all followers using the followStartTimestamp
	/// @return The total supply of points
	/// @dev Iterates through all followers, which may be gas-intensive for large numbers of followers
	function totalSupply() public view override returns (uint256) {
		uint256 totalPoints = 0;
		uint256 totalFollowers = followerStamp.totalSupply();

		for (uint256 i = 1; i <= totalFollowers; i++) {
			uint256 followerSince = followerStamp.followStartTimestamp(i);
			if (followerSince == 0) {
				continue;
			}
			totalPoints += _calculatePoints(followerSince);
		}

		return totalPoints;
	}

	/// @dev Calculates points based on the duration of following using a square root formula
	/// @param followerSince The timestamp when the user started following
	/// @return The calculated points
	/// @dev Uses block.timestamp, which can be manipulated by miners to a small degree
	function _calculatePoints(uint256 followerSince) private view returns (uint256) {
		uint256 durationInSeconds = block.timestamp - followerSince;

		// Adjusted divisor to get closer to desired values
		return (Math.sqrt(durationInSeconds * 1e18) * 1e9) / 293938769;
	}
}
