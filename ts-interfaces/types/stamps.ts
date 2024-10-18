import { AccountAddress, Timestamp } from './basic'

export enum StampType {
	Null = 'Null',
	AccountOwnership = 'AccountOwnership',
	FollowerSince = 'FollowerSince',
}

export interface StampData {
	contractAddress: AccountAddress
	stampType: StampType
	name: string
	symbol: string
	totalSupply: number
	specific?: string // ABI-encoded data as a hex string
}

export interface StampUser {
	owns: boolean
	stampId?: number
	mintingTimestamp?: Timestamp
	specific?: string // ABI-encoded data as a hex string
}

export interface StampView {
	data: StampData
	user: StampUser
}

