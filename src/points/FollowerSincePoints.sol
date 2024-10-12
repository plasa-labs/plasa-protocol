// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Points } from "./Points.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title FollowerPoints - A non-transferable token based on follower duration
/// @notice This contract calculates points based on how long a user has been a follower
/// @dev Inherits from Points and uses IFollowerSinceStamp for duration calculation
contract FollowerSincePoints is Points {
	IFollowerSinceStamp public immutable followerStamp;
	uint256 public immutable POINTS_PER_DAY;

	/// @notice Initializes the FollowerPoints contract
	/// @param _followerStamp The address of the IFollowerSinceStamp contract
	/// @param _name The name of the token
	/// @param _symbol The symbol of the token
	/// @param _pointsPerDay The number of points earned per day (in wei, 18 decimal places)
	constructor(
		address _followerStamp,
		string memory _name,
		string memory _symbol,
		uint256 _pointsPerDay
	) Points(_name, _symbol, 18) {
		followerStamp = IFollowerSinceStamp(_followerStamp);
		POINTS_PER_DAY = _pointsPerDay;
	}

	/// @notice Calculates the balance of points for a given account using a square root formula
	/// @param account The address to calculate the balance for
	/// @return uint256 The number of points the account has earned
	function balanceOf(address account) public view override returns (uint256) {
		uint256 followerSince = followerStamp.followerSince(account);
		if (followerSince == 0) {
			return 0;
		}
		uint256 durationInDays = (block.timestamp - followerSince) / 1 days;
		return Math.sqrt(durationInDays * POINTS_PER_DAY);
	}

	/// @notice Returns the total supply of points
	/// @dev This function is not implemented as it would require iterating over all followers
	/// @return uint256 Always returns 0
	function totalSupply() public pure override returns (uint256) {
		return 0;
	}
}
