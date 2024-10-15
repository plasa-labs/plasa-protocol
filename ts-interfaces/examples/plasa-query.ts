import { Plasa } from "../types/plasa"
import { StampType } from "../types/stamps"

const examplePlasaQuery: Plasa = {
	data: {
		contractAddress: "0x1234567890123456789012345678901234567890",
		chainId: 1,
		version: "1.0.0"
	},
	user: {
		username: "alice"
	},
	stamps: [
		{
			data: {
				contractAddress: "0xabcdef1234567890abcdef1234567890abcdef12",
				type: StampType.AccountOwnership,
				name: "Twitter Account Ownership",
				symbol: "TWO",
				platform: "Twitter",
				totalSupply: 1000000
			},
			user: {
				owns: true,
				stampId: 123456,
				mintingTimestamp: 1625097600000
			},
			userUsername: "alice_twitter"
		},
		{
			data: {
				contractAddress: "0x9876543210fedcba9876543210fedcba98765432",
				type: StampType.FollowerSince,
				name: "Early Follower",
				symbol: "EF",
				platform: "Twitter",
				totalSupply: 5000,
				followedAccount: "0x1111222233334444555566667777888899990000",
				space: "CryptoNews"
			},
			user: {
				owns: true,
				stampId: 789012,
				mintingTimestamp: 1625184000000,
				followTimestamp: 1625097600000,
				timeSinceFollow: 86400000 // 1 day in milliseconds
			}
		}
	],
	spaces: [
		{
			data: {
				contractAddress: "0x1111222233334444555566667777888899990000",
				name: "CryptoNews",
				description: "Latest news and updates in the crypto space",
				imageUrl: "https://example.com/crypto-news.png",
				creationTimestamp: 1625000000000
			},
			user: {
				roles: {
					superAdmin: false,
					admin: true,
					mod: true
				},
				permissions: {
					UpdateSpaceInfo: true,
					UpdateSpaceDefaultPoints: true,
					UpdateQuestionInfo: true,
					UpdateQuestionDeadline: true,
					UpdateQuestionPoints: true,
					CreateFixedQuestion: true,
					CreateOpenQuestion: true,
					VetoFixedQuestion: true,
					VetoOpenQuestion: true,
					VetoOpenQuestionOption: true,
					LiftVetoFixedQuestion: true,
					LiftVetoOpenQuestion: true,
					LiftVetoOpenQuestionOption: true,
					AddOpenQuestionOption: true
				}
			}
		}
	]
}

console.log(JSON.stringify(examplePlasaQuery, null, 2))
