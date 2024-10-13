// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script } from "forge-std/Script.sol";

contract DeployPoCArgs is Script {
	struct DeploymentArgs {
		// Space args
		address spaceOwner;
		address stampSigner;
		string stampPlatform;
		string stampFollowed;
		string spaceName;
		string spaceDescription;
		string spaceImageUrl;
	}

	function getArgs() public view returns (DeploymentArgs memory) {
		DeploymentArgs memory args = DeploymentArgs({
			// Space args
			spaceOwner: vm.envAddress("SPACES_OWNER_ADDRESS"),
			stampSigner: vm.envAddress("EIP712_SIGNER_ADDRESS"),
			stampPlatform: "Instagram",
			stampFollowed: "base_onchain",
			spaceName: "Base",
			spaceDescription: "The (un)official community space for Base Onchain followers",
			spaceImageUrl: "https://example.com/base_onchain_logo.png"
		});

		return args;
	}
}
