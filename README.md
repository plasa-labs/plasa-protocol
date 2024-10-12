# Plasa Contracts

## Querying Question

Each question contract has a `getQuestionView(address user)` function that returns a `QuestionView` struct. This struct contains all the information about the question and the user's voting status.
It includes an array of `OptionView` structs, which contain information about each option.

```solidity
/// @dev Represents a comprehensive view of a question with all its details
struct QuestionView {
	QuestionType questionType; // The type of question (Fixed or Open), set in the constructor of OpenQuestion or FixedQuestion
	string title; // The title of the question, can be updated with Question.updateTitle()
	string description; // The description of the question, can be updated with Question.updateDescription()
	uint256 deadline; // The voting deadline, can be updated with Question.updateDeadline()
	uint256 totalVoteCount; // The total number of votes across all options, calculated in Question.getQuestionView()
	OptionView[] options; // Array of all voting options with their details, populated in Question.getQuestionView()
	Status status; // The current status of the question (Active or Ended), determined by Question.getStatus()
	address owner; // The owner of the question contract, set in the constructor and managed by Ownable
	uint256 started; // The timestamp when the question was deployed, set in the Question constructor
	uint256 userOptionVoted; // The option ID the user voted for (0 if not voted), set in Question.getQuestionView()
	uint256 userPointsCurrent; // The user's current point balance, retrieved from the Points contract
	uint256 userPointsDeadline; // The user's point balance at the voting deadline, retrieved from the Points contract
	bool userCanAddOption; // Whether the user can add a new option (always false for FixedQuestion, conditional for OpenQuestion)
}
```

```solidity
/// @dev Represents a view of a voting option with additional user-specific data
struct OptionView {
	string title; // The title of the option, set in Question._addOption()
	string description; // The description of the option, set in Question._addOption()
	address proposer; // The address that proposed this option, set to msg.sender in Question._addOption()
	uint256 voteCount; // The total number of votes for this option, incremented in Question.vote()
	uint256 pointsAccrued; // Total points accrued for this option, updated in Question.vote()
	bool userVoted; // Whether the specific user voted for this option, checked in Question.getQuestionView()
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

More details about the `OptionView` struct can be found in the `IQuestion.sol` interface.
