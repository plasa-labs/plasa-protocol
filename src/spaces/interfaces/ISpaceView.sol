// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestionView } from "../../questions/interfaces/IQuestionView.sol";
import { IPointsView } from "../../points/interfaces/IPointsView.sol";

/// @title Interface for viewing Space data and user permissions
/// @dev This interface defines structures and functions for retrieving Space information
interface ISpaceView {
	/// @notice Struct containing basic Space data
	/// @dev Used in SpacePreview and SpaceView
	struct SpaceData {
		address contractAddress;
		string name;
		string description;
		string imageUrl;
		uint256 creationTimestamp;
	}

	/// @notice Struct containing user roles and permissions for a Space
	/// @dev Used in SpacePreview and SpaceView
	struct SpaceUser {
		RolesUser roles;
		PermissionsUser permissions;
	}

	/// @notice Struct defining user roles within a Space
	struct RolesUser {
		bool superAdmin;
		bool admin;
		bool mod;
	}

	/// @notice Struct defining user permissions within a Space
	struct PermissionsUser {
		bool UpdateSpaceInfo;
		bool UpdateSpacePoints;
		bool UpdateQuestionInfo;
		bool UpdateQuestionDeadline;
		bool UpdateQuestionPoints;
		bool CreateFixedQuestion;
		bool CreateOpenQuestion;
		bool VetoFixedQuestion;
		bool VetoOpenQuestion;
		bool VetoOpenQuestionOption;
		bool LiftVetoFixedQuestion;
		bool LiftVetoOpenQuestion;
		bool LiftVetoOpenQuestionOption;
		bool AddOpenQuestionOption;
	}

	/// @notice Struct containing a preview of Space data and user info
	struct SpacePreview {
		SpaceData data;
		SpaceUser user;
	}

	/// @notice Struct containing full Space data, user info, points, and questions
	struct SpaceView {
		SpaceData data;
		SpaceUser user;
		IPointsView.PointsView points;
		IQuestionView.QuestionPreview[] questions;
	}

	/// @notice Retrieves the full view of a Space for a given user
	/// @dev This function returns all Space data, user permissions, points, and questions
	/// @param user The address of the user to get the Space view for
	/// @return A SpaceView struct containing all Space information
	function getSpaceView(address user) external view returns (SpaceView memory);

	/// @notice Retrieves a preview of a Space for a given user
	/// @dev This function returns basic Space data and user permissions
	/// @param user The address of the user to get the Space preview for
	/// @return A SpacePreview struct containing basic Space information
	function getSpacePreview(address user) external view returns (SpacePreview memory);
}
