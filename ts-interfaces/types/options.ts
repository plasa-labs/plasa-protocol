import { AccountAddress } from './basic'

export interface OptionData {
	title: string
	description: string
	proposer: AccountAddress
	voteCount: number
	pointsAtDeadline: number
}

export interface OptionUser {
	voted: boolean
}

export interface OptionView {
	data: OptionData
	user: OptionUser
}
