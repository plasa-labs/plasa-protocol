import { AccountAddress } from './basic'

export interface PointsData {
	contractAddress: AccountAddress
	name: string
	symbol: string
}

export interface PointsUser {
	currentBalance: number
}

export interface Points {
	data: PointsData
	user: PointsUser
}
