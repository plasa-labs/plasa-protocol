// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoints } from "../../points/interfaces/IPoints.sol";
import { IQuestionView } from "./IQuestionView.sol";

/// @title Question Interface for a Voting System
/// @dev Interface for managing questions in a voting system with various options and views
interface IQuestion is IQuestionView {
	// Events
	/// @dev Emitted when a question is updated
	/// @param newTitle The new title of the question
	/// @param newDescription The new description of the question
	/// @param newDeadline The new deadline for voting
	event QuestionUpdated(string newTitle, string newDescription, uint256 newDeadline);

	/// @dev Emitted when a vote is cast
	/// @param voter The address of the voter
	/// @param optionId The ID of the option voted for
	/// @param timestamp The timestamp of the vote
	event Voted(address indexed voter, uint256 indexed optionId, uint256 timestamp);

	/// @dev Emitted when a new option is added
	/// @param proposer The address of the proposer
	/// @param optionId The ID of the new option
	/// @param title The title of the new option
	event NewOption(address indexed proposer, uint256 indexed optionId, string title);

	// Errors
	/// @dev Thrown when trying to vote after the deadline
	error VotingEnded();

	/// @dev Thrown when a user tries to vote more than once
	error AlreadyVoted();

	/// @dev Thrown when an invalid option is selected
	error InvalidOption();

	// Public variables
	/// @notice Get the title of the question
	/// @return The title of the question
	function title() external view returns (string memory);

	/// @notice Get the description of the question
	/// @return The description of the question
	function description() external view returns (string memory);

	/// @notice Get the deadline for voting
	/// @return The timestamp of the voting deadline
	function deadline() external view returns (uint256);

	// External functions
	/// @notice Cast a vote for an option
	/// @param optionId The ID of the option to vote for
	function vote(uint256 optionId) external;

	/// @notice Update the title of the question
	/// @param _title The new title
	function updateTitle(string memory _title) external;

	/// @notice Update the description of the question
	/// @param _description The new description
	function updateDescription(string memory _description) external;

	/// @notice Update the deadline of the question
	/// @param _deadline The new deadline timestamp
	function updateDeadline(uint256 _deadline) external;

	/// @notice Get all options for the question
	/// @return An array of all Option structs
	function getOptions() external view returns (Option[] memory);

	/// @notice Get a specific option by its ID
	/// @param optionId The ID of the option to retrieve
	/// @return The Option struct for the specified ID
	function getOption(uint256 optionId) external view returns (Option memory);

	// Public functions
	/// @notice Check if the question is currently active
	/// @return True if the question is active, false otherwise
	function isActive() external view returns (bool);

	/// @notice Check if a specific user has voted for a specific option
	/// @param voter The address of the voter to check
	/// @param optionId The ID of the option to check
	/// @return True if the user has voted for the option, false otherwise
	function hasVotedOption(address voter, uint256 optionId) external view returns (bool);

	/// @notice Check if a specific user has voted for any option
	/// @param voter The address of the voter to check
	/// @return True if the user has voted for any option, false otherwise
	function hasVoted(address voter) external view returns (bool);

	/// @notice Get the deployment time of the question contract
	/// @return The timestamp when the contract was deployed
	function deploymentTime() external view returns (uint256);
}
