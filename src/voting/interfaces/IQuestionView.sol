// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

interface IQuestionView {
	enum QuestionType {
		Null,
		Open,
		Fixed
	}

	struct QuestionData {
		address contractAddress;
		QuestionType questionType;
		string title;
		string description;
		address creator;
		uint256 kickoff;
		uint256 deadline;
		bool isActive;
		uint256 voteCount;
	}

	struct QuestionUser {
		bool canVote;
		uint256 pointsAtDeadline;
	}

	struct OptionData {
		string title;
		string description;
		address proposer;
		uint256 voteCount;
		uint256 pointsCurrent;
		uint256 pointsAtDeadline;
	}

	struct OptionUser {
		bool voted;
	}

	struct Option {
		OptionData data;
		OptionUser user;
	}

	struct QuestionPreview {
		QuestionData data;
		QuestionUser user;
	}

	struct QuestionView {
		QuestionData data;
		QuestionUser user;
		Option[] options;
	}

	/// @notice Get a comprehensive view of the question for a specific user
	/// @param user The address of the user to get the view for
	/// @return A QuestionView struct with all question details
	function getQuestionView(address user) external view returns (QuestionView memory);

	/// @notice Get a preview of the question for a specific user
	/// @param user The address of the user to get the preview for
	/// @return A QuestionPreview struct with question preview details
	function getQuestionPreview(address user) external view returns (QuestionPreview memory);
}
