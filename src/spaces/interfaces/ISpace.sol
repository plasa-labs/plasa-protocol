// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISpaceAccessControl } from "./ISpaceAccessControl.sol";
import { ISpaceView } from "./ISpaceView.sol";
import { IPoints } from "../../points/interfaces/IPoints.sol";
import { IQuestion } from "../../voting/interfaces/IQuestion.sol";

/// @title ISpace - Interface for managing community spaces in Plasa
/// @dev Implement this interface to create a space contract that represents a community or organization
/// @notice This interface defines the structure for managing points, questions, and space information
interface ISpace is ISpaceAccessControl, ISpaceView {
	// Errors
	/// @notice Emitted when a zero address is provided where it's not allowed
	error ZeroAddressNotAllowed();

	/// @notice Emitted when an invalid question type is provided
	error InvalidQuestionType();

	// Events

	/// @notice Emitted when a new question contract is added to the space
	/// @param questionAddress The address of the newly added question contract
	/// @param questionType The type of the question (Fixed or Open)
	event QuestionAdded(address questionAddress, IQuestion.QuestionType questionType);

	/// @notice Emitted when the space info is updated
	/// @param newName The new name of the space
	/// @param newDescription The new description of the space
	/// @param newImageUrl The new image URL of the space
	event SpaceInfoUpdated(string newName, string newDescription, string newImageUrl);

	/// @notice Emitted when the default points contract is updated
	/// @param newDefaultPoints The address of the new default points contract
	event DefaultPointsUpdated(address newDefaultPoints);

	/// @notice Emitted when the minimum points to add an open question option is updated
	/// @param newMinPointsToAddOpenQuestionOption The new minimum points required
	event MinPointsToAddOpenQuestionOptionUpdated(uint256 newMinPointsToAddOpenQuestionOption);

	// External Functions

	/// @notice Adds a question to the space
	/// @dev Requires CreateFixedQuestion or CreateOpenQuestion permission
	/// @param question The address of the question contract
	function addQuestion(address question) external;

	/// @notice Updates the space info
	/// @dev Requires UpdateSpaceInfo permission
	/// @param newName The new name of the space
	/// @param newDescription The new description of the space
	/// @param newImageUrl The new image URL of the space
	function updateSpaceInfo(string memory newName, string memory newDescription, string memory newImageUrl) external;

	/// @notice Updates the default points contract
	/// @dev Requires UpdateSpacePoints permission
	/// @param newDefaultPoints The address of the new default points contract
	function updateDefaultPoints(address newDefaultPoints) external;

	/// @notice Updates the minimum points required to add an open question option
	/// @dev Requires UpdateSpacePoints permission
	/// @param newMinPointsToAddOpenQuestionOption The new minimum points required
	function updateMinPointsToAddOpenQuestionOption(uint256 newMinPointsToAddOpenQuestionOption) external;

	/// @notice Checks if a user can add an open question option
	/// @param user The address of the user
	/// @return True if the user can add an open question option, false otherwise
	function canAddOpenQuestionOption(address user) external view returns (bool);

	// External View Functions

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

	/// @notice Returns the default points contract associated with this space
	/// @return The IPoints interface of the associated default points contract
	function defaultPoints() external view returns (IPoints);
}
