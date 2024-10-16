// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IStampView } from "../stamps/interfaces/IStampView.sol";
import { ISpaceView } from "../spaces/interfaces/ISpaceView.sol";

interface IPlasaView {
	struct PlasaData {
		address contractAddress;
		uint256 chainId;
		string version;
	}

	struct PlasaUser {
		string username;
	}

	struct PlasaView {
		PlasaData data;
		PlasaUser user;
		IStampView.StampView[] stamps;
		ISpaceView.SpacePreview[] spaces;
	}

	function getPlasaView(address user) external view returns (PlasaView memory);
}
