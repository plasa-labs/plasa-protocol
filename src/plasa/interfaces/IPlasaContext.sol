// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title IPlasaContext
/// @dev This interface defines the context for Plasa, including error handling for registration status.
/// @notice This interface is used to manage the registration state of entities in the Plasa system.
interface IPlasaContext {
	/// @notice Error thrown when an entity is not registered.
	error NotRegistered();
}
