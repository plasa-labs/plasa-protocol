// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { ISpace } from "../../src/spaces/interfaces/ISpace.sol";
import { DeployPoCArgs } from "./DeployPoCArgs.s.sol";
import { IFollowerSinceStamp } from "../../src/stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../src/points/interfaces/IFollowerSincePoints.sol";

contract DeployPoC is Script {
	function run() public {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

		// Create an instance of DeployPoCArgs with the deployer's address
		address deployer = vm.addr(deployerPrivateKey);
		console.log("Deployer address:", deployer);

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		// Deploy Space
		Space space = new Space(
			args.spaceOwner,
			args.stampSigner,
			args.stampPlatform,
			args.stampFollowed,
			args.spaceName,
			args.spaceDescription,
			args.spaceImageUrl
		);

		vm.stopBroadcast();

		// Retrieve Stamp and Points contract addresses
		IFollowerSinceStamp stamp = space.followerStamp();
		IFollowerSincePoints points = space.followerPoints();

		// Log deployment information in JSON format
		console.log("DEPLOYMENT_LOG_START");
		console.log("{");
		console.log('  "DeployerAddress": "%s",', deployer);
		console.log('  "ChainId": %d,', block.chainid);
		console.log('  "Contracts": [');
		console.log("    {");
		console.log('      "Space": {');
		console.log('        "address": "%s",', address(space));
		console.log('        "deployer": "%s",', deployer);
		console.log('        "arguments": {');
		console.log('          "spaceOwner": "%s",', args.spaceOwner);
		console.log('          "stampSigner": "%s",', args.stampSigner);
		console.log('          "stampPlatform": "%s",', args.stampPlatform);
		console.log('          "stampFollowed": "%s",', args.stampFollowed);
		console.log('          "spaceName": "%s",', args.spaceName);
		console.log('          "spaceDescription": "%s",', args.spaceDescription);
		console.log('          "spaceImageUrl": "%s"', args.spaceImageUrl);
		console.log("        }");
		console.log("      }");
		console.log("    },");
		console.log("    {");
		console.log('      "FollowerSinceStamp": {');
		console.log('        "address": "%s",', address(stamp));
		console.log('        "deployer": "%s",', address(space));
		console.log('        "arguments": {');
		console.log('          "signer": "%s",', args.stampSigner);
		console.log('          "platform": "%s",', stamp.PLATFORM());
		console.log('          "followed": "%s"', stamp.FOLLOWED());
		console.log("        }");
		console.log("      }");
		console.log("    },");
		console.log("    {");
		console.log('      "FollowerSincePoints": {');
		console.log('        "address": "%s",', address(points));
		console.log('        "deployer": "%s",', address(space));
		console.log('        "arguments": {');
		console.log('          "followerStamp": "%s",', address(stamp));
		console.log('          "name": "%s",', points.name());
		console.log('          "symbol": "%s"', points.symbol());
		console.log("        }");
		console.log("      }");
		console.log("    }");
		console.log("  ]");
		console.log("}");
		console.log("DEPLOYMENT_LOG_END");
	}
}
