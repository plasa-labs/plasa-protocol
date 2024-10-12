// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";

/// @title IFollowerSincePoints - Interface for non-transferable tokens based on follower duration
/// @notice This interface defines the structure for a contract that calculates points based on how long a user has been a follower
/// @dev Inherits from IERC20 and uses IFollowerSinceStamp for duration calculation
interface IFollowerSincePoints is IERC20 {
	/// @notice Returns the IFollowerSinceStamp contract used for duration calculations
	/// @return The address of the IFollowerSinceStamp contract
	function followerStamp() external view returns (IFollowerSinceStamp);

	/// @notice Calculates the balance of points for a given account
	/// @dev Uses a square root formula based on the duration of following
	/// @param account The address to calculate the balance for
	/// @return The number of points the account has earned
	/// @dev Returns 0 if the account is not a follower
	function balanceOf(address account) external view override returns (uint256);

	/// @notice Returns the total supply of points
	/// @dev Calculates the total points for all followers using the followStartTimestamp
	/// @return The total supply of points
	/// @dev May be gas-intensive for large numbers of followers
	function totalSupply() external view override returns (uint256);
}
