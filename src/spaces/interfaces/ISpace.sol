// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestion } from "../../voting/interfaces/IQuestion.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../points/interfaces/IFollowerSincePoints.sol";

/// @title ISpace - Interface for managing community spaces in Plasa
/// @notice This interface defines the structure for managing follower stamps, points, and questions within a space
/// @dev Implement this interface to create a space contract that represents a community or organization using Plasa
interface ISpace {
	// Structs

	/// @notice Represents a comprehensive view of a space
	struct SpaceView {
		string name;
		string description;
		string imageUrl;
		address owner;
		StampView stamp;
		PointsView points;
		QuestionPreview[] questions;
	}

	/// @notice Represents a view of the follower stamp associated with the space
	struct StampView {
		address addr;
		string platform;
		string followedAccount;
		bool userHasStamp;
	}

	/// @notice Represents a view of the points system associated with the space
	struct PointsView {
		address addr;
		uint256 userCurrentBalance;
	}

	/// @notice Represents a preview of a question in the space
	struct QuestionPreview {
		address addr;
		string title;
		string description;
		uint256 deadline;
		bool isActive;
		bool userHasVoted;
	}

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

	/// @notice Emitted when the space name is updated
	/// @param newName The new name of the space
	event SpaceNameUpdated(string newName);

	/// @notice Emitted when the space description is updated
	/// @param newDescription The new description of the space
	event SpaceDescriptionUpdated(string newDescription);

	/// @notice Emitted when the space image URL is updated
	/// @param newImageUrl The new image URL of the space
	event SpaceImageUrlUpdated(string newImageUrl);

	// External Functions

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

	/// @notice Updates the name of the space
	/// @dev Only the owner can call this function
	/// @param _spaceName The new name of the space
	function updateSpaceName(string memory _spaceName) external;

	/// @notice Updates the description of the space
	/// @dev Only the owner can call this function
	/// @param _spaceDescription The new description of the space
	function updateSpaceDescription(string memory _spaceDescription) external;

	/// @notice Updates the image URL of the space
	/// @dev Only the owner can call this function
	/// @param _spaceImageUrl The new image URL of the space
	function updateSpaceImageUrl(string memory _spaceImageUrl) external;

	// External View Functions

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

	/// @notice Gets all deployed questions
	/// @return An array of IQuestion interfaces representing all deployed questions
	function getQuestions() external view returns (IQuestion[] memory);

	/// @notice Gets the total number of deployed questions
	/// @return The number of deployed questions
	function getQuestionCount() external view returns (uint256);

	/// @notice Gets a comprehensive view of the space for a given user
	/// @param user The address of the user to get the view for
	/// @return A SpaceView struct containing all relevant information about the space
	function getSpaceView(address user) external view returns (SpaceView memory);
}
