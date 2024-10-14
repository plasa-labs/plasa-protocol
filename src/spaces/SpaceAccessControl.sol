// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";

/// @title SpaceAccessControl - A contract for managing access control in Space contracts
/// @notice This contract defines roles and permissions for Space management
contract SpaceAccessControl is AccessControl {
	error NotAllowed(address user, PermissionName permissionName);

	bytes32 public constant SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
	bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
	bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

	enum PermissionLevel {
		ONLY_SUPERADMINS,
		SUPERADMINS_AND_ADMINS,
		SUPERADMINS_ADMINS_AND_MODS,
		NOBODY
	}

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

	mapping(PermissionName => PermissionLevel) public permissions;

	constructor(address initialSuperAdmin) {
		_grantRole(SUPER_ADMIN_ROLE, initialSuperAdmin);
		_setRoleAdmin(ADMIN_ROLE, SUPER_ADMIN_ROLE);
		_setRoleAdmin(MODERATOR_ROLE, SUPER_ADMIN_ROLE);
		_setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);
	}

	function setPermission(PermissionName permissionName, PermissionLevel level) external onlyRole(SUPER_ADMIN_ROLE) {
		permissions[permissionName] = level;
	}

	function checkPermission(PermissionName permissionName, address user) internal view returns (bool) {
		PermissionLevel level = permissions[permissionName];

		if (hasRole(SUPER_ADMIN_ROLE, user)) {
			return true;
		}

		if (level == PermissionLevel.ONLY_SUPERADMINS) {
			return false;
		}

		if (level == PermissionLevel.NOBODY) {
			return false;
		}

		if (hasRole(ADMIN_ROLE, user)) {
			return true;
		}

		return level == PermissionLevel.SUPERADMINS_ADMINS_AND_MODS && hasRole(MODERATOR_ROLE, user);
	}

	modifier onlyAllowed(PermissionName permissionName) {
		if (!checkPermission(permissionName, msg.sender)) {
			revert NotAllowed(msg.sender, permissionName);
		}
		_;
	}
}
