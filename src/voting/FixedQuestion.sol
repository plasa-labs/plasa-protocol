// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Question } from "./Question.sol";
import { IFixedQuestion, IQuestion } from "./interfaces/IFixedQuestion.sol";

/// @title Fixed Question Contract for Voting System
/// @dev Implements a fixed-choice voting system where users can vote only once on predefined options
/// @notice This contract allows the creation of questions with fixed options and enables users to cast a single vote
contract FixedQuestion is Question, IFixedQuestion {
	/// @dev Mapping to store user votes: user address => option ID
	mapping(address => uint256) private userVotes;

	/// @notice Initializes a new fixed question with predefined options
	/// @dev Sets up the initial state and options for the fixed question
	/// @param _space The address of the Space contract
	/// @param _title A short, descriptive title for the question
	/// @param _description A more detailed explanation of the question
	/// @param _deadline The timestamp after which voting will be closed
	/// @param _initialOptionTitles An array of titles for the initial voting options
	/// @param _initialOptionDescriptions An array of descriptions for the initial voting options
	constructor(
		address _space,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		string[] memory _initialOptionTitles,
		string[] memory _initialOptionDescriptions
	) Question(_space, _title, _description, _deadline) {
		questionType = QuestionType.Fixed;

		if (_initialOptionTitles.length != _initialOptionDescriptions.length) {
			revert MismatchedOptionArrays();
		}

		// Add initial options
		for (uint256 i = 0; i < _initialOptionTitles.length; i++) {
			_addOption(_initialOptionTitles[i], _initialOptionDescriptions[i]);
		}
	}

	/// @notice Processes a user's vote
	/// @dev Internal function to record a user's vote, ensuring they can only vote once
	/// @param optionId The ID of the option the user is voting for
	function _processVote(uint256 optionId) internal override {
		// Check if the user has already voted
		if (userVotes[msg.sender] != 0) {
			revert UserAlreadyVoted();
		}
		// Record the user's vote
		userVotes[msg.sender] = optionId;
	}

	/// @inheritdoc Question
	function hasVotedOption(address voter, uint256 optionId) public view override(IQuestion, Question) returns (bool) {
		return userVotes[voter] == optionId;
	}

	function canVote(address voter) public view override(IQuestion, Question) returns (bool) {
		return super.canVote(voter) && !hasVoted(voter);
	}
}
