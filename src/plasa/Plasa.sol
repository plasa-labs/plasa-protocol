// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Space, ISpace, ISpaceView } from "../spaces/Space.sol";
import { AccountOwnershipStamp, IAccountOwnershipStamp } from "../stamps/AccountOwnershipStamp.sol";
import { IPlasaView } from "./IPlasaView.sol";
import { IStamp, IStampView } from "../stamps/interfaces/IStamp.sol";

/// @title Plasa - The main contract for managing spaces and account ownership stamps
/// @notice This contract serves as the central hub for all Plasa-related contracts
/// @dev Inherits from Ownable for access control
contract Plasa is Ownable, IPlasaView {
	/// @notice Array to store all created spaces
	ISpace[] public spaces;

	IStamp[] public stamps;

	/// @notice Mapping to store account ownership stamps by platform name
	mapping(string => IAccountOwnershipStamp) public accountOwnershipStamps;

	/// @notice Event emitted when a new space is created
	event SpaceCreated(address spaceAddress, address owner);

	/// @notice Event emitted when a new account ownership stamp is created
	event AccountOwnershipStampCreated(string platform, address stampAddress);

	/// @notice Custom error for when a stamp already exists for a platform
	error StampAlreadyExists(string platform);

	/// @notice Initializes the Plasa contract
	/// @param initialOwner The address that will own this Plasa contract
	constructor(address initialOwner) Ownable(initialOwner) {}

	/// @notice Creates a new space
	/// @param initialSuperAdmins An array of addresses to be granted the SUPER_ADMIN_ROLE
	/// @param initialAdmins An array of addresses to be granted the ADMIN_ROLE
	/// @param initialModerators An array of addresses to be granted the MODERATOR_ROLE
	/// @param stampSigner The address authorized to sign mint requests for follower stamps
	/// @param platform The platform name (e.g., "Instagram", "Twitter")
	/// @param followed The account being followed
	/// @param spaceName The name of the space
	/// @param spaceDescription The description of the space
	/// @param spaceImageUrl The URL of the space's image
	/// @param pointsSymbol The symbol of the points
	/// @param minPointsToAddOpenQuestionOption The minimum points required to add an open question option
	/// @return The address of the newly created space
	function createSpace(
		address[] memory initialSuperAdmins,
		address[] memory initialAdmins,
		address[] memory initialModerators,
		address stampSigner,
		string memory platform,
		string memory followed,
		string memory spaceName,
		string memory spaceDescription,
		string memory spaceImageUrl,
		string memory pointsSymbol,
		uint256 minPointsToAddOpenQuestionOption
	) external returns (address) {
		ISpace newSpace = new Space(
			initialSuperAdmins,
			initialAdmins,
			initialModerators,
			stampSigner,
			platform,
			followed,
			spaceName,
			spaceDescription,
			spaceImageUrl,
			pointsSymbol,
			minPointsToAddOpenQuestionOption
		);
		spaces.push(newSpace);
		emit SpaceCreated(address(newSpace), msg.sender);
		return address(newSpace);
	}

	/// @notice Creates a new account ownership stamp
	/// @param platform The platform name (e.g., "Instagram", "Twitter")
	/// @param stampSigner The address authorized to sign ownership verification requests
	/// @return The address of the newly created account ownership stamp
	function createAccountOwnershipStamp(
		string memory platform,
		address stampSigner
	) external onlyOwner returns (address) {
		if (address(accountOwnershipStamps[platform]) != address(0)) {
			revert StampAlreadyExists(platform);
		}

		IAccountOwnershipStamp newStamp = new AccountOwnershipStamp(address(this), stampSigner, platform);
		accountOwnershipStamps[platform] = newStamp;
		emit AccountOwnershipStampCreated(platform, address(newStamp));
		return address(newStamp);
	}

	/// @notice Retrieves the Plasa view for a given user
	/// @param user The address of the user to get the Plasa view for
	/// @return The Plasa view for the given user
	function getPlasaView(address user) external view returns (IPlasaView.PlasaView memory) {
		IStampView.StampView[] memory stampsViews = new IStampView.StampView[](stamps.length);
		for (uint256 i = 0; i < stamps.length; i++) {
			stampsViews[i] = stamps[i].getStampView(user);
		}

		ISpaceView.SpacePreview[] memory spacesPreviews = new ISpaceView.SpacePreview[](spaces.length);
		for (uint256 i = 0; i < spaces.length; i++) {
			spacesPreviews[i] = spaces[i].getSpacePreview(user);
		}

		IPlasaView.PlasaData memory data = IPlasaView.PlasaData({
			contractAddress: address(this),
			chainId: block.chainid,
			version: "0.1.0"
		});

		return
			IPlasaView.PlasaView(data, IPlasaView.PlasaUser({ username: "testusername" }), stampsViews, spacesPreviews);
	}
}
