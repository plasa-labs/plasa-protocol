import { AccountAddress, Timestamp } from './basic'

export enum StampType {
	Null = 'Null',
	AccountOwnership = 'AccountOwnership',
	FollowerSince = 'FollowerSince',
}

export interface StampData {
	contractAddress: AccountAddress
	type: StampType
	name: string
	symbol: string
	platform: string
	totalSupply: number
}

export interface StampUser {
	owns: boolean
	stampId?: number
	mintingTimestamp?: Timestamp
}

export interface Stamp {
	data: StampData
	user: StampUser
}

export interface FollowerSinceStampData extends StampData {
	followedAccount: string
	space: string
}

export interface FollowerSinceStampUser extends StampUser {
	followTimestamp: Timestamp
	timeSinceFollow: Timestamp
}

export interface FollowerSinceStamp extends Stamp {
	data: FollowerSinceStampData
	user: FollowerSinceStampUser
}

export interface AccountOwnershipStamp extends Stamp {
	userUsername?: string
}
