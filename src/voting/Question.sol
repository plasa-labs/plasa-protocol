// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract Question is Ownable {
	// State variables
	string public title;
	string public description;
	uint256 public deadline;

	// Structs
	struct Option {
		string title;
		string description;
	}

	// Arrays
	Option[] public options;

	// Mappings
	mapping(address => uint256) public voterToOptionId;
	mapping(uint256 => uint256) public voteCounts;

	// Events
	event QuestionUpdated(string newTitle, string newDescription, uint256 newDeadline);
	event Voted(address indexed voter, uint256 indexed optionId, uint256 timestamp);
	event NewOption(address indexed proposer, uint256 indexed optionId, string title);

	// Errors
	error VotingEnded();
	error AlreadyVoted();
	error InvalidOption();

	// IERC20 points variable
	IERC20 public points;

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
		options.push(Option("", ""));
	}

	// External functions
	function vote(uint256 optionId) public virtual {
		if (block.timestamp >= deadline) revert VotingEnded();
		if (optionId == 0 || optionId > options.length) revert InvalidOption();

		_beforeVoting(optionId);
		_vote(optionId);

		uint256 timestamp = (block.timestamp / 1 days) * 1 days;
		emit Voted(msg.sender, optionId, timestamp);
	}

	function getOptions() public view virtual returns (Option[] memory) {
		return options;
	}

	function getOption(uint256 optionId) public view virtual returns (Option memory) {
		if (optionId == 0 || optionId > options.length) revert InvalidOption();
		return options[optionId - 1];
	}

	function getOptionVoteCount(uint256 optionId) public view virtual returns (uint256);

	function getOptionPointsAccrued(uint256 optionId) public view virtual returns (uint256);

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
		uint256 optionId = options.length + 1;
		options.push(Option(_title, _description));
		emit NewOption(msg.sender, optionId, _title);
	}
}
