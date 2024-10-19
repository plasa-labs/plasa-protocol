// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IAccessControl } from "@openzeppelin/contracts/access/IAccessControl.sol";

/// @title Space Access Control Interface
/// @dev Defines the structure for managing roles and permissions within a space
interface ISpaceAccessControl is IAccessControl {
	/// @dev Error thrown when a user is not allowed to perform an action
	/// @param user The address of the user attempting the action
	/// @param permissionName The name of the permission being checked
	error NotAllowed(address user, PermissionName permissionName);

	/// @dev Enum representing different permission levels
	enum PermissionLevel {
		ONLY_SUPERADMINS,
		SUPERADMINS_AND_ADMINS,
		SUPERADMINS_ADMINS_AND_MODS,
		NOBODY
	}

	/// @dev Enum representing different permission names
	enum PermissionName {
		UpdateSpaceInfo,
		UpdateSpacePoints,
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

	/// @dev Returns the role identifier for super admins
	/// @return bytes32 The keccak256 hash of "SUPER_ADMIN_ROLE"
	function SUPER_ADMIN_ROLE() external view returns (bytes32);

	/// @dev Returns the role identifier for admins
	/// @return bytes32 The keccak256 hash of "ADMIN_ROLE"
	function ADMIN_ROLE() external view returns (bytes32);

	/// @dev Returns the role identifier for moderators
	/// @return bytes32 The keccak256 hash of "MODERATOR_ROLE"
	function MODERATOR_ROLE() external view returns (bytes32);

	/// @dev Get the permission level for a given permission name
	/// @param permissionName The name of the permission to check
	/// @return PermissionLevel The permission level for the given permission name
	function permissions(PermissionName permissionName) external view returns (PermissionLevel);

	/// @dev Set the permission level for a given permission name
	/// @notice Only callable by accounts with the SUPER_ADMIN_ROLE
	/// @param permissionName The name of the permission to set
	/// @param level The new permission level
	function updatePermission(PermissionName permissionName, PermissionLevel level) external;

	/// @dev Check if a user has permission for a given action
	/// @param permissionName The name of the permission to check
	/// @param user The address of the user to check
	/// @return bool True if the user has permission, false otherwise
	function hasPermission(PermissionName permissionName, address user) external view returns (bool);
}
