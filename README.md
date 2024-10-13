# Plasa Protocol

Plasa Protocol is a decentralized platform that implements a unique system of Stamps, Points, and Questions for community engagement and governance. This README provides an overview of the main components and their functionalities.

## Table of Contents

- [Plasa Protocol](#plasa-protocol)
	- [Table of Contents](#table-of-contents)
- [Protocol](#protocol)
	- [Stamps](#stamps)
		- [Account Ownership Stamp](#account-ownership-stamp)
		- [Follower Since Stamp](#follower-since-stamp)
	- [Points](#points)
		- [Follower Since Points](#follower-since-points)
		- [Multiple Follower Since Points](#multiple-follower-since-points)
	- [Questions](#questions)
		- [Fixed Question](#fixed-question)
		- [Open Question](#open-question)
	- [Smart Contracts](#smart-contracts)
- [Queries](#queries)
	- [Questions](#questions-1)
	- [Stamps](#stamps-1)
	- [Points](#points-1)

# Protocol

Plasa Protocol is a decentralized platform that implements a unique system of Stamps, Points, and Questions for community engagement and governance.

## Stamps

Stamps are non-transferable ERC721 tokens that represent specific achievements or statuses within the Plasa ecosystem. There are two types of stamps:

### Account Ownership Stamp

- Represents ownership of an account on a specific platform (e.g., Twitter, GitHub).
- Each stamp is unique to a platform and username combination.
- Minting requires a signature from an authorized signer.

Key features:

- Platform-specific (e.g., "Twitter", "GitHub")
- Username-to-stampId mapping
- Signature-based minting

### Follower Since Stamp

- Represents a user's follower status since a specific date on a platform.
- Each stamp includes a timestamp indicating when the follow relationship began.
- Useful for calculating duration-based points.

Key features:

- Platform and followed account specific
- Stores the follow start timestamp for each stamp
- Signature-based minting

## Points

Points are non-transferable ERC20-like tokens that represent a user's influence or participation within the Plasa ecosystem. There are two types of point systems:

### Follower Since Points

- Calculates points based on how long a user has been a follower.
- Uses the Follower Since Stamp to determine the duration of following.
- Points increase over time as long as the user remains a follower.

Key features:

- Time-based point calculation
- Integrates with Follower Since Stamp
- Non-transferable

### Multiple Follower Since Points

- An extension of Follower Since Points that considers multiple follower relationships.
- Allows for different point multipliers for various platforms or followed accounts.
- Aggregates points from multiple Follower Since Stamps.

Key features:

- Supports multiple follower relationships
- Configurable point multipliers for each relationship
- Aggregates points across platforms or followed accounts

## Questions

Questions are the core of the Plasa governance system, allowing users to create and vote on proposals. There are two types of questions:

### Fixed Question

- Has a predefined set of options that cannot be changed after creation.
- Users can only vote on the existing options.

Key features:

- Immutable options
- Voting based on user's point balance

### Open Question

- Allows users to add new options during the voting period.
- Requires a minimum point balance to add a new option.

Key features:

- Dynamic option addition
- Minimum point requirement for adding options
- Voting based on user's point balance

## Smart Contracts

The Plasa Protocol is implemented using several Solidity smart contracts:

1. `Stamp.sol`: Base contract for non-transferable ERC721 tokens (stamps).
2. `AccountOwnershipStamp.sol`: Implementation of the Account Ownership Stamp.
3. `FollowerSinceStamp.sol`: Implementation of the Follower Since Stamp.
4. `Points.sol`: Base contract for non-transferable ERC20-like tokens (points).
5. `FollowerSincePoints.sol`: Implementation of the Follower Since Points system.
6. `MultipleFollowerSincePoints.sol`: Implementation of the Multiple Follower Since Points system.
7. `Question.sol`: Base contract for voting questions.
8. `OpenQuestion.sol`: Implementation of the Open Question type.
9. `FixedQuestion.sol`: Implementation of the Fixed Question type (not shown in the provided code snippets).

These contracts work together to create a comprehensive system for community engagement, reputation tracking, and decentralized decision-making.

For detailed information on each contract and its functions, please refer to the inline documentation in the source code.

# Queries

The Plasa Protocol provides various ways to query data from the smart contracts. Here are some common queries and how to perform them:

## Questions

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

## Stamps

// Add information about querying stamps here

## Points

// Add information about querying points here
