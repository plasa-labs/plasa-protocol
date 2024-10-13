// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "../../stamps/interfaces/IFollowerSinceStamp.sol";
import "../../points/interfaces/IFollowerSincePoints.sol";
import "../../voting/interfaces/IQuestion.sol";

/// @title ISpace
/// @notice Interface for the Space contract, representing a community or organization using Plasa
/// @dev This interface defines the structure for managing follower stamps, points, and questions
interface ISpace {
	// Public variables
	/// @notice Returns the FollowerSinceStamp contract associated with this space
	/// @return The IFollowerSinceStamp interface of the associated stamp contract
	function followerStamp() external view returns (IFollowerSinceStamp);

	/// @notice Returns the FollowerSincePoints contract associated with this space
	/// @return The IFollowerSincePoints interface of the associated points contract
	function followerPoints() external view returns (IFollowerSincePoints);

	/// @notice Returns the name of the space
	/// @return The name of the space
	function spaceName() external view returns (string memory);

	/// @notice Returns the description of the space
	/// @return The description of the space
	function spaceDescription() external view returns (string memory);

	/// @notice Returns the image URL of the space
	/// @return The image URL of the space
	function spaceImageUrl() external view returns (string memory);

	// Events
	/// @notice Emitted when a new FollowerSinceStamp contract is deployed
	/// @param stampAddress The address of the newly deployed FollowerSinceStamp contract
	event FollowerStampDeployed(address stampAddress);

	/// @notice Emitted when a new FollowerSincePoints contract is deployed
	/// @param pointsAddress The address of the newly deployed FollowerSincePoints contract
	event FollowerPointsDeployed(address pointsAddress);

	/// @notice Emitted when a new question contract is deployed
	/// @param questionAddress The address of the newly deployed question contract
	/// @param questionType The type of the question (Fixed or Open)
	event QuestionDeployed(address questionAddress, IQuestion.QuestionType questionType);

	// Public functions
	/// @notice Deploys a new fixed question
	/// @dev Only the owner can call this function
	/// @param questionTitle The title of the question
	/// @param questionDescription The description of the question
	/// @param deadline The deadline for voting
	/// @param initialOptionTitles The titles of the initial options
	/// @param initialOptionDescriptions The descriptions of the initial options
	/// @return The address of the newly deployed question contract
	function deployFixedQuestion(
		string memory questionTitle,
		string memory questionDescription,
		uint256 deadline,
		string[] memory initialOptionTitles,
		string[] memory initialOptionDescriptions
	) external returns (address);

	/// @notice Deploys a new open question
	/// @dev Only the owner can call this function
	/// @param questionTitle The title of the question
	/// @param questionDescription The description of the question
	/// @param deadline The deadline for voting
	/// @param minPointsToAddOption The minimum points required to add an option
	/// @return The address of the newly deployed question contract
	function deployOpenQuestion(
		string memory questionTitle,
		string memory questionDescription,
		uint256 deadline,
		uint256 minPointsToAddOption
	) external returns (address);

	/// @notice Gets all deployed questions
	/// @return An array of IQuestion interfaces representing all deployed questions
	function getQuestions() external view returns (IQuestion[] memory);

	/// @notice Gets the total number of deployed questions
	/// @return The number of deployed questions
	function getQuestionCount() external view returns (uint256);
}
