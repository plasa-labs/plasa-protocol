import { AccountAddress } from './basic'

export interface OptionData {
	title: string
	description: string
	proposer: AccountAddress
	voteCount: number
	pointsCurrent: number
	pointsAtDeadline: number
}

export interface OptionUser {
	voted: boolean
}

export interface Option {
	data: OptionData
	user: OptionUser
}
