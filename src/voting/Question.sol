// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IQuestion } from "./interfaces/IQuestion.sol";
import { IPoints } from "../points/interfaces/IPoints.sol";

/// @title Abstract Question Contract for Voting System
/// @dev This contract implements the base functionality for a voting question
/// @notice This contract allows users to vote on options and manages the voting process
abstract contract Question is Ownable, IQuestion {
	// State variables
	uint256 public immutable deploymentTime;
	string public title;
	string public description;
	uint256 public deadline;
	IPoints public immutable points;
	Option[] private options;
	QuestionType public questionType;

	// Mapping to store vote counts for each option
	mapping(uint256 optionId => uint256 count) public optionVoteCounts;
	// Mapping to store points accrued for each option
	mapping(uint256 optionId => uint256 points) public optionPointsAccrued;

	/// @dev Modifier to check if the voting is still active
	modifier whileActive() {
		if (!isActive()) revert VotingEnded();
		_;
	}

	/// @notice Constructor to initialize the question
	/// @dev Sets up the initial state of the question
	/// @param initialOwner The address of the initial owner of the contract
	/// @param _title The title of the question
	/// @param _description The description of the question
	/// @param _deadline The deadline for voting
	/// @param _pointsAddress The address of the Points contract
	constructor(
		address initialOwner,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		address _pointsAddress
	) Ownable(initialOwner) {
		deploymentTime = block.timestamp;
		title = _title;
		description = _description;
		deadline = _deadline;
		points = IPoints(_pointsAddress);

		// Add an empty option at index 0
		options.push(Option("", "", msg.sender));
	}

	/// @inheritdoc IQuestion
	function vote(uint256 optionId) external whileActive {
		if (optionId == 0 || optionId > options.length) revert InvalidOption();

		_processVote(optionId);

		uint256 timestamp = (block.timestamp / 1 days) * 1 days;

		optionVoteCounts[optionId]++;
		optionPointsAccrued[optionId] += points.balanceAtTimestamp(msg.sender, deadline);

		emit Voted(msg.sender, optionId, timestamp);
	}

	/// @inheritdoc IQuestion
	function updateTitle(string memory _title) external onlyOwner {
		title = _title;
		emit QuestionUpdated(_title, description, deadline);
	}

	/// @inheritdoc IQuestion
	function updateDescription(string memory _description) external onlyOwner {
		description = _description;
		emit QuestionUpdated(title, _description, deadline);
	}

	/// @inheritdoc IQuestion
	function updateDeadline(uint256 _deadline) external onlyOwner {
		deadline = _deadline;
		emit QuestionUpdated(title, description, _deadline);
	}

	/// @inheritdoc IQuestion
	function getOptions() external view returns (Option[] memory) {
		return options;
	}

	/// @inheritdoc IQuestion
	function getOption(uint256 optionId) external view returns (Option memory) {
		if (optionId >= options.length) revert InvalidOption();
		return options[optionId];
	}

	// Internal functions

	/// @dev Processes a vote for a specific option
	/// @param optionId The ID of the option being voted for
	function _processVote(uint256 optionId) internal virtual;

	/// @dev Adds a new option to the question
	/// @param _title The title of the new option
	/// @param _description The description of the new option
	function _addOption(string memory _title, string memory _description) internal {
		uint256 optionId = options.length;
		options.push(Option(_title, _description, msg.sender));
		emit NewOption(msg.sender, optionId, _title);
	}

	/// @inheritdoc IQuestion
	function isActive() public view returns (bool) {
		return block.timestamp < deadline;
	}

	/// @inheritdoc IQuestion
	function hasVotedOption(address voter, uint256 optionId) public view virtual returns (bool);

	/// @inheritdoc IQuestion
	function hasVoted(address voter) public view returns (bool) {
		for (uint256 i = 1; i < options.length; i++) {
			if (hasVotedOption(voter, i)) {
				return true;
			}
		}
		return false;
	}

	/// @dev Checks if a user can add an option
	/// @param user The address of the user to check
	/// @return bool True if the user can add an option, false otherwise
	function canAddOption(address user) public view virtual returns (bool);

	// Helper function to get total vote count
	function getTotalVoteCount() internal view returns (uint256) {
		uint256 totalVotes = 0;
		for (uint256 i = 1; i < options.length; i++) {
			totalVotes += optionVoteCounts[i];
		}
		return totalVotes;
	}
}
