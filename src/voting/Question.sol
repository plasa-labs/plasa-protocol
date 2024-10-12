// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Question is Ownable {
	// Errors
	error VotingEnded();
	error AlreadyVoted();
	error InvalidOption();

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

	// New struct for question view
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
	}

	// State variables
	string public title;
	string public description;
	uint256 public deadline;
	IERC20 public immutable points;

	// Arrays
	Option[] private options;

	// Mappings
	mapping(address => uint256) public voterToOptionId;
	mapping(uint256 => uint256) public voteCounts;

	// Events
	event QuestionUpdated(string newTitle, string newDescription, uint256 newDeadline);
	event Voted(address indexed voter, uint256 indexed optionId, uint256 timestamp);
	event NewOption(address indexed proposer, uint256 indexed optionId, string title);

	// Constructor
	constructor(
		address initialOwner,
		string memory _title,
		string memory _description,
		uint256 _deadline,
		address _pointsAddress
	) Ownable(initialOwner) {
		title = _title;
		description = _description;
		deadline = _deadline;
		points = IERC20(_pointsAddress);

		// Add an empty option at index 0
		options.push(Option("", "", msg.sender));
	}

	// External functions
	function vote(uint256 optionId) external virtual {
		if (block.timestamp >= deadline) revert VotingEnded();
		if (optionId == 0 || optionId > options.length) revert InvalidOption();

		_beforeVoting(optionId);
		_vote(optionId);

		uint256 timestamp = (block.timestamp / 1 days) * 1 days;
		emit Voted(msg.sender, optionId, timestamp);
	}

	function getOptions() external view virtual returns (Option[] memory) {
		return options;
	}

	function getOption(uint256 optionId) external view virtual returns (Option memory) {
		if (optionId >= options.length) revert InvalidOption();
		return options[optionId];
	}

	function getOptionVoteCount(uint256 optionId) internal view virtual returns (uint256);

	function getOptionPointsAccrued(uint256 optionId) internal view virtual returns (uint256);

	function hasVoted(address voter, uint256 optionId) internal view virtual returns (bool);

	// External functions (onlyOwner)
	function updateTitle(string memory _title) external onlyOwner {
		title = _title;
		emit QuestionUpdated(_title, description, deadline);
	}

	function updateDescription(string memory _description) external onlyOwner {
		description = _description;
		emit QuestionUpdated(title, _description, deadline);
	}

	function updateDeadline(uint256 _deadline) external onlyOwner {
		deadline = _deadline;
		emit QuestionUpdated(title, description, _deadline);
	}

	// Internal functions
	function _beforeVoting(uint256 optionId) internal virtual;

	function _vote(uint256 optionId) internal virtual;

	function _addOption(string memory _title, string memory _description) internal virtual {
		uint256 optionId = options.length;
		options.push(Option(_title, _description, msg.sender));
		emit NewOption(msg.sender, optionId, _title);
	}

	function getStatus() external view returns (Status) {
		if (block.timestamp < deadline) {
			return Status.Active;
		} else {
			return Status.Ended;
		}
	}

	// New function to get question view
	function getQuestionView(address user) external view virtual returns (QuestionView memory) {
		uint256 totalVotes = 0;
		OptionView[] memory optionViews = new OptionView[](options.length);

		for (uint256 i = 0; i < options.length; i++) {
			uint256 voteCount = getOptionVoteCount(i);
			totalVotes += voteCount;
			optionViews[i] = OptionView({
				title: options[i].title,
				description: options[i].description,
				proposer: options[i].proposer,
				voteCount: voteCount,
				pointsAccrued: getOptionPointsAccrued(i),
				userVoted: hasVoted(user, i)
			});
		}

		return
			QuestionView({
				title: title,
				description: description,
				deadline: deadline,
				totalVoteCount: totalVotes,
				options: optionViews
			});
	}
}
