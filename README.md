# Plasa Contracts

## Querying Question

Each question contract has a `getQuestionView(address user)` function that returns a `QuestionView` struct. This struct contains all the information about the question and the user's voting status.
It includes an array of `OptionView` structs, which contain information about each option.

```solidity
/// @notice Get a comprehensive view of the question for a specific user
/// @param user The address of the user to get the view for
/// @return A QuestionView struct with all question details
function getQuestionView(address user) external view returns (QuestionView memory);
```

```solidity
/// @dev Represents a comprehensive view of a question with all its details
struct QuestionView {
	QuestionType questionType; // The type of question (Fixed or Open)
	string title; // The title of the question
	string description; // The description of the question
	uint256 deadline; // The voting deadline
	uint256 totalVoteCount; // The total number of votes across all options
	OptionView[] options; // Array of all voting options with their details
	Status status; // The current status of the question (Active or Ended)
	address owner; // The owner of the question contract
	uint256 started; // The timestamp when the question was deployed
	uint256 userOptionVoted; // The option ID the user voted for (0 if not voted)
	uint256 userPointsCurrent; // The user's current point balance
	uint256 userPointsDeadline; // The user's point balance at the voting deadline
	bool userCanAddOption; // Whether the user can add a new option (always false for FixedQuestion, conditional for OpenQuestion)
}
```

```solidity
/// @dev Represents a view of a voting option with additional user-specific data
struct OptionView {
	string title; // The title of the option
	string description; // The description of the option
	address proposer; // The address that proposed this option
	uint256 voteCount; // The total number of votes for this option
	uint256 pointsAccrued; // Total points accrued for this option
	bool userVoted; // Whether the specific user voted for this option
}
```

```solidity
/// @dev Represents the current status of a question
enum Status {
	Null,
	Active,
	Ended
}

/// @dev Defines the type of question
enum QuestionType {
	Null,
	Fixed,
	Open
}
```

More details can be found in the `IQuestion.sol` interface.
