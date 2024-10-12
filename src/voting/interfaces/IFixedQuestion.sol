// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { IQuestion } from "./IQuestion.sol";

/// @title IFixedQuestion Interface
/// @notice Interface for fixed-choice voting questions
/// @dev Extends the IQuestion interface with specific functionality for fixed-choice questions
interface IFixedQuestion is IQuestion {
	/// @notice Error thrown when a user attempts to vote more than once
	/// @dev This error should be used in the implementation to prevent multiple votes from the same user
	error UserAlreadyVoted();

	/// @dev Error thrown when the lengths of option titles and descriptions arrays don't match
	error MismatchedOptionArrays();
}
