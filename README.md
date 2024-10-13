# Plasa Protocol

Plasa Protocol is a decentralized platform that implements a unique system of Stamps, Points, and Questions for community engagement and governance. This README provides an overview of the main components and their functionalities.

## Table of Contents

- [Plasa Protocol](#plasa-protocol)
  - [Table of Contents](#table-of-contents)
- [Protocol](#protocol)
  - [Spaces](#spaces)
    - [Space Components](#space-components)
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
  - [Spaces](#spaces-1)
  - [Questions](#questions-1)
- [Write](#write)
  - [FollowerSinceStamp](#followersincestamp)
    - [`mintStamp`](#mintstamp)
  - [Questions](#questions-2)
    - [`vote`](#vote)
    - [`addOption` (OpenQuestion only)](#addoption-openquestion-only)

# Protocol

Plasa Protocol is a decentralized platform that implements a unique system of Stamps, Points, and Questions for community engagement and governance.

## Spaces

Spaces represent communities, organizations, or leaders using Plasa for their community engagement and governance. Each Space manages its own follower stamps, points, and questions.

Key features:

- Deploys and manages Follower Since Stamps and Follower Since Points
- Creates and manages Fixed and Open Questions
- Customizable space information (name, description, image URL)

### Space Components

- **Stamps**: Represents a user's follower status since a specific date on a platform.
- **Points**: Calculates points based on how long a user has been a follower.
- **Questions**: Both Fixed and Open questions for community voting and governance.

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

1. `Space.sol`: Main contract for managing a space, including follower stamps, points, and questions.
2. `Stamp.sol`: Base contract for non-transferable ERC721 tokens (stamps).
3. `AccountOwnershipStamp.sol`: Implementation of the Account Ownership Stamp.
4. `FollowerSinceStamp.sol`: Implementation of the Follower Since Stamp.
5. `Points.sol`: Base contract for non-transferable ERC20-like tokens (points).
6. `FollowerSincePoints.sol`: Implementation of the Follower Since Points system.
7. `MultipleFollowerSincePoints.sol`: Implementation of the Multiple Follower Since Points system.
8. `Question.sol`: Base contract for voting questions.
9. `OpenQuestion.sol`: Implementation of the Open Question type.
10. `FixedQuestion.sol`: Implementation of the Fixed Question type.

These contracts work together to create a comprehensive system for community engagement, reputation tracking, and decentralized decision-making.

For detailed information on each contract and its functions, please refer to the inline documentation in the source code.

# Queries

The Plasa Protocol provides various ways to query data from the smart contracts. Here are some common queries and how to perform them:

## Spaces

Each space contract has a `getSpaceView()` function that returns a `SpaceView` struct. This struct contains all the information about the space.

https://github.com/plasa-labs/plasa-protocol/blob/d55d048575913d7c66fe939f675418b55f126ee1/src/spaces/interfaces/ISpace.sol#L153-L156

https://github.com/plasa-labs/plasa-protocol/blob/d55d048575913d7c66fe939f675418b55f126ee1/src/spaces/interfaces/ISpace.sol#L14-L47

## Questions

Each question contract has a `getQuestionView(address user)` function that returns a `QuestionView` struct. This struct contains all the information about the question and the user's voting status.
It includes an array of `OptionView` structs, which contain information about each option.

https://github.com/plasa-labs/plasa-protocol/blob/19eaa4278396f2bce96472d789483559caf21d59/src/voting/interfaces/IQuestion.sol#L124-L127

https://github.com/plasa-labs/plasa-protocol/blob/19eaa4278396f2bce96472d789483559caf21d59/src/voting/interfaces/IQuestion.sol#L25-L40

https://github.com/plasa-labs/plasa-protocol/blob/19eaa4278396f2bce96472d789483559caf21d59/src/voting/interfaces/IQuestion.sol#L42-L50

https://github.com/plasa-labs/plasa-protocol/blob/19eaa4278396f2bce96472d789483559caf21d59/src/voting/interfaces/IQuestion.sol#L10-L15

More details can be found in the `IQuestion.sol` interface.

# Write

## FollowerSinceStamp

### `mintStamp`

https://github.com/plasa-labs/plasa-protocol/blob/d55d048575913d7c66fe939f675418b55f126ee1/src/stamps/interfaces/IFollowerSinceStamp.sol#L34-L46

## Questions

### `vote`

https://github.com/plasa-labs/plasa-protocol/blob/d55d048575913d7c66fe939f675418b55f126ee1/src/voting/interfaces/IQuestion.sol#L98-L101

### `addOption` (OpenQuestion only)

https://github.com/plasa-labs/plasa-protocol/blob/d55d048575913d7c66fe939f675418b55f126ee1/src/voting/interfaces/IOpenQuestion.sol#L25-L29
