import { AccountAddress, Timestamp } from './basic'

export enum StampType {
	Null = 'Null',
	AccountOwnership = 'AccountOwnership',
	FollowerSince = 'FollowerSince',
}

export interface StampData {
	contractAddress: AccountAddress
	spaceAddress: AccountAddress
	stampType: StampType
	name: string
	symbol: string
	platform: string
	totalSupply: number
	specific?: unknown
}



export interface StampUser {
	owns: boolean
	stampId?: number
	mintingTimestamp?: Timestamp
	specific?: unknown
}

export interface StampView {
	data: StampData
	user: StampUser
}

export interface FollowerSinceStampData extends StampData {
	specific: string // followedAccount
}

export interface FollowerSinceStampUser extends StampUser {
	specific: Timestamp // follow date
}

export interface FollowerSinceStamp extends StampView {
	data: FollowerSinceStampData
	user: FollowerSinceStampUser
}

export interface AccountOwnershipStamp extends StampView { }
