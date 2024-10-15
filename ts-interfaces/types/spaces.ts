import { AccountAddress, Timestamp } from './basic'
import { Points } from './points'
import { QuestionPreview } from './questions'

export interface SpaceData {
	contractAddress: AccountAddress
	name: string
	description: string
	imageUrl: string
	creationTimestamp: Timestamp
}

export interface SpaceUser {
	roles: {
		superAdmin: boolean
		admin: boolean
		mod: boolean
	}
	permissions: {
		UpdateSpaceInfo: boolean
		UpdateSpaceDefaultPoints: boolean
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
}

export interface SpacePreview {
	data: SpaceData
	user: SpaceUser
}

export interface Space extends SpacePreview {
	points: Points
	questions: QuestionPreview[]
}
