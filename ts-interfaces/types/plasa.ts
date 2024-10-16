import { AccountAddress } from './basic'
import { SpacePreview } from './spaces'
import { StampView, FollowerSinceStamp, AccountOwnershipStamp } from './stamps'

export interface PlasaData {
	contractAddress: AccountAddress
	chainId: number
	version: string
}

export interface PlasaUser {
	username: string
}

export interface PlasaView {
	data: PlasaData
	user: PlasaUser
	stamps: (StampView | FollowerSinceStamp | AccountOwnershipStamp)[]
	spaces: SpacePreview[]
}

export type ViewReturnType = PlasaView
