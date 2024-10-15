// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISpace, ISpaceView } from "./interfaces/ISpace.sol";
import { IQuestion, IQuestionView } from "../voting/interfaces/IQuestion.sol";
import { FollowerSinceStamp, IFollowerSinceStamp } from "../stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints, IFollowerSincePoints } from "../points/FollowerSincePoints.sol";
import { SpaceAccessControl } from "./SpaceAccessControl.sol";
import { FixedQuestion } from "../voting/FixedQuestion.sol";
import { OpenQuestion } from "../voting/OpenQuestion.sol";

/// @title Space - A contract for managing community spaces in Plasa
/// @notice This contract represents a space, organization, or leader using Plasa for their community
/// @dev Implements ISpace interface and inherits from SpaceAccessControl for access control
/// @custom:security-contact security@plasa.io
contract Space is ISpace, SpaceAccessControl {
	// State variables
	IFollowerSinceStamp public override followerStamp;
	IFollowerSincePoints public override defaultPoints;
	IQuestion[] private questions;

	string public override spaceName;
	string public override spaceDescription;
	string public override spaceImageUrl;

	uint256 public minPointsToAddOpenQuestionOption;

	/// @notice Constructor for Space contract
	/// @param initialSuperAdmins Array of initial super admins
	/// @param initialAdmins Array of initial admins
	/// @param initialModerators Array of initial moderators
	/// @param stampSigner Signer address for the follower stamp
	/// @param platform Platform name
	/// @param followed Platform username
	/// @param _spaceName Name of the space
	constructor(
		address[] memory initialSuperAdmins,
		address[] memory initialAdmins,
		address[] memory initialModerators,
		address stampSigner,
		string memory platform,
		string memory followed,
		string memory _spaceName,
		string memory _spaceDescription,
		string memory _spaceImageUrl,
		string memory _pointsSymbol,
		uint256 _minPointsToAddOpenQuestionOption
	) SpaceAccessControl(initialSuperAdmins, initialAdmins, initialModerators) {
		spaceName = _spaceName;
		spaceDescription = _spaceDescription;
		spaceImageUrl = _spaceImageUrl;
		minPointsToAddOpenQuestionOption = _minPointsToAddOpenQuestionOption;

		// Deploy FollowerSinceStamp contract
		followerStamp = IFollowerSinceStamp(
			address(new FollowerSinceStamp(address(this), stampSigner, platform, followed))
		);
		emit FollowerStampDeployed(address(followerStamp));

		// Deploy FollowerSincePoints contract
		string memory pointsName = string(abi.encodePacked(_spaceName, " Points"));
		defaultPoints = IFollowerSincePoints(
			address(new FollowerSincePoints(address(followerStamp), pointsName, _pointsSymbol))
		);
		emit FollowerPointsDeployed(address(defaultPoints));
	}

	/// @inheritdoc ISpace
	function updateDefaultPoints(
		address newDefaultPoints
	) external override onlyAllowed(PermissionName.UpdateSpacePoints) {
		require(newDefaultPoints != address(0), "New default points address cannot be zero");
		defaultPoints = IFollowerSincePoints(newDefaultPoints);
		emit DefaultPointsUpdated(newDefaultPoints);
	}

	/// @inheritdoc ISpace
	function deployFixedQuestion(
		string memory questionTitle,
		string memory questionDescription,
		uint256 deadline,
		string[] memory initialOptionTitles,
		string[] memory initialOptionDescriptions
	) external override onlyAllowed(PermissionName.CreateFixedQuestion) returns (address) {
		FixedQuestion newQuestion = new FixedQuestion(
			address(this),
			questionTitle,
			questionDescription,
			deadline,
			initialOptionTitles,
			initialOptionDescriptions
		);
		questions.push(IQuestion(address(newQuestion)));
		emit QuestionDeployed(address(newQuestion), IQuestionView.QuestionType.Fixed);
		return address(newQuestion);
	}

	/// @inheritdoc ISpace
	function deployOpenQuestion(
		string memory questionTitle,
		string memory questionDescription,
		uint256 deadline
	) external override onlyAllowed(PermissionName.CreateOpenQuestion) returns (address) {
		OpenQuestion newQuestion = new OpenQuestion(address(this), questionTitle, questionDescription, deadline);
		questions.push(IQuestion(address(newQuestion)));
		emit QuestionDeployed(address(newQuestion), IQuestionView.QuestionType.Open);
		return address(newQuestion);
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
	function updateSpaceName(string memory _spaceName) external override onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceName = _spaceName;
		emit SpaceNameUpdated(_spaceName);
	}

	/// @inheritdoc ISpace
	function updateSpaceDescription(
		string memory _spaceDescription
	) external override onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceDescription = _spaceDescription;
		emit SpaceDescriptionUpdated(_spaceDescription);
	}

	/// @inheritdoc ISpace
	function updateSpaceImageUrl(
		string memory _spaceImageUrl
	) external override onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceImageUrl = _spaceImageUrl;
		emit SpaceImageUrlUpdated(_spaceImageUrl);
	}

	/// @inheritdoc ISpace
	function canAddOpenQuestionOption(address user, uint256 deadline) public view override returns (bool) {
		return defaultPoints.balanceAtTimestamp(user, deadline) >= minPointsToAddOpenQuestionOption;
	}

	/// @inheritdoc ISpace
	function updateMinPointsToAddOpenQuestionOption(
		uint256 _minPointsToAddOpenQuestionOption
	) external override onlyAllowed(PermissionName.UpdateSpacePoints) {
		minPointsToAddOpenQuestionOption = _minPointsToAddOpenQuestionOption;
		emit MinPointsToAddOpenQuestionOptionUpdated(_minPointsToAddOpenQuestionOption);
	}

	/// @dev Internal function to create SpaceData struct
	/// @return SpaceData struct containing space information
	function _spaceData() private view returns (SpaceData memory) {
		return
			SpaceData({
				contractAddress: address(this),
				name: spaceName,
				description: spaceDescription,
				imageUrl: spaceImageUrl,
				creationTimestamp: block.timestamp
			});
	}

	/// @dev Internal function to create SpaceUser struct for a given user
	/// @param user Address of the user
	/// @return SpaceUser struct containing user roles and permissions
	function _spaceUser(address user) private view returns (SpaceUser memory) {
		return
			SpaceUser({
				roles: RolesUser({
					superAdmin: hasRole(SUPER_ADMIN_ROLE, user),
					admin: hasRole(ADMIN_ROLE, user),
					mod: hasRole(MODERATOR_ROLE, user)
				}),
				permissions: PermissionsUser({
					UpdateSpaceInfo: checkPermission(PermissionName.UpdateSpaceInfo, user),
					UpdateSpacePoints: checkPermission(PermissionName.UpdateSpacePoints, user),
					UpdateQuestionInfo: checkPermission(PermissionName.UpdateQuestionInfo, user),
					UpdateQuestionDeadline: checkPermission(PermissionName.UpdateQuestionDeadline, user),
					UpdateQuestionPoints: checkPermission(PermissionName.UpdateQuestionPoints, user),
					CreateFixedQuestion: checkPermission(PermissionName.CreateFixedQuestion, user),
					CreateOpenQuestion: checkPermission(PermissionName.CreateOpenQuestion, user),
					VetoFixedQuestion: checkPermission(PermissionName.VetoFixedQuestion, user),
					VetoOpenQuestion: checkPermission(PermissionName.VetoOpenQuestion, user),
					VetoOpenQuestionOption: checkPermission(PermissionName.VetoOpenQuestionOption, user),
					LiftVetoFixedQuestion: checkPermission(PermissionName.LiftVetoFixedQuestion, user),
					LiftVetoOpenQuestion: checkPermission(PermissionName.LiftVetoOpenQuestion, user),
					LiftVetoOpenQuestionOption: checkPermission(PermissionName.LiftVetoOpenQuestionOption, user),
					AddOpenQuestionOption: canAddOpenQuestionOption(user, block.timestamp)
				})
			});
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
		return SpacePreview({ data: _spaceData(), user: _spaceUser(user) });
	}

	/// @inheritdoc ISpaceView
	function getSpaceView(address user) external view override returns (SpaceView memory) {
		return
			SpaceView({
				data: _spaceData(),
				user: _spaceUser(user),
				points: defaultPoints.getPointsView(user),
				questions: _questionsPreview(user)
			});
	}
}
