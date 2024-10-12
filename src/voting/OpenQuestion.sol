// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Question } from "./Question.sol";
import { IOpenQuestion, IQuestion } from "./interfaces/IOpenQuestion.sol";

/// @title OpenQuestion Contract
/// @dev Implements an open-ended question where users can add options and vote
contract OpenQuestion is Question, IOpenQuestion {
	// Mapping to store user votes for each option
	mapping(address voter => mapping(uint256 optionId => bool hasVoted)) private userVotes;

	/// @inheritdoc IOpenQuestion
	/// @notice Minimum points required to add an option
	uint256 public override minPointsToAddOption;

	/// @notice Initializes the OpenQuestion contract
	/// @dev Sets up the question details and minimum points required to add an option
	/// @param initialOwner The address of the initial owner of the question
	/// @param _title The title of the question
	/// @param _description The description of the question
	/// @param _deadline The deadline for voting on the question
	/// @param _pointsAddress The address of the Points contract
	/// @param _minPointsToAddOption The minimum points required to add a new option
	constructor(
		address initialOwner,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		address _pointsAddress,
		uint256 _minPointsToAddOption
	) Question(initialOwner, _title, _description, _deadline, _pointsAddress) {
		questionType = QuestionType.Open;
		minPointsToAddOption = _minPointsToAddOption;
	}

	/// @inheritdoc IOpenQuestion
	/// @notice Adds a new option to the question
	/// @dev Checks if the user has sufficient points to add the option
	/// @param _title The title of the new option
	/// @param _description The description of the new option
	function addOption(string memory _title, string memory _description) external override {
		if (points.balanceAtTimestamp(msg.sender, deadline) < minPointsToAddOption) {
			revert InsufficientPoints();
		}
		_addOption(_title, _description);
	}

	/// @notice Processes a vote for a specific option
	/// @dev Overrides the base _processVote function to check for duplicate votes
	/// @param optionId The ID of the option being voted for
	function _processVote(uint256 optionId) internal override {
		if (userVotes[msg.sender][optionId]) {
			revert UserAlreadyVotedThisOption(msg.sender, optionId);
		}
		userVotes[msg.sender][optionId] = true;
	}

	/// @inheritdoc IQuestion
	/// @notice Checks if a user has voted for a specific option
	/// @dev Returns true if the user has voted for the option, false otherwise
	/// @param voter The address of the user
	/// @param optionId The ID of the option
	function hasVoted(
		address voter,
		uint256 optionId
	) public view override(IQuestion, Question) returns (bool) {
		return userVotes[voter][optionId];
	}

	/// @inheritdoc IOpenQuestion
	/// @notice Updates the minimum points required to add a new option
	/// @dev Only callable by the owner
	/// @param _minPointsToAddOption The new minimum points required
	function updateMinPointsToAddOption(uint256 _minPointsToAddOption) external override onlyOwner {
		minPointsToAddOption = _minPointsToAddOption;
		emit MinPointsToAddOptionUpdated(_minPointsToAddOption);
	}
}
