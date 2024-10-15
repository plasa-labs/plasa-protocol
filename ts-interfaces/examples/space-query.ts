import { Space } from "../types/spaces"
import { QuestionType } from "../types/questions"

const exampleSpaceQuery: Space = {
	data: {
		contractAddress: "0xaaaa1111bbbb2222cccc3333dddd4444eeee5555",
		name: "Crypto Governance",
		description: "A space for discussing and voting on crypto governance proposals",
		imageUrl: "https://example.com/crypto-governance.png",
		creationTimestamp: 1620000000000
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
	},
	points: {
		data: {
			contractAddress: "0xffff9999gggg8888hhhh7777iiii6666jjjj5555",
			name: "Governance Points",
			symbol: "GP"
		},
		user: {
			currentBalance: 1000
		}
	},
	questions: [
		{
			data: {
				contractAddress: "0x1111aaaabbbbccccddddeeeeffffgggg2222hhhh",
				type: QuestionType.Fixed,
				title: "Should we implement EIP-1559?",
				description: "Vote on whether to implement Ethereum Improvement Proposal 1559",
				creator: "0x3333444455556666777788889999aaaabbbbcccc",
				kickoff: 1625270400000,
				deadline: 1625875200000,
				isActive: true,
				voteCount: 1500
			},
			user: {
				canVote: true,
				pointsAtDeadline: 950
			}
		},
		{
			data: {
				contractAddress: "0x4444iiiijjjjkkkkllllmmmmnnnnoooo5555pppp",
				type: QuestionType.Open,
				title: "What should be our next focus area?",
				description: "Propose and vote on the next major focus area for our project",
				creator: "0x6666777788889999aaaabbbbccccddddeeeefffff",
				kickoff: 1625356800000,
				deadline: 1626048000000,
				isActive: true,
				voteCount: 750
			},
			user: {
				canVote: true,
				pointsAtDeadline: 1000
			}
		}
	]
}

console.log(JSON.stringify(exampleSpaceQuery, null, 2))
