import { PlasaView, PlasaData, PlasaUser } from "../types/plasa"
import { StampType, StampView, StampData, StampUser } from "../types/stamps"
import { AccountAddress, Timestamp } from "../types/basic"
import { SpacePreview, SpaceData, SpaceUser, RolesUser, PermissionsUser } from "../types/spaces"

const examplePlasaQuery: PlasaView = {
	data: {
		contractAddress: "0x1234567890123456789012345678901234567890" as AccountAddress,
		chainId: 1,
		version: "0.1.0"
	} as PlasaData,

	user: {
		username: "alice"
	} as PlasaUser,

	stamps: [
		{
			data: {
				contractAddress: "0x2345678901234567890123456789012345678901" as AccountAddress,
				stampType: StampType.AccountOwnership,
				name: "Account Ownership Stamp",
				symbol: "AOS",
				totalSupply: 1000,
				specific: "0x" // No specific data for this stamp type
			} as StampData,
			user: {
				owns: true,
				stampId: 42,
				mintingTimestamp: 1625097600 as Timestamp,
				specific: "0x" // No specific data for this stamp type
			} as StampUser
		} as StampView,
		{
			data: {
				contractAddress: "0x3456789012345678901234567890123456789012" as AccountAddress,
				stampType: StampType.FollowerSince,
				name: "Follower Since Stamp",
				symbol: "FSS",
				totalSupply: 5000,
				specific: "0x0000000000000000000000000000000000000000000000000000000060e316a0" // Encoded timestamp
			} as StampData,
			user: {
				owns: true,
				stampId: 123,
				mintingTimestamp: 1625184000 as Timestamp,
				specific: "0x0000000000000000000000000000000000000000000000000000000060e316a0" // Encoded timestamp
			} as StampUser
		} as StampView
	],

	spaces: [
		{
			data: {
				contractAddress: "0x4567890123456789012345678901234567890123" as AccountAddress,
				name: "Governance Space",
				description: "A space for community governance",
				imageUrl: "https://example.com/governance-space.png",
				creationTimestamp: 1625270400 as Timestamp
			} as SpaceData,
			user: {
				roles: {
					superAdmin: false,
					admin: true,
					mod: true
				} as RolesUser,
				permissions: {
					UpdateSpaceInfo: true,
					UpdateSpacePoints: true,
					UpdateQuestionInfo: true,
					UpdateQuestionDeadline: true,
					UpdateQuestionPoints: true,
					CreateFixedQuestion: true,
					CreateOpenQuestion: true,
					VetoFixedQuestion: false,
					VetoOpenQuestion: false,
					VetoOpenQuestionOption: false,
					LiftVetoFixedQuestion: false,
					LiftVetoOpenQuestion: false,
					LiftVetoOpenQuestionOption: false,
					AddOpenQuestionOption: true
				} as PermissionsUser
			} as SpaceUser
		} as SpacePreview
	]
} as PlasaView

console.log(JSON.stringify(examplePlasaQuery, null, 2))
