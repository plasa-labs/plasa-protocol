// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./interfaces/ISpaceAccessControl.sol";

/// @title SpaceAccessControl - A contract for managing access control in Space contracts
/// @notice This contract defines roles and permissions for Space management
/// @dev Inherits from OpenZeppelin's AccessControl and implements ISpaceAccessControl
contract SpaceAccessControl is AccessControl, ISpaceAccessControl {
	bytes32 public constant override SUPER_ADMIN_ROLE = keccak256("SUPER_ADMIN_ROLE");
	bytes32 public constant override ADMIN_ROLE = keccak256("ADMIN_ROLE");
	bytes32 public constant override MODERATOR_ROLE = keccak256("MODERATOR_ROLE");

	mapping(PermissionName => PermissionLevel) public override permissions;

	/// @notice Constructor to set up initial roles
	/// @param initialSuperAdmin The address to be granted the SUPER_ADMIN_ROLE
	constructor(address initialSuperAdmin) {
		_grantRole(SUPER_ADMIN_ROLE, initialSuperAdmin);
		_setRoleAdmin(ADMIN_ROLE, SUPER_ADMIN_ROLE);
		_setRoleAdmin(MODERATOR_ROLE, SUPER_ADMIN_ROLE);
		_setRoleAdmin(MODERATOR_ROLE, ADMIN_ROLE);
	}

	/// @inheritdoc ISpaceAccessControl
	function setPermission(
		PermissionName permissionName,
		PermissionLevel level
	) external override onlyRole(SUPER_ADMIN_ROLE) {
		permissions[permissionName] = level;
	}

	/// @inheritdoc ISpaceAccessControl
	function checkPermission(PermissionName permissionName, address user) public view override returns (bool) {
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

	/// @notice Modifier to restrict access based on permissions
	/// @param permissionName The name of the permission to check
	modifier onlyAllowed(PermissionName permissionName) {
		if (!checkPermission(permissionName, msg.sender)) {
			revert NotAllowed(msg.sender, permissionName);
		}
		_;
	}
}
