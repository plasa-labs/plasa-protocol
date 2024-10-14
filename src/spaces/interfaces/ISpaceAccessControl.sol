// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title ISpaceAccessControl - Interface for managing access control in Space contracts
/// @notice This interface defines the structure for managing roles and permissions within a space
/// @dev Implement this interface to create an access control system for space management
interface ISpaceAccessControl {
	/// @notice Error thrown when a user is not allowed to perform an action
	/// @param user The address of the user attempting the action
	/// @param permissionName The name of the permission being checked
	error NotAllowed(address user, PermissionName permissionName);

	/// @notice Enum representing different permission levels
	enum PermissionLevel {
		ONLY_SUPERADMINS,
		SUPERADMINS_AND_ADMINS,
		SUPERADMINS_ADMINS_AND_MODS,
		NOBODY
	}

	/// @notice Enum representing different permission names
	enum PermissionName {
		UpdateSpaceInfo,
		UpdateSpaceDefaultPoints,
		UpdateQuestionInfo,
		UpdateQuestionDeadline,
		UpdateQuestionPoints,
		CreateFixedQuestion,
		CreateOpenQuestion,
		VetoFixedQuestion,
		VetoOpenQuestion,
		VetoOpenQuestionOption,
		LiftVetoFixedQuestion,
		LiftVetoOpenQuestion,
		LiftVetoOpenQuestionOption
	}

	/// @notice The role identifier for super admins
	function SUPER_ADMIN_ROLE() external view returns (bytes32);

	/// @notice The role identifier for admins
	function ADMIN_ROLE() external view returns (bytes32);

	/// @notice The role identifier for moderators
	function MODERATOR_ROLE() external view returns (bytes32);

	/// @notice Get the permission level for a given permission name
	/// @param permissionName The name of the permission to check
	/// @return The permission level for the given permission name
	function permissions(PermissionName permissionName) external view returns (PermissionLevel);

	/// @notice Set the permission level for a given permission name
	/// @dev Only callable by accounts with the SUPER_ADMIN_ROLE
	/// @param permissionName The name of the permission to set
	/// @param level The new permission level
	function setPermission(PermissionName permissionName, PermissionLevel level) external;

	/// @notice Check if a user has permission for a given action
	/// @param permissionName The name of the permission to check
	/// @param user The address of the user to check
	/// @return True if the user has permission, false otherwise
	function checkPermission(PermissionName permissionName, address user) external view returns (bool);
}
