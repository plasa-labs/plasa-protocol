// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoints } from "./IPoints.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";

/// @title IFollowerSincePoints - Interface for follower duration-based point system
/// @notice This interface defines the structure for a contract that calculates and manages points based on a user's follower duration
/// @dev Inherits from IPoints for basic point functionality and integrates with IFollowerSinceStamp for duration tracking
interface IFollowerSincePoints is IPoints {
	/// @notice Retrieves the associated IFollowerSinceStamp contract
	/// @dev This function allows access to the stamp contract used for follower duration calculations
	/// @return The address of the IFollowerSinceStamp contract implementation
	function followerStamp() external view returns (IFollowerSinceStamp);
}
