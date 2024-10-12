// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestion } from "./IQuestion.sol";

/// @title IOpenQuestion Interface
/// @dev Interface for an open-ended question where users can add new options
interface IOpenQuestion is IQuestion {
	/// @notice Thrown when a user tries to add an option without sufficient points
	error InsufficientPoints();

	/// @notice Thrown when a user tries to vote for an option they've already voted for
	/// @param voter The address of the voter
	/// @param optionId The ID of the option
	error UserAlreadyVotedThisOption(address voter, uint256 optionId);

	/// @notice Emitted when the minimum points required to add an option is updated
	/// @param newMinPoints The new minimum points value
	event MinPointsToAddOptionUpdated(uint256 newMinPoints);

	/// @notice Returns the minimum points required to add a new option
	/// @return The minimum points required
	function minPointsToAddOption() external view returns (uint256);

	/// @notice Adds a new option to the question
	/// @dev Requires the caller to have sufficient points
	/// @param _title The title of the new option
	/// @param _description The description of the new option
	function addOption(string memory _title, string memory _description) external;

	/// @notice Updates the minimum points required to add a new option
	/// @dev Can only be called by the contract owner or authorized role
	/// @param _minPointsToAddOption The new minimum points value
	function updateMinPointsToAddOption(uint256 _minPointsToAddOption) external;
}
