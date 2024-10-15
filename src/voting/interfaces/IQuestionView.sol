// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Question View Interface
/// @notice Interface for retrieving question and option data for users
/// @dev This interface defines structures and functions for viewing question details
interface IQuestionView {
	/// @notice Enum representing the type of question
	enum QuestionType {
		Null,
		Open,
		Fixed
	}

	/// @notice Struct containing question data
	/// @dev This struct holds all the relevant information about a question
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

	/// @notice Struct containing user-specific question data
	/// @dev This struct holds information about a user's interaction with a question
	struct QuestionUser {
		bool canVote;
		uint256 pointsAtDeadline;
	}

	/// @notice Struct containing option data
	/// @dev This struct holds all the relevant information about an option
	struct OptionData {
		string title;
		string description;
		address proposer;
		uint256 voteCount;
		uint256 pointsAtDeadline;
	}

	/// @notice Struct containing user-specific option data
	/// @dev This struct holds information about a user's interaction with an option
	struct OptionUser {
		bool voted;
	}

	/// @notice Struct combining option data and user-specific option data
	struct OptionView {
		OptionData data;
		OptionUser user;
	}

	/// @notice Struct combining question data and user-specific question data for previews
	struct QuestionPreview {
		QuestionData data;
		QuestionUser user;
	}

	/// @notice Struct containing comprehensive question view data
	/// @dev This struct combines question data, user data, and option data
	struct QuestionView {
		QuestionData data;
		QuestionUser user;
		OptionView[] options;
	}

	/// @notice Get a comprehensive view of the question for a specific user
	/// @dev This function returns all question details including options
	/// @param user The address of the user to get the view for
	/// @return A QuestionView struct with all question details
	function getQuestionView(address user) external view returns (QuestionView memory);

	/// @notice Get a preview of the question for a specific user
	/// @dev This function returns a simplified view of the question without options
	/// @param user The address of the user to get the preview for
	/// @return A QuestionPreview struct with question preview details
	function getQuestionPreview(address user) external view returns (QuestionPreview memory);
}
