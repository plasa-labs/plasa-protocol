// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Question } from "./Question.sol";
import { IOpenQuestion, IQuestion } from "./interfaces/IOpenQuestion.sol";
import { ISpaceAccessControl } from "../spaces/interfaces/ISpaceAccessControl.sol";

/// @title OpenQuestion Contract
/// @dev Implements an open-ended question where users can add options and vote
contract OpenQuestion is Question, IOpenQuestion {
	// Mapping to store user votes for each option
	mapping(address user => mapping(uint256 optionId => bool hasVoted)) private userVotes;

	/// @notice Mapping to track if an option is vetoed
	mapping(uint256 => bool) public vetoed;

	/// @notice Initializes the OpenQuestion contract
	/// @dev Sets up the question details and minimum points required to add an option
	/// @param _space The address of the Space contract
	/// @param _title The title of the question
	/// @param _description The description of the question
	/// @param _deadline The deadline for voting on the question
	/// @param _tags The array of tags associated with this question
	constructor(
		address _space,
		address _points,
		string memory _title,
		string memory _description,
		string[] memory _tags,
		uint256 _deadline,
		address _plasa
	)
		Question(_space, _points, _title, _description, _deadline, _tags, _plasa)
		onlyAllowed(ISpaceAccessControl.PermissionName.CreateOpenQuestion)
	{
		questionType = QuestionType.Open;
	}

	/// @inheritdoc IOpenQuestion
	function addOption(
		string memory _title,
		string memory _description
	) external whileActive returns (uint256 optionId) {
		if (!space.canAddOpenQuestionOption(msg.sender)) revert InsufficientPoints();

		optionId = _addOption(_title, _description);
	}

	/// @inheritdoc IOpenQuestion
	function vetoOption(
		uint256 optionId
	)
		external
		whileActive
		validOption(optionId)
		onlyAllowed(ISpaceAccessControl.PermissionName.VetoOpenQuestionOption)
	{
		vetoed[optionId] = true;

		emit OptionVetoed(msg.sender, optionId);
	}

	/// @inheritdoc IOpenQuestion
	function liftOptionVeto(
		uint256 optionId
	)
		external
		whileActive
		validOption(optionId)
		onlyAllowed(ISpaceAccessControl.PermissionName.LiftVetoOpenQuestionOption)
	{
		vetoed[optionId] = false;

		emit OptionVetoLifted(msg.sender, optionId);
	}

	/// @inheritdoc Question
	function _isVetoed(uint256 optionId) internal view override returns (bool) {
		return vetoed[optionId];
	}

	/// @notice Processes a vote for a specific option
	/// @dev Overrides the base _processVote function to check for duplicate votes
	/// @param optionId The ID of the option being voted for
	function _processVote(uint256 optionId) internal override {
		if (userVotes[msg.sender][optionId]) revert UserAlreadyVotedOption(msg.sender, optionId);

		userVotes[msg.sender][optionId] = true;
	}

	/// @inheritdoc IQuestion
	function hasVotedOption(address voter, uint256 optionId) public view override(IQuestion, Question) returns (bool) {
		return userVotes[voter][optionId];
	}
}
