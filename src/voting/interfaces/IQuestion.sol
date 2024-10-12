// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IPoints } from "../../points/interfaces/IPoints.sol";

interface IQuestion {
	// Enums
	enum Status {
		Null,
		Active,
		Ended
	}

	// Structs
	struct Option {
		string title;
		string description;
		address proposer;
	}

	struct OptionView {
		string title;
		string description;
		address proposer;
		uint256 voteCount;
		uint256 pointsAccrued;
		bool userVoted;
	}

	struct QuestionView {
		string title;
		string description;
		uint256 deadline;
		uint256 totalVoteCount;
		OptionView[] options;
		Status status;
		address owner;
	}

	// Events
	event QuestionUpdated(string newTitle, string newDescription, uint256 newDeadline);
	event Voted(address indexed voter, uint256 indexed optionId, uint256 timestamp);
	event NewOption(address indexed proposer, uint256 indexed optionId, string title);

	// Errors
	error VotingEnded();
	error AlreadyVoted();
	error InvalidOption();

	// Public variables
	function title() external view returns (string memory);

	function description() external view returns (string memory);

	function deadline() external view returns (uint256);

	function points() external view returns (IPoints);

	// External functions
	function vote(uint256 optionId) external;

	function updateTitle(string memory _title) external;

	function updateDescription(string memory _description) external;

	function updateDeadline(uint256 _deadline) external;

	function getOptions() external view returns (Option[] memory);

	function getOption(uint256 optionId) external view returns (Option memory);

	function getQuestionView(address user) external view returns (QuestionView memory);

	// Public functions
	function getStatus() external view returns (Status);

	function getOptionVoteCount(uint256 optionId) external view returns (uint256);

	function getOptionPointsAccrued(uint256 optionId) external view returns (uint256);

	function hasVoted(address voter, uint256 optionId) external view returns (bool);
}
