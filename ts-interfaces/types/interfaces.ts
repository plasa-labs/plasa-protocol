// Points Types
interface Holder {
	user: string  // address
	balance: bigint
}

interface PointsData {
	contractAddress: string  // address
	name: string
	symbol: string
	totalSupply: bigint
	top10Holders: Holder[]
}

interface PointsUser {
	currentBalance: bigint
}

interface PointsView {
	data: PointsData
	user: PointsUser
}

// Question Types
enum QuestionType {
	Null,
	Open,
	Fixed
}

interface QuestionData {
	contractAddress: string  // address
	questionType: QuestionType
	title: string
	description: string
	tags: string[]
	creator: string  // address
	kickoff: bigint
	deadline: bigint
	isActive: boolean
	voteCount: bigint
}

interface QuestionUser {
	canVote: boolean
	pointsAtDeadline: bigint
}

interface OptionData {
	title: string
	description: string
	proposer: string  // address
	voteCount: bigint
	pointsAtDeadline: bigint
}

interface OptionUser {
	voted: boolean
}

interface OptionView {
	data: OptionData
	user: OptionUser
}

interface QuestionPreview {
	data: QuestionData
	user: QuestionUser
	points: PointsView
}

interface QuestionView {
	data: QuestionData
	user: QuestionUser
	options: OptionView[]
	points: PointsView
}

// Stamp Types
enum StampType {
	Null,
	AccountOwnership,
	FollowerSince
}

interface StampData {
	contractAddress: string  // address
	stampType: StampType
	name: string
	symbol: string
	totalSupply: bigint
	specific: string  // bytes in hex
}

interface StampUser {
	owns: boolean
	stampId: bigint
	mintingTimestamp: bigint
	specific: string  // bytes in hex
}

interface StampView {
	data: StampData
	user: StampUser
}

// Points Stamp Types
interface PointsStampData extends StampData {
	multiplier: bigint
}

// Space Types
interface SpaceData {
	contractAddress: string  // address
	name: string
	description: string
	imageUrl: string
	creationTimestamp: bigint
}

interface RolesUser {
	superAdmin: boolean
	admin: boolean
	mod: boolean
}

interface PermissionsUser {
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

interface SpaceUser {
	roles: RolesUser
	permissions: PermissionsUser
}

interface SpacePreview {
	data: SpaceData
	user: SpaceUser
}

interface PointsStampView {
	data: PointsStampData
	user: StampUser
}

interface MultipleFollowerSincePointsView {
	points: PointsView
	stamps: PointsStampView[]
}

interface SpaceView {
	data: SpaceData
	user: SpaceUser
	points: MultipleFollowerSincePointsView
	questions: QuestionPreview[]
}

// Plasa Types
interface PlasaData {
	contractAddress: string  // address
	chainId: bigint
	version: string
}

interface PlasaUser {
	username: string
}

interface PlasaView {
	data: PlasaData
	user: PlasaUser
	stamps: StampView[]
	spaces: SpacePreview[]
}
