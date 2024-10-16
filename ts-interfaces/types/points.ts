import { AccountAddress } from './basic'

export interface PointsData {
	contractAddress: AccountAddress
	name: string
	symbol: string
}

export interface PointsUser {
	currentBalance: number
}

export interface PointsView {
	data: PointsData
	user: PointsUser
}
