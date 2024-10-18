import { QuestionView, QuestionType } from "../types/questions"
import { AccountAddress, Timestamp } from "../types/basic"

const exampleFixedQuestionQuery: QuestionView = {
	data: {
		contractAddress: "0x1111aaaabbbbccccddddeeeeffffgggg2222hhhh" as AccountAddress,
		questionType: QuestionType.Fixed,
		title: "Should we implement EIP-1559?",
		description: "Vote on whether to implement Ethereum Improvement Proposal 1559",
		creator: "0x3333444455556666777788889999aaaabbbbcccc" as AccountAddress,
		kickoff: 1625270400000 as Timestamp,
		deadline: 1625875200000 as Timestamp,
		isActive: true,
		voteCount: 1500
	},
	user: {
		canVote: true,
		pointsAtDeadline: 950
	},
	options: [
		{
			data: {
				title: "Yes, implement EIP-1559",
				description: "Support the implementation of EIP-1559 to improve gas fee predictability",
				proposer: "0x7777888899990000aaaabbbbccccddddeeeefffff" as AccountAddress,
				voteCount: 850,
				pointsAtDeadline: 72000
			},
			user: {
				voted: false
			}
		},
		{
			data: {
				title: "No, don't implement EIP-1559",
				description: "Oppose the implementation of EIP-1559 due to concerns about miner revenue",
				proposer: "0xbbbbccccddddeeeefffff00001111222233334444" as AccountAddress,
				voteCount: 600,
				pointsAtDeadline: 53000
			},
			user: {
				voted: false
			}
		},
		{
			data: {
				title: "Delay implementation for further research",
				description: "Postpone the decision on EIP-1559 to allow for more research and discussion",
				proposer: "0xddddeeeefffff000011112222333344445555666" as AccountAddress,
				voteCount: 50,
				pointsAtDeadline: 4800
			},
			user: {
				voted: false
			}
		}
	]
}


console.log(JSON.stringify(exampleFixedQuestionQuery, null, 2))
