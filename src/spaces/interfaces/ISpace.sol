// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestion } from "../../voting/interfaces/IQuestion.sol";
import { IFollowerSinceStamp } from "../../stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../points/interfaces/IFollowerSincePoints.sol";
import { ISpaceAccessControl } from "./ISpaceAccessControl.sol";
import { IStampView } from "../../stamps/interfaces/IStampView.sol";
import { IQuestionView } from "../../voting/interfaces/IQuestionView.sol";
import { ISpaceView } from "./ISpaceView.sol";

/// @title ISpace - Interface for managing community spaces in Plasa
/// @notice This interface defines the structure for managing follower stamps, points, and questions within a space
/// @dev Implement this interface to create a space contract that represents a community or organization using Plasa
/// @custom:security-contact security@plasa.io
interface ISpace is ISpaceAccessControl, ISpaceView {
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

	/// @notice Emitted when the default points contract is updated
	/// @param newDefaultPoints The address of the new default points contract
	event DefaultPointsUpdated(address newDefaultPoints);

	/// @notice Emitted when the minimum points to add an open question option is updated
	/// @param newMinPointsToAddOpenQuestionOption The new minimum points to add an open question option
	event MinPointsToAddOpenQuestionOptionUpdated(uint256 newMinPointsToAddOpenQuestionOption);

	// External Functions

	/// @notice Deploys a new fixed question
	/// @dev Only the owner can call this function. Emits a QuestionDeployed event.
	/// @param questionTitle The title of the question
	/// @param questionDescription The description of the question
	/// @param deadline The deadline for voting (in Unix timestamp)
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
	/// @dev Only the owner can call this function. Emits a QuestionDeployed event.
	/// @param questionTitle The title of the question
	/// @param questionDescription The description of the question
	/// @param deadline The deadline for voting (in Unix timestamp)
	/// @return The address of the newly deployed question contract
	function deployOpenQuestion(
		string memory questionTitle,
		string memory questionDescription,
		uint256 deadline
	) external returns (address);

	/// @notice Updates the name of the space
	/// @dev Only the owner can call this function. Emits a SpaceNameUpdated event.
	/// @param _spaceName The new name of the space
	function updateSpaceName(string memory _spaceName) external;

	/// @notice Updates the description of the space
	/// @dev Only the owner can call this function. Emits a SpaceDescriptionUpdated event.
	/// @param _spaceDescription The new description of the space
	function updateSpaceDescription(string memory _spaceDescription) external;

	/// @notice Updates the image URL of the space
	/// @dev Only the owner can call this function. Emits a SpaceImageUrlUpdated event.
	/// @param _spaceImageUrl The new image URL of the space
	function updateSpaceImageUrl(string memory _spaceImageUrl) external;

	/// @notice Updates the default points contract
	/// @dev Only callable by a super admin. Emits a DefaultPointsUpdated event.
	/// @param newDefaultPoints The address of the new default points contract
	function updateDefaultPoints(address newDefaultPoints) external;

	/// @notice Updates the minimum points to add an open question option
	/// @dev Only callable by a super admin. Emits a MinPointsToAddOpenQuestionOptionUpdated event.
	/// @param newMinPointsToAddOpenQuestionOption The new minimum points to add an open question option
	function updateMinPointsToAddOpenQuestionOption(uint256 newMinPointsToAddOpenQuestionOption) external;

	/// @notice Checks if a user can add an open question option
	/// @param user The address of the user
	/// @param deadline The deadline of the question
	/// @return True if the user can add an open question option, false otherwise
	function canAddOpenQuestionOption(address user, uint256 deadline) external view returns (bool);

	// External View Functions

	/// @notice Returns the FollowerSinceStamp contract associated with this space
	/// @return The IFollowerSinceStamp interface of the associated stamp contract
	function followerStamp() external view returns (IFollowerSinceStamp);

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

	/// @notice Returns the default FollowerSincePoints contract associated with this space
	/// @return The IFollowerSincePoints interface of the associated default points contract
	function defaultPoints() external view returns (IFollowerSincePoints);
}
