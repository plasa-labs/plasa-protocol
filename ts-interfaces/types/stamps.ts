import { AccountAddress, Timestamp } from './basic'

export enum StampType {
	Null = 'Null',
	AccountOwnership = 'AccountOwnership',
	FollowerSince = 'FollowerSince',
}

export interface StampData {
	contractAddress: AccountAddress
	space: AccountAddress
	type: StampType
	name: string
	symbol: string
	platform: string
	totalSupply: number
	specific?: string
}

export interface StampUser {
	owns: boolean
	stampId?: number
	mintingTimestamp?: Timestamp
	specific?: string
}

export interface StampView {
	data: StampData
	user: StampUser
}

export interface FollowerSinceStampData extends StampData {
	followedAccount: string
	space: AccountAddress
}

export interface FollowerSinceStampUser extends StampUser {
	followTimestamp: Timestamp
	timeSinceFollow: Timestamp
}

export interface FollowerSinceStamp extends StampView {
	data: FollowerSinceStampData
	user: FollowerSinceStampUser
}

export interface AccountOwnershipStamp extends StampView { }
