// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Question } from "./Question.sol";
import { IFixedQuestion, IQuestion } from "./interfaces/IFixedQuestion.sol";

/// @title Fixed Question Contract for Voting System
/// @dev Implements a fixed-choice voting system where users can only vote once
/// @notice This contract allows users to vote on predefined options, with each user limited to one vote
contract FixedQuestion is Question, IFixedQuestion {
	// Mapping to store user votes: user address => option ID
	mapping(address => uint256) private userVotes;

	/// @notice Constructor to initialize the fixed question
	/// @dev Sets up the initial state and options for the fixed question
	/// @param initialOwner The address of the initial owner of the contract
	/// @param _title The title of the question
	/// @param _description The description of the question
	/// @param _deadline The deadline for voting
	/// @param _pointsAddress The address of the Points contract
	/// @param initialOptions An array of initial options for the question
	constructor(
		address initialOwner,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		address _pointsAddress,
		Option[] memory initialOptions
	) Question(initialOwner, _title, _description, _deadline, _pointsAddress) {
		questionType = QuestionType.Fixed;
		// Add initial options
		for (uint256 i = 0; i < initialOptions.length; i++) {
			_addOption(initialOptions[i].title, initialOptions[i].description);
		}
	}

	/// @inheritdoc Question
	function _processVote(uint256 optionId) internal override {
		// Check if the user has already voted
		if (userVotes[msg.sender] != 0) {
			revert UserAlreadyVoted();
		}
		// Record the user's vote
		userVotes[msg.sender] = optionId;
	}

	/// @inheritdoc Question
	function hasVoted(
		address voter,
		uint256 optionId
	) public view override(IQuestion, Question) returns (bool) {
		return userVotes[voter] == optionId;
	}
}
