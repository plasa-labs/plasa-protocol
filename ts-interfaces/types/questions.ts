import { AccountAddress, Timestamp } from './basic'
import { OptionView } from './options'

export enum QuestionType {
	Null = 'Null',
	Open = 'Open',
	Fixed = 'Fixed',
}

export interface QuestionData {
	contractAddress: AccountAddress
	questionType: QuestionType
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

export interface QuestionView extends QuestionPreview {
	options: OptionView[]
}
