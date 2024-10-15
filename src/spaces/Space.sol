// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISpace } from "./interfaces/ISpace.sol";
import { IFollowerSinceStamp } from "../stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../points/interfaces/IFollowerSincePoints.sol";
import { IQuestion } from "../voting/interfaces/IQuestion.sol";
import { FixedQuestion } from "../voting/FixedQuestion.sol";
import { OpenQuestion } from "../voting/OpenQuestion.sol";
import { FollowerSinceStamp } from "../stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints } from "../points/FollowerSincePoints.sol";
import { SpaceAccessControl } from "./SpaceAccessControl.sol";
import { IQuestionView } from "../voting/interfaces/IQuestionView.sol";

/// @title Space - A contract for managing community spaces in Plasa
/// @notice This contract represents a space, organization, or leader using Plasa for their community
/// @dev Implements ISpace interface and inherits from SpaceAccessControl for access control
contract Space is ISpace, SpaceAccessControl {
	IFollowerSinceStamp public followerStamp;
	IFollowerSincePoints public defaultPoints;
	IQuestion[] private questions;

	string public spaceName;
	string public spaceDescription;
	string public spaceImageUrl;

	/// @notice Initializes the Space contract
	/// @dev Deploys FollowerSinceStamp and FollowerSincePoints contracts
	/// @param initialSuperAdmins An array of addresses to be granted the SUPER_ADMIN_ROLE
	/// @param initialAdmins An array of addresses to be granted the ADMIN_ROLE
	/// @param initialModerators An array of addresses to be granted the MODERATOR_ROLE
	/// @param stampSigner The address authorized to sign mint requests for follower stamps
	/// @param platform The platform name (e.g., "Instagram", "Twitter")
	/// @param followed The account being followed
	/// @param _spaceName The name of the space
	/// @param _spaceDescription The description of the space
	/// @param _spaceImageUrl The URL of the space's image
	/// @param _pointsSymbol The symbol for the space's points
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
		string memory _pointsSymbol
	) SpaceAccessControl(initialSuperAdmins, initialAdmins, initialModerators) {
		spaceName = _spaceName;
		spaceDescription = _spaceDescription;
		spaceImageUrl = _spaceImageUrl;

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

	/// @notice Updates the default points contract
	/// @dev Only callable by a super admin
	/// @param newDefaultPoints The address of the new default points contract
	function updateDefaultPoints(
		address newDefaultPoints
	) external onlyAllowed(PermissionName.UpdateSpaceDefaultPoints) {
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
	) external onlyAllowed(PermissionName.CreateFixedQuestion) returns (address) {
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
	) external onlyAllowed(PermissionName.CreateOpenQuestion) returns (address) {
		OpenQuestion newQuestion = new OpenQuestion(address(this), questionTitle, questionDescription, deadline);
		questions.push(IQuestion(address(newQuestion)));
		emit QuestionDeployed(address(newQuestion), IQuestionView.QuestionType.Open);
		return address(newQuestion);
	}

	/// @inheritdoc ISpace
	function getQuestions() external view returns (IQuestion[] memory) {
		return questions;
	}

	/// @inheritdoc ISpace
	function getQuestionCount() external view returns (uint256) {
		return questions.length;
	}

	/// @inheritdoc ISpace
	function updateSpaceName(string memory _spaceName) external onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceName = _spaceName;
		emit SpaceNameUpdated(_spaceName);
	}

	/// @inheritdoc ISpace
	function updateSpaceDescription(
		string memory _spaceDescription
	) external onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceDescription = _spaceDescription;
		emit SpaceDescriptionUpdated(_spaceDescription);
	}

	/// @inheritdoc ISpace
	function updateSpaceImageUrl(string memory _spaceImageUrl) external onlyAllowed(PermissionName.UpdateSpaceInfo) {
		spaceImageUrl = _spaceImageUrl;
		emit SpaceImageUrlUpdated(_spaceImageUrl);
	}

	/// @inheritdoc ISpace
	function getSpaceView(address user) external view override returns (SpaceView memory) {
		QuestionPreview[] memory questionPreviews = new QuestionPreview[](questions.length);
		for (uint i = 0; i < questions.length; i++) {
			IQuestion question = questions[i];
			questionPreviews[i] = QuestionPreview({
				addr: address(question),
				title: question.title(),
				description: question.description(),
				deadline: question.deadline(),
				isActive: question.isActive(),
				userHasVoted: question.hasVoted(user)
			});
		}

		return
			SpaceView({
				name: spaceName,
				description: spaceDescription,
				imageUrl: spaceImageUrl,
				stampView: followerStamp.getStampView(user),
				points: PointsView({ addr: address(defaultPoints), userCurrentBalance: defaultPoints.balanceOf(user) }),
				questions: questionPreviews
			});
	}
}
