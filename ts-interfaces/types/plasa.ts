import { AccountAddress } from './basic'
import { SpacePreview } from './spaces'
import { StampView } from './stamps'

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
	stamps: StampView[]
	spaces: SpacePreview[]
}

export type ViewReturnType = PlasaView
