import { AccountAddress, Timestamp } from './basic'
import { PointsView } from './points'
import { QuestionPreview } from './questions'

export interface SpaceData {
	contractAddress: AccountAddress
	name: string
	description: string
	imageUrl: string
	creationTimestamp: Timestamp
}

export interface RolesUser {
	superAdmin: boolean
	admin: boolean
	mod: boolean
}

export interface PermissionsUser {
	UpdateSpaceInfo: boolean
	UpdateSpacePoints: boolean
	UpdateQuestionInfo: boolean
	UpdateQuestionDeadline: boolean
	UpdateQuestionPoints: boolean
	CreateFixedQuestion: boolean
	CreateOpenQuestion: boolean
	VetoFixedQuestion: boolean
	VetoOpenQuestion: boolean
	VetoOpenQuestionOption: boolean
	LiftVetoFixedQuestion: boolean
	LiftVetoOpenQuestion: boolean
	LiftVetoOpenQuestionOption: boolean
	AddOpenQuestionOption: boolean
}

export interface SpaceUser {
	roles: RolesUser
	permissions: PermissionsUser
}

export interface SpacePreview {
	data: SpaceData
	user: SpaceUser
}

export interface SpaceView extends SpacePreview {
	points: PointsView
	questions: QuestionPreview[]
}
