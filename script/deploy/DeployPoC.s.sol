// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Script, console } from "forge-std/Script.sol";
import { Space } from "../../src/spaces/Space.sol";
import { ISpace } from "../../src/spaces/interfaces/ISpace.sol";
import { DeployPoCArgs } from "./DeployPoCArgs.s.sol";
import { IFollowerSinceStamp } from "../../src/stamps/interfaces/IFollowerSinceStamp.sol";
import { IFollowerSincePoints } from "../../src/points/interfaces/IFollowerSincePoints.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import { FollowerSinceStamp } from "../../src/stamps/FollowerSinceStamp.sol";
import { FollowerSincePoints } from "../../src/points/FollowerSincePoints.sol";
import { Plasa } from "../../src/plasa/Plasa.sol";

contract DeployPoC is Script {
	function run() public {
		uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

		// Create an instance of DeployPoCArgs with the deployer's address
		address deployer = vm.addr(deployerPrivateKey);
		console.log("Deployer address:", deployer);

		DeployPoCArgs deployArgs = new DeployPoCArgs();
		DeployPoCArgs.DeploymentArgs memory args = deployArgs.getArgs();

		vm.startBroadcast(deployerPrivateKey);

		FollowerSinceStamp stamp = new FollowerSinceStamp(args.stampSigner, args.stampPlatform, args.stampFollowed);

		FollowerSincePoints points = new FollowerSincePoints(address(stamp), args.pointsName, args.pointsSymbol);

		Space space = new Space(
			args.initialSuperAdmins,
			args.initialAdmins,
			args.initialModerators,
			args.spaceName,
			args.spaceDescription,
			args.spaceImageUrl,
			address(points),
			args.minPointsToAddOpenQuestionOption
		);

		// Deploy Plasa
		// Set space initial super admin as Plasa owner
		Plasa plasa = new Plasa(args.initialSuperAdmins[0]);

		plasa.addStamp(address(stamp));
		plasa.addSpace(address(space));

		vm.stopBroadcast();

		// Log deployment information in JSON format
		console.log("DEPLOYMENT_LOG_START");
		console.log("{");
		console.log('  "DeployerAddress": "%s",', deployer);
		console.log('  "ChainId": %d,', block.chainid);
		// console.log('  "CompilerVersion": "%s",', vm.envString("FOUNDRY_SOLC_VERSION"));
		console.log('  "Contracts": [');
		console.log("    {");
		console.log('      "FollowerSinceStamp": {');
		console.log('        "address": "%s",', address(stamp));
		console.log('        "deployer": "%s",', deployer);
		console.log('        "contractName": "FollowerSinceStamp",');
		console.log('        "sourcePath": "src/stamps/FollowerSinceStamp.sol",');
		console.log('        "arguments": {');
		console.log('          "signer": "%s",', args.stampSigner);
		console.log('          "platform": "%s",', args.stampPlatform);
		console.log('          "followed": "%s"', args.stampFollowed);
		console.log("        }");
		console.log("      }");
		console.log("    },");
		console.log("    {");
		console.log('      "FollowerSincePoints": {');
		console.log('        "address": "%s",', address(points));
		console.log('        "deployer": "%s",', deployer);
		console.log('        "contractName": "FollowerSincePoints",');
		console.log('        "sourcePath": "src/points/FollowerSincePoints.sol",');
		console.log('        "arguments": {');
		console.log('          "followerStamp": "%s",', address(stamp));
		console.log('          "name": "%s",', args.pointsName);
		console.log('          "symbol": "%s"', args.pointsSymbol);
		console.log("        }");
		console.log("      }");
		console.log("    },");
		console.log("    {");
		console.log('      "Space": {');
		console.log('        "address": "%s",', address(space));
		console.log('        "deployer": "%s",', deployer);
		console.log('        "contractName": "Space",');
		console.log('        "sourcePath": "src/spaces/Space.sol",');
		console.log('        "arguments": {');
		console.log('          "initialSuperAdmins": %s,', _formatAddressArray(args.initialSuperAdmins));
		console.log('          "initialAdmins": %s,', _formatAddressArray(args.initialAdmins));
		console.log('          "initialModerators": %s,', _formatAddressArray(args.initialModerators));
		console.log('          "spaceName": "%s",', args.spaceName);
		console.log('          "spaceDescription": "%s",', args.spaceDescription);
		console.log('          "spaceImageUrl": "%s",', args.spaceImageUrl);
		console.log('          "defaultPoints": "%s",', address(points));
		console.log('          "minPointsToAddOpenQuestionOption": %d', args.minPointsToAddOpenQuestionOption);
		console.log("        }");
		console.log("      }");
		console.log("    },");
		console.log("    {");
		console.log('      "Plasa": {');
		console.log('        "address": "%s",', address(plasa));
		console.log('        "deployer": "%s",', deployer);
		console.log('        "contractName": "Plasa",');
		console.log('        "sourcePath": "src/plasa/Plasa.sol",');
		console.log('        "arguments": {');
		console.log('          "initialOwner": "%s"', args.initialSuperAdmins[0]);
		console.log("        }");
		console.log("      }");
		console.log("    }");
		console.log("  ]");
		console.log("}");
		console.log("DEPLOYMENT_LOG_END");
	}

	function _formatAddressArray(address[] memory addresses) internal pure returns (string memory) {
		bytes memory result = "[";
		for (uint i = 0; i < addresses.length; i++) {
			if (i > 0) {
				result = abi.encodePacked(result, ",");
			}
			result = abi.encodePacked(result, '"', Strings.toHexString(uint160(addresses[i]), 20), '"');
		}
		result = abi.encodePacked(result, "]");
		return string(result);
	}
}
