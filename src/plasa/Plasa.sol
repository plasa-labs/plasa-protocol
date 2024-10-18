// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Space, ISpace, ISpaceView } from "../spaces/Space.sol";
import { AccountOwnershipStamp, IAccountOwnershipStamp } from "../stamps/AccountOwnershipStamp.sol";
import { IPlasa } from "./IPlasa.sol";
import { IStamp, IStampView } from "../stamps/interfaces/IStamp.sol";
import { IPlasaView } from "./IPlasaView.sol";

/// @title Plasa - The main contract for managing spaces and account ownership stamps
/// @notice This contract serves as the central hub for all Plasa-related operations
/// @dev Inherits from Ownable for access control and implements IPlasa interface
contract Plasa is Ownable, IPlasa {
	/// @notice Array to store all created spaces
	ISpace[] private _spaces;

	/// @notice Array to store all stamps
	IStamp[] private _stamps;

	/// @notice Initializes the Plasa contract
	/// @param initialOwner The address that will own this Plasa contract
	constructor(address initialOwner) Ownable(initialOwner) {}

	/// @inheritdoc IPlasaView
	function getPlasaView(address user) external view returns (IPlasaView.PlasaView memory) {
		IStampView.StampView[] memory stampsViews = new IStampView.StampView[](_stamps.length);
		for (uint256 i = 0; i < _stamps.length; i++) {
			stampsViews[i] = _stamps[i].getStampView(user);
		}

		ISpaceView.SpacePreview[] memory spacesPreviews = new ISpaceView.SpacePreview[](_spaces.length);
		for (uint256 i = 0; i < _spaces.length; i++) {
			spacesPreviews[i] = _spaces[i].getSpacePreview(user);
		}

		IPlasaView.PlasaData memory data = IPlasaView.PlasaData({
			contractAddress: address(this),
			chainId: block.chainid,
			version: "0.1.0"
		});

		return
			IPlasaView.PlasaView({
				data: data,
				user: IPlasaView.PlasaUser({ username: "testusername" }),
				stamps: stampsViews,
				spaces: spacesPreviews
			});
	}

	/// @inheritdoc IPlasa
	function addStamp(address stamp) external onlyOwner {
		_stamps.push(IStamp(stamp));
	}

	/// @inheritdoc IPlasa
	function addSpace(address space) external onlyOwner {
		_spaces.push(ISpace(space));
	}

	/// @inheritdoc IPlasa
	function getSpaces() external view returns (ISpace[] memory) {
		return _spaces;
	}

	/// @inheritdoc IPlasa
	function getStamps() external view returns (IStamp[] memory) {
		return _stamps;
	}

	/// @inheritdoc IPlasa
	function getSpace(uint256 index) external view returns (ISpace) {
		if (index >= _spaces.length) revert IndexOutOfBounds(index, _spaces.length);
		return _spaces[index];
	}

	/// @inheritdoc IPlasa
	function getStamp(uint256 index) external view returns (IStamp) {
		if (index >= _stamps.length) revert IndexOutOfBounds(index, _stamps.length);
		return _stamps[index];
	}
}
