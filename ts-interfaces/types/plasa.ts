import { AccountAddress } from './basic'
import { SpacePreview } from './spaces'
import { Stamp, FollowerSinceStamp, AccountOwnershipStamp } from './stamps'

export interface PlasaData {
	contractAddress: AccountAddress
	chainId: number
	version: string
}

export interface PlasaUser {
	username: string
}

export interface Plasa {
	data: PlasaData
	user: PlasaUser
	stamps: (Stamp | FollowerSinceStamp | AccountOwnershipStamp)[]
	spaces: SpacePreview[]
}

export type ViewReturnType = Plasa
