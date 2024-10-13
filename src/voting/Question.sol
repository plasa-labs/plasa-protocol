// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IQuestion, QuestionStatus } from "./interfaces/IQuestion.sol";
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
	QuestionType public immutable questionType;

	// Mapping to store vote counts for each option
	mapping(uint256 optionId => uint256 count) public optionVoteCounts;
	// Mapping to store points accrued for each option
	mapping(uint256 optionId => uint256 points) public optionPointsAccrued;

	/// @dev Modifier to check if the voting is still active
	modifier whileActive() {
		if (block.timestamp >= deadline) revert VotingEnded();
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

	/// @inheritdoc IQuestion
	function getQuestionView(address user) external view returns (QuestionView memory) {
		uint256 totalVotes = 0;
		// Adjust the array size to exclude the empty option at index 0
		OptionView[] memory optionViews = new OptionView[](options.length - 1);
		uint256 userOptionVoted = 0;

		// Start the loop from index 1 to skip the empty option
		for (uint256 i = 1; i < options.length; i++) {
			uint256 voteCount = optionVoteCounts[i];
			totalVotes += voteCount;
			bool userVotedForOption = hasVoted(user, i);
			// Adjust the index for optionViews to start at 0
			optionViews[i - 1] = OptionView({
				title: options[i].title,
				description: options[i].description,
				proposer: options[i].proposer,
				voteCount: voteCount,
				pointsAccrued: optionPointsAccrued[i],
				userVoted: userVotedForOption
			});

			if (userVotedForOption) {
				userOptionVoted = i;
			}
		}

		return
			QuestionView({
				questionType: questionType,
				title: title,
				description: description,
				deadline: deadline,
				totalVoteCount: totalVotes,
				options: optionViews,
				status: getStatus(),
				owner: owner(),
				started: deploymentTime,
				userOptionVoted: userOptionVoted,
				userPointsCurrent: points.balanceOf(user),
				userPointsDeadline: points.balanceAtTimestamp(user, deadline),
				userCanAddOption: canAddOption(user)
			});
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
	function getStatus() public view returns (QuestionStatus) {
		if (block.timestamp < deadline) {
			return QuestionStatus.Active;
		} else {
			return QuestionStatus.Ended;
		}
	}

	/// @inheritdoc IQuestion
	function hasVoted(address voter, uint256 optionId) public view virtual returns (bool);

	/// @dev Checks if a user can add an option
	/// @param user The address of the user to check
	/// @return bool True if the user can add an option, false otherwise
	function canAddOption(address user) public view virtual returns (bool);
}
