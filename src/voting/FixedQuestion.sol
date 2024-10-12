// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Question } from "./Question.sol";

contract FixedQuestion is Question {
	// Mapping to store user votes
	mapping(address => uint256) private userVotes;

	// Custom errors
	error UserAlreadyVoted();

	constructor(
		address initialOwner,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		address _pointsAddress,
		Option[] memory initialOptions
	) Question(initialOwner, _title, _description, _deadline, _pointsAddress) {
		questionType = QuestionType.Fixed;
		for (uint256 i = 0; i < initialOptions.length; i++) {
			_addOption(initialOptions[i].title, initialOptions[i].description);
		}
	}

	function _processVote(uint256 optionId) internal override {
		// Implement voting logic
		if (userVotes[msg.sender] != 0) {
			revert UserAlreadyVoted();
		}
		userVotes[msg.sender] = optionId;
	}

	function hasVoted(address voter, uint256 optionId) public view override returns (bool) {
		return userVotes[voter] == optionId;
	}
}
