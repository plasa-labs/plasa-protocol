import { QuestionView, QuestionType } from "../types/questions"
import { AccountAddress, Timestamp } from "../types/basic"

// New Open question example
const exampleOpenQuestionQuery: QuestionView = {
	data: {
		contractAddress: "0x3333bbbbccccddddeeeeffffgggg4444iiii" as AccountAddress,
		questionType: QuestionType.Open,
		title: "What should be our next community project?",
		description: "Propose and vote on ideas for our next community-driven project",
		creator: "0x5555666677778888999900001111aaaabbbbcccc" as AccountAddress,
		kickoff: 1630454400000 as Timestamp,
		deadline: 1631664000000 as Timestamp,
		isActive: true,
		voteCount: 750
	},
	user: {
		canVote: true,
		pointsAtDeadline: 1200
	},
	options: [
		{
			data: {
				title: "Develop a decentralized social media platform",
				description: "Create a censorship-resistant social network using blockchain technology",
				proposer: "0x9999000011112222aaaabbbbccccddddeeeefffff" as AccountAddress,
				voteCount: 300,
				pointsAtDeadline: 45000
			},
			user: {
				voted: false
			}
		},
		{
			data: {
				title: "Launch a community-owned NFT marketplace",
				description: "Build an NFT marketplace where fees are distributed to community members",
				proposer: "0xccccddddeeeefffff22223333444455556666777" as AccountAddress,
				voteCount: 250,
				pointsAtDeadline: 38000
			},
			user: {
				voted: false
			}
		},
		{
			data: {
				title: "Create a DAO-governed grant program",
				description: "Establish a grant program to fund innovative blockchain projects, governed by our DAO",
				proposer: "0xeeeefffff000011112222333344445555666777" as AccountAddress,
				voteCount: 200,
				pointsAtDeadline: 30000
			},
			user: {
				voted: false
			}
		}
	]
}

console.log(JSON.stringify(exampleOpenQuestionQuery, null, 2))
