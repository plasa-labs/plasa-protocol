import { PlasaView } from "../types/plasa"
import { StampType, StampView } from "../types/stamps"
import { AccountAddress, Timestamp } from "../types/basic"
import { SpacePreview } from "../types/spaces"
const examplePlasaQuery: PlasaView = {
	data: {
		contractAddress: "0x1234567890123456789012345678901234567890" as AccountAddress,
		chainId: 1 as number,
		version: "1.0.0" as string
	},
	user: {
		username: "alice" as string
	},
	stamps: [
		{
			data: {
				contractAddress: "0xabcdef1234567890abcdef1234567890abcdef12" as AccountAddress,
				spaceAddress: "0x1111222233334444555566667777888899990000" as AccountAddress,
				stampType: StampType.AccountOwnership as StampType,
				name: "Twitter Account Ownership" as string,
				symbol: "TWO" as string,
				platform: "Twitter" as string,
				totalSupply: 1000000 as number
			},
			user: {
				owns: true as boolean,
				stampId: 123456 as number,
				mintingTimestamp: 1625097600000 as Timestamp
			}
		} as StampView,
		{
			data: {
				contractAddress: "0x9876543210fedcba9876543210fedcba98765432" as AccountAddress,
				spaceAddress: "0x1111222233334444555566667777888899990000" as AccountAddress,
				stampType: StampType.FollowerSince as StampType,
				name: "Early Follower" as string,
				symbol: "EF" as string,
				platform: "Twitter" as string,
				totalSupply: 5000 as number,
				specific: "0x1111222233334444555566667777888899990000" as AccountAddress // followedAccount
			},
			user: {
				owns: true as boolean,
				stampId: 789012 as number,
				mintingTimestamp: 1625184000000 as Timestamp,
				specific: 1625097600000 as Timestamp // follow date
			}
		} as StampView
	],
	spaces: [
		{
			data: {
				contractAddress: "0x1111222233334444555566667777888899990000" as AccountAddress,
				name: "CryptoNews" as string,
				description: "Latest news and updates in the crypto space" as string,
				imageUrl: "https://example.com/crypto-news.png" as string,
				creationTimestamp: 1625000000000 as Timestamp
			},
			user: {
				roles: {
					superAdmin: false as boolean,
					admin: true as boolean,
					mod: true as boolean
				},
				permissions: {
					UpdateSpaceInfo: true as boolean,
					UpdateSpacePoints: true as boolean,
					UpdateQuestionInfo: true as boolean,
					UpdateQuestionDeadline: true as boolean,
					UpdateQuestionPoints: true as boolean,
					CreateFixedQuestion: true as boolean,
					CreateOpenQuestion: true as boolean,
					VetoFixedQuestion: true as boolean,
					VetoOpenQuestion: true as boolean,
					VetoOpenQuestionOption: true as boolean,
					LiftVetoFixedQuestion: true as boolean,
					LiftVetoOpenQuestion: true as boolean,
					LiftVetoOpenQuestionOption: true as boolean,
					AddOpenQuestionOption: true as boolean
				}
			}
		} as SpacePreview
	]
}

console.log(JSON.stringify(examplePlasaQuery, null, 2))
