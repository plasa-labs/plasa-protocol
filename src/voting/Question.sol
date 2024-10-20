// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IQuestion } from "./interfaces/IQuestion.sol";
import { ISpace } from "../spaces/interfaces/ISpace.sol";
import { IQuestionView } from "./interfaces/IQuestionView.sol";

/// @title Abstract Question Contract for Decentralized Voting System
/// @dev Implements base functionality for a voting question, inheriting from Ownable and IQuestion
/// @notice This contract allows users to vote on options and manages the voting process
abstract contract Question is Ownable, IQuestion {
	// State variables
	/// @notice The timestamp when the question was created
	uint256 public immutable override kickoff;

	/// @notice The title of the question
	string public override title;
	/// @notice A detailed description of the question
	string public override description;

	/// @notice The timestamp when voting ends
	uint256 public override deadline;

	/// @notice An array of voting options
	OptionData[] private _options;

	/// @notice The type of question (e.g., single choice, multiple choice)
	QuestionType public questionType;

	/// @notice The Space contract associated with this question
	ISpace public space;

	/// @notice The address of the user who created this question
	address public creator;

	/// @dev Modifier to check if the voting is still active
	/// @notice Reverts if the voting period has ended
	modifier whileActive() {
		if (!isActive()) revert VotingEnded();
		_;
	}

	/// @notice Constructor to initialize the question
	/// @dev Sets up the initial state of the question
	/// @param _space The address of the Space contract
	/// @param _title The title of the question
	/// @param _description The description of the question
	/// @param _deadline The deadline for voting
	constructor(
		address _space,
		string memory _title,
		string memory _description,
		uint256 _deadline
	) Ownable(msg.sender) {
		creator = msg.sender;
		space = ISpace(_space);
		kickoff = block.timestamp;
		title = _title;
		description = _description;
		deadline = _deadline;

		// Add an empty option at index 0
		_options.push(OptionData("", "", address(0), 0, 0));
	}

	/// @inheritdoc IQuestion
	function vote(uint256 optionId) external whileActive {
		if (optionId == 0 || optionId >= _options.length) revert InvalidOption();

		_processVote(optionId);

		OptionData storage option = _options[optionId];
		option.voteCount++;
		option.pointsAtDeadline += votingPower(msg.sender);

		uint256 timestamp = (block.timestamp / 1 days) * 1 days;
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
	function getOptions() external view returns (OptionData[] memory) {
		return _options;
	}

	/// @inheritdoc IQuestion
	function getOption(uint256 optionId) external view returns (OptionData memory) {
		if (optionId >= _options.length) revert InvalidOption();
		return _options[optionId];
	}

	// Internal functions

	/// @dev Processes a vote for a specific option
	/// @param optionId The ID of the option being voted for
	function _processVote(uint256 optionId) internal virtual;

	/// @dev Adds a new option to the question
	/// @param _title The title of the new option
	/// @param _description The description of the new option
	/// @return optionId The ID of the newly added option
	function _addOption(string memory _title, string memory _description) internal returns (uint256 optionId) {
		optionId = _options.length;
		_options.push(OptionData(_title, _description, msg.sender, 0, 0));
		emit NewOption(msg.sender, optionId, _title);
	}

	/// @inheritdoc IQuestion
	function isActive() public view returns (bool) {
		return block.timestamp < deadline;
	}

	/// @inheritdoc IQuestion
	function hasVotedOption(address voter, uint256 optionId) public view virtual returns (bool);

	function canVote(address) public view virtual returns (bool) {
		return isActive();
	}

	/// @inheritdoc IQuestion
	function hasVoted(address voter) public view returns (bool) {
		for (uint256 i = 1; i < _options.length; i++) {
			if (hasVotedOption(voter, i)) {
				return true;
			}
		}
		return false;
	}

	/// @inheritdoc IQuestion
	function totalVoteCount() public view returns (uint256) {
		uint256 totalVotes = 0;
		for (uint256 i = 1; i < _options.length; i++) {
			totalVotes += _options[i].voteCount;
		}
		return totalVotes;
	}

	/// @inheritdoc IQuestion
	function votingPower(address user) public view returns (uint256) {
		return space.defaultPoints().balanceAtTimestamp(user, deadline);
	}

	/// @dev Creates an array of OptionView structs for a given user
	/// @param user The address of the user to create views for
	/// @return An array of OptionView structs
	function _optionsViews(address user) private view returns (OptionView[] memory) {
		OptionView[] memory _views = new OptionView[](_options.length);
		for (uint256 i = 1; i < _views.length; i++) {
			_views[i] = OptionView(_options[i], OptionUser(hasVotedOption(user, i)));
		}
		return _views;
	}

	/// @dev Creates a QuestionData struct with current question information
	/// @return A QuestionData struct
	function _questionData() internal view returns (QuestionData memory) {
		return
			QuestionData(
				address(this),
				questionType,
				title,
				description,
				creator,
				kickoff,
				deadline,
				isActive(),
				totalVoteCount()
			);
	}

	/// @dev Creates a QuestionUser struct for a given user
	/// @param user The address of the user to create the struct for
	/// @return A QuestionUser struct
	function _questionUser(address user) private view returns (QuestionUser memory) {
		return QuestionUser(canVote(user), votingPower(user));
	}

	/// @inheritdoc IQuestionView
	function getQuestionView(address user) external view returns (QuestionView memory) {
		return QuestionView(_questionData(), _questionUser(user), _optionsViews(user));
	}

	/// @inheritdoc IQuestionView
	function getQuestionPreview(address user) external view returns (QuestionPreview memory) {
		return QuestionPreview(_questionData(), _questionUser(user));
	}
}
