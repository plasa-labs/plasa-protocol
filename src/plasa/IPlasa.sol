// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISpace } from "../spaces/interfaces/ISpace.sol";
import { IStamp } from "../stamps/interfaces/IStamp.sol";
import { IPlasaView } from "./IPlasaView.sol";

/// @title IPlasa - Interface for the main Plasa contract
/// @notice This interface defines the core functionality for managing spaces and stamps in the Plasa ecosystem
/// @dev Implements IPlasaView for read-only operations
interface IPlasa is IPlasaView {
	/// @notice Retrieves all created spaces
	/// @return An array of ISpace interfaces representing all spaces
	function getSpaces() external view returns (ISpace[] memory);

	/// @notice Retrieves a specific space by its index
	/// @param index The index of the space to retrieve
	/// @return The ISpace interface of the requested space
	function getSpace(uint256 index) external view returns (ISpace);

	/// @notice Retrieves all stamps
	/// @return An array of IStamp interfaces representing all stamps
	function getStamps() external view returns (IStamp[] memory);

	/// @notice Retrieves a specific stamp by its index
	/// @param index The index of the stamp to retrieve
	/// @return The IStamp interface of the requested stamp
	function getStamp(uint256 index) external view returns (IStamp);

	/// @notice Adds a new stamp to the Plasa ecosystem
	/// @dev Only callable by authorized entities
	/// @param stamp The address of the stamp contract to add
	function addStamp(address stamp) external;

	/// @notice Adds a new space to the Plasa ecosystem
	/// @dev Only callable by authorized entities
	/// @param space The address of the space contract to add
	function addSpace(address space) external;

	/// @notice Custom error for when an index is out of bounds
	/// @param index The index that was out of bounds
	/// @param arrayLength The length of the array that was being accessed
	error IndexOutOfBounds(uint256 index, uint256 arrayLength);
}
