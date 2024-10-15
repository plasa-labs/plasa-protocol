// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestion } from "./IQuestion.sol";

/// @title IOpenQuestion Interface
/// @notice Interface for an open-ended question where users can add new options and vote
/// @dev Extends the IQuestion interface with functionality for adding options
interface IOpenQuestion is IQuestion {
	/// @notice Thrown when a user tries to add an option without sufficient points
	/// @dev This error should be used when enforcing point requirements for adding options
	error InsufficientPoints();

	/// @notice Thrown when a user tries to vote for an option they've already voted for
	/// @dev This error helps prevent double voting
	/// @param voter The address of the voter attempting to vote again
	/// @param optionId The ID of the option the user is attempting to vote for again
	error UserAlreadyVotedThisOption(address voter, uint256 optionId);

	/// @notice Adds a new option to the question
	/// @dev Requires the caller to have sufficient points. Implementers should emit an event after adding the option.
	/// @param _title The title of the new option
	/// @param _description The description of the new option
	/// @return optionId The ID of the newly added option
	function addOption(string memory _title, string memory _description) external returns (uint256 optionId);
}
