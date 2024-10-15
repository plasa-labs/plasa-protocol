import { AccountAddress, Timestamp } from './basic'
import { Option } from './options'

export enum QuestionType {
	Open = 'Open',
	Fixed = 'Fixed',
}

export interface QuestionData {
	contractAddress: AccountAddress
	type: QuestionType
	title: string
	description: string
	creator: AccountAddress
	kickoff: Timestamp
	deadline: Timestamp
	isActive: boolean
	voteCount: number
}

export interface QuestionUser {
	canVote: boolean
	pointsAtDeadline: number
}

export interface QuestionPreview {
	data: QuestionData
	user: QuestionUser
}

export interface Question extends QuestionPreview {
	options: Option[]
}
