// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestionView } from "./IQuestionView.sol";
import { ISpace } from "../../spaces/interfaces/ISpace.sol";
import { IPoints } from "../../points/interfaces/IPoints.sol";
import { ISpaceAccessControl } from "../../spaces/interfaces/ISpaceAccessControl.sol";

/// @title Question Interface for a Decentralized Voting System
/// @dev Interface for managing questions, options, and votes in a decentralized voting system
/// @notice This interface provides functions for creating, updating, and interacting with voting questions
interface IQuestion is IQuestionView {
	// Events
	/// @dev Emitted when a question's title is updated
	/// @param newTitle The updated title of the question
	event QuestionTitleUpdated(string newTitle);

	/// @dev Emitted when a question's description is updated
	/// @param newDescription The updated description of the question
	event QuestionDescriptionUpdated(string newDescription);

	/// @dev Emitted when a question's deadline is updated
	/// @param newDeadline The updated deadline for voting
	event QuestionDeadlineUpdated(uint256 newDeadline);

	/// @dev Emitted when a question's tags are updated
	/// @param newTags The updated tags for the question
	event QuestionTagsUpdated(string[] newTags);

	/// @dev Emitted when a vote is cast
	/// @param voter The address of the voter
	/// @param name The username of the voter
	/// @param optionId The ID of the option voted for
	/// @param points The number of points the voter used to vote
	/// @param timestamp The timestamp when the vote was cast
	event Voted(address voter, string name, uint256 indexed optionId, uint256 points, uint256 timestamp);

	/// @dev Emitted when a new voting option is added
	/// @param proposer The address of the account proposing the new option
	/// @param optionId The ID assigned to the new option
	/// @param title The title of the new option
	event NewOption(address indexed proposer, uint256 indexed optionId, string title);

	// Errors
	/// @dev Thrown when an attempt is made to vote after the voting deadline
	error VotingEnded();

	/// @dev Thrown when a user tries to vote more than once
	error AlreadyVoted();

	/// @dev Thrown when an invalid option ID is provided for voting
	error InvalidOption();

	/// @dev Thrown when a user is not allowed to perform an action
	error NotAllowed(address user, ISpaceAccessControl.PermissionName permissionName);

	// Public variables
	/// @notice Retrieves the title of the question
	/// @return The current title of the question
	function title() external view returns (string memory);

	/// @notice Retrieves the description of the question
	/// @return The current description of the question
	function description() external view returns (string memory);

	/// @notice Retrieves the deadline for voting on this question
	/// @return The timestamp representing the voting deadline
	function deadline() external view returns (uint256);

	// External functions
	/// @notice Allows a user to cast a vote for a specific option
	/// @dev Emits a Voted event upon successful voting
	/// @param optionId The ID of the option to vote for
	function vote(uint256 optionId) external;

	/// @notice Updates the title of the question
	/// @dev Only callable by authorized roles (e.g., admin)
	/// @param _title The new title to set for the question
	function updateTitle(string memory _title) external;

	/// @notice Updates the description of the question
	/// @dev Only callable by authorized roles (e.g., admin)
	/// @param _description The new description to set for the question
	function updateDescription(string memory _description) external;

	/// @notice Updates the voting deadline for the question
	/// @dev Only callable by authorized roles (e.g., admin)
	/// @param _deadline The new deadline timestamp to set
	function updateDeadline(uint256 _deadline) external;

	/// @notice Retrieves all available voting options for the question
	/// @return An array of OptionData structs representing all voting options
	function getOptions() external view returns (OptionStorage[] memory);

	/// @notice Retrieves a specific voting option by its ID
	/// @param optionId The ID of the option to retrieve
	/// @return The OptionData struct for the specified option ID
	function getOption(uint256 optionId) external view returns (OptionStorage memory);

	// Public functions
	/// @notice Checks if the voting period for this question is currently active
	/// @return True if voting is active, false otherwise
	function isActive() external view returns (bool);

	/// @notice Checks if a specific user has voted for a particular option
	/// @param voter The address of the voter to check
	/// @param optionId The ID of the option to check against
	/// @return True if the user has voted for the specified option, false otherwise
	function hasVotedOption(address voter, uint256 optionId) external view returns (bool);

	/// @notice Checks if a specific user has voted for any option
	/// @param voter The address of the voter to check
	/// @return True if the user has cast any vote, false otherwise
	function hasVoted(address voter) external view returns (bool);

	/// @notice Checks if a specific user is eligible to vote
	/// @param voter The address of the potential voter to check
	/// @return True if the user can vote, false otherwise
	function canVote(address voter) external view returns (bool);

	/// @notice Retrieves the deployment timestamp of the question contract
	/// @return The timestamp when the contract was deployed
	function kickoff() external view returns (uint256);

	/// @notice Calculates the total number of votes cast for all options
	/// @dev This function iterates through all options to sum up the votes
	/// @return The total number of votes cast for the question
	function totalVoteCount() external view returns (uint256);

	/// @notice Determines the voting power of a user at the voting deadline
	/// @dev This function should return the user's balance of voting points at the deadline
	/// @param user The address of the user to check
	/// @return The voting power (point balance) of the user at the voting deadline
	function votingPower(address user) external view returns (uint256);

	/// @notice Retrieves the type of question
	/// @return The type of question
	function questionType() external view returns (QuestionType);

	// Additional state variables
	/// @notice The Space contract associated with this question
	function space() external view returns (ISpace);

	/// @notice The Points contract associated with this question
	function points() external view returns (IPoints);

	/// @notice The address of the user who created this question
	function creator() external view returns (address);

	/// @notice Get a tag at a specific index
	function tags(uint256 index) external view returns (string memory);

	// Additional functions
	/// @notice Updates the tags associated with the question
	/// @param _tags The new array of tags
	function updateTags(string[] memory _tags) external;
}
