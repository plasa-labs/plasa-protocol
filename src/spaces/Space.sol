// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISpace } from "./interfaces/ISpace.sol";
import { ISpaceView } from "./interfaces/ISpaceView.sol";
import { IQuestion, IQuestionView } from "../voting/interfaces/IQuestion.sol";
import { SpaceAccessControl } from "./SpaceAccessControl.sol";
import { IPoints } from "../points/interfaces/IPoints.sol";

/// @title Space - A contract for managing community spaces in Plasa
/// @dev Implements ISpace interface and inherits from SpaceAccessControl for access control
/// @custom:security-contact security@plasa.io
contract Space is ISpace, SpaceAccessControl {
	IPoints public override defaultPoints;
	IQuestion[] private questions;

	string public override spaceName;
	string public override spaceDescription;
	string public override spaceImageUrl;

	uint256 public minPointsToAddOpenQuestionOption;

	/// @notice Constructor for Space contract
	/// @param initialSuperAdmins Array of initial super admins
	/// @param _spaceName Name of the space
	/// @param _spaceDescription Description of the space
	/// @param _spaceImageUrl Image URL of the space
	/// @param _defaultPoints Address of the default points contract
	/// @param _minPointsToAddOpenQuestionOption Minimum points required to add an open question option
	constructor(
		address[] memory initialSuperAdmins,
		string memory _spaceName,
		string memory _spaceDescription,
		string memory _spaceImageUrl,
		address _defaultPoints,
		uint256 _minPointsToAddOpenQuestionOption
	) SpaceAccessControl(initialSuperAdmins) {
		spaceName = _spaceName;
		spaceDescription = _spaceDescription;
		spaceImageUrl = _spaceImageUrl;
		defaultPoints = IPoints(_defaultPoints);
		minPointsToAddOpenQuestionOption = _minPointsToAddOpenQuestionOption;
	}

	/// @inheritdoc ISpace
	function updateDefaultPoints(
		address newDefaultPoints
	) external override onlyAllowed(PermissionName.UpdateSpacePoints) {
		if (newDefaultPoints == address(0)) revert ZeroAddressNotAllowed();
		defaultPoints = IPoints(newDefaultPoints);
		emit DefaultPointsUpdated(newDefaultPoints);
	}

	/// @inheritdoc ISpace
	function addQuestion(address question) external override {
		IQuestionView.QuestionType questionType = IQuestion(question).questionType();

		if (questionType == IQuestionView.QuestionType.Open) {
			if (!hasPermission(PermissionName.CreateOpenQuestion, msg.sender)) {
				revert NotAllowed(msg.sender, PermissionName.CreateOpenQuestion);
			}
		} else if (questionType == IQuestionView.QuestionType.Fixed) {
			if (!hasPermission(PermissionName.CreateFixedQuestion, msg.sender)) {
				revert NotAllowed(msg.sender, PermissionName.CreateFixedQuestion);
			}
		} else {
			revert InvalidQuestionType();
		}

		questions.push(IQuestion(question));
		emit QuestionAdded(question, questionType);
	}

	/// @inheritdoc ISpace
	function getQuestions() external view override returns (IQuestion[] memory) {
		return questions;
	}

	/// @inheritdoc ISpace
	function getQuestionCount() external view override returns (uint256) {
		return questions.length;
	}

	/// @inheritdoc ISpace
	function updateSpaceInfo(
		string memory _spaceName,
		string memory _spaceDescription,
		string memory _spaceImageUrl
	) external override onlyAllowed(PermissionName.UpdateSpaceInfo) {
		if (bytes(_spaceName).length > 0) {
			spaceName = _spaceName;
		}
		if (bytes(_spaceDescription).length > 0) {
			spaceDescription = _spaceDescription;
		}
		if (bytes(_spaceImageUrl).length > 0) {
			spaceImageUrl = _spaceImageUrl;
		}
		emit SpaceInfoUpdated(spaceName, spaceDescription, spaceImageUrl);
	}

	/// @inheritdoc ISpace
	function canAddOpenQuestionOption(address user) public view override returns (bool) {
		return defaultPoints.balanceOf(user) >= minPointsToAddOpenQuestionOption;
	}

	/// @inheritdoc ISpace
	function updateMinPointsToAddOpenQuestionOption(
		uint256 _minPointsToAddOpenQuestionOption
	) external override onlyAllowed(PermissionName.UpdateSpacePoints) {
		minPointsToAddOpenQuestionOption = _minPointsToAddOpenQuestionOption;
		emit MinPointsToAddOpenQuestionOptionUpdated(_minPointsToAddOpenQuestionOption);
	}

	/// @dev Internal function to create an array of QuestionPreview structs
	/// @param user Address of the user
	/// @return Array of QuestionPreview structs
	function _questionsPreview(address user) private view returns (IQuestionView.QuestionPreview[] memory) {
		IQuestionView.QuestionPreview[] memory questionsPreview = new IQuestionView.QuestionPreview[](questions.length);
		for (uint256 i = 0; i < questions.length; i++) {
			questionsPreview[i] = questions[i].getQuestionPreview(user);
		}
		return questionsPreview;
	}

	/// @inheritdoc ISpaceView
	function getSpacePreview(address user) external view override returns (SpacePreview memory) {
		return _spacePreviewData(user);
	}

	/// @inheritdoc ISpaceView
	function getSpaceView(address user) external view override returns (SpaceView memory) {
		SpacePreview memory preview = _spacePreviewData(user);
		return
			SpaceView({
				data: preview.data,
				user: preview.user,
				points: defaultPoints.getPointsView(user),
				questions: _questionsPreview(user)
			});
	}

	/// @dev Internal function to create SpacePreview struct
	/// @param user Address of the user
	/// @return SpacePreview struct containing space information and user roles and permissions
	function _spacePreviewData(address user) private view returns (SpacePreview memory) {
		return
			SpacePreview({
				data: SpaceData({
					contractAddress: address(this),
					name: spaceName,
					description: spaceDescription,
					imageUrl: spaceImageUrl,
					creationTimestamp: block.timestamp
				}),
				user: SpaceUser({
					roles: RolesUser({
						superAdmin: hasRole(SUPER_ADMIN_ROLE, user),
						admin: hasRole(ADMIN_ROLE, user),
						mod: hasRole(MODERATOR_ROLE, user)
					}),
					permissions: PermissionsUser({
						UpdateSpaceInfo: hasPermission(PermissionName.UpdateSpaceInfo, user),
						UpdateSpacePoints: hasPermission(PermissionName.UpdateSpacePoints, user),
						UpdateQuestionInfo: hasPermission(PermissionName.UpdateQuestionInfo, user),
						UpdateQuestionDeadline: hasPermission(PermissionName.UpdateQuestionDeadline, user),
						UpdateQuestionPoints: hasPermission(PermissionName.UpdateQuestionPoints, user),
						CreateFixedQuestion: hasPermission(PermissionName.CreateFixedQuestion, user),
						CreateOpenQuestion: hasPermission(PermissionName.CreateOpenQuestion, user),
						VetoFixedQuestion: hasPermission(PermissionName.VetoFixedQuestion, user),
						VetoOpenQuestion: hasPermission(PermissionName.VetoOpenQuestion, user),
						VetoOpenQuestionOption: hasPermission(PermissionName.VetoOpenQuestionOption, user),
						LiftVetoFixedQuestion: hasPermission(PermissionName.LiftVetoFixedQuestion, user),
						LiftVetoOpenQuestion: hasPermission(PermissionName.LiftVetoOpenQuestion, user),
						LiftVetoOpenQuestionOption: hasPermission(PermissionName.LiftVetoOpenQuestionOption, user),
						AddOpenQuestionOption: canAddOpenQuestionOption(user)
					})
				})
			});
	}
}
