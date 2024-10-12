// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IQuestion } from "./interfaces/IQuestion.sol";
import { IPoints } from "../points/interfaces/IPoints.sol";

abstract contract Question is Ownable, IQuestion {
	// State variables
	string public title;
	string public description;
	uint256 public deadline;
	IPoints public immutable points;
	Option[] private options;

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
		points = IPoints(_pointsAddress);

		// Add an empty option at index 0
		options.push(Option("", "", msg.sender));
	}

	// External functions
	function vote(uint256 optionId) external {
		if (block.timestamp >= deadline) revert VotingEnded();
		if (optionId == 0 || optionId > options.length) revert InvalidOption();

		_beforeVoting(optionId);
		_vote(optionId);

		uint256 timestamp = (block.timestamp / 1 days) * 1 days;
		emit Voted(msg.sender, optionId, timestamp);
	}

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

	// External view functions
	function getOptions() external view returns (Option[] memory) {
		return options;
	}

	function getOption(uint256 optionId) external view returns (Option memory) {
		if (optionId >= options.length) revert InvalidOption();
		return options[optionId];
	}

	function getQuestionView(address user) external view returns (QuestionView memory) {
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
				options: optionViews,
				status: getStatus(),
				owner: owner()
			});
	}

	// Internal functions
	function _beforeVoting(uint256 optionId) internal virtual;

	function _vote(uint256 optionId) internal virtual;

	function _addOption(string memory _title, string memory _description) internal {
		uint256 optionId = options.length;
		options.push(Option(_title, _description, msg.sender));
		emit NewOption(msg.sender, optionId, _title);
	}

	function getStatus() public view returns (Status) {
		if (block.timestamp < deadline) {
			return Status.Active;
		} else {
			return Status.Ended;
		}
	}

	function getOptionVoteCount(uint256 optionId) public view virtual returns (uint256);

	function getOptionPointsAccrued(uint256 optionId) public view virtual returns (uint256);

	function hasVoted(address voter, uint256 optionId) public view virtual returns (bool);
}
