// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/ISpace.sol";
import "../stamps/interfaces/IFollowerSinceStamp.sol";
import "../points/interfaces/IFollowerSincePoints.sol";
import "../voting/interfaces/IQuestion.sol";
import "../voting/FixedQuestion.sol";
import "../voting/OpenQuestion.sol";
import "../stamps/FollowerSinceStamp.sol";
import "../points/FollowerSincePoints.sol";

/// @title Space
/// @notice Represents a space, organization, or leader using Plasa for their community
/// @dev This contract manages follower stamps, points, and questions for a community
contract Space is ISpace, Ownable {
	IFollowerSinceStamp public followerStamp;
	IFollowerSincePoints public followerPoints;
	IQuestion[] private questions;

	/// @notice Initializes the PoCSpace contract
	/// @param initialOwner The address that will own this space
	/// @param stampSigner The address authorized to sign mint requests for follower stamps
	/// @param platform The platform name (e.g., "Instagram", "Twitter")
	/// @param followed The account being followed
	/// @param spaceName The name of the space
	constructor(
		address initialOwner,
		address stampSigner,
		string memory platform,
		string memory followed,
		string memory spaceName
	) Ownable(initialOwner) {
		// Deploy FollowerSinceStamp contract
		followerStamp = IFollowerSinceStamp(
			address(new FollowerSinceStamp(stampSigner, platform, followed))
		);
		emit FollowerStampDeployed(address(followerStamp));

		// Deploy FollowerSincePoints contract
		string memory pointsName = string(abi.encodePacked(spaceName, " Points"));
		followerPoints = IFollowerSincePoints(
			address(new FollowerSincePoints(address(followerStamp), pointsName, "FP"))
		);
		emit FollowerPointsDeployed(address(followerPoints));
	}

	/// @inheritdoc ISpace
	function deployFixedQuestion(
		string memory title,
		string memory description,
		uint256 deadline,
		string[] memory initialOptionTitles,
		string[] memory initialOptionDescriptions
	) external onlyOwner returns (address) {
		FixedQuestion newQuestion = new FixedQuestion(
			owner(),
			title,
			description,
			deadline,
			address(followerPoints),
			initialOptionTitles,
			initialOptionDescriptions
		);
		questions.push(IQuestion(address(newQuestion)));
		emit QuestionDeployed(address(newQuestion), IQuestion.QuestionType.Fixed);
		return address(newQuestion);
	}

	/// @inheritdoc ISpace
	function deployOpenQuestion(
		string memory title,
		string memory description,
		uint256 deadline,
		uint256 minPointsToAddOption
	) external onlyOwner returns (address) {
		OpenQuestion newQuestion = new OpenQuestion(
			owner(),
			title,
			description,
			deadline,
			address(followerPoints),
			minPointsToAddOption
		);
		questions.push(IQuestion(address(newQuestion)));
		emit QuestionDeployed(address(newQuestion), IQuestion.QuestionType.Open);
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
}
