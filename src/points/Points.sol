// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPoints, IERC20Metadata, IERC20 } from "./interfaces/IPoints.sol";

/// @title Points - A non-transferable ERC20-like token contract
/// @notice This contract implements a non-transferable token system
/// @dev This is an abstract contract that needs to be inherited and implemented
abstract contract Points is IPoints {
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	/// @notice Initializes the contract with a name, symbol, and decimals
	/// @param tokenName The name of the token
	/// @param tokenSymbol The symbol of the token
	/// @param tokenDecimals The number of decimals for the token
	constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
		_name = tokenName;
		_symbol = tokenSymbol;
		_decimals = tokenDecimals;
	}

	/// @dev Internal function to calculate balance at a specific timestamp
	/// @param user The address of the user
	/// @param timestamp The timestamp at which to check the balance
	/// @return The balance of the user at the given timestamp
	function _balanceAtTimestamp(address user, uint256 timestamp) internal view virtual returns (uint256);

	/// @inheritdoc IPoints
	function balanceAtTimestamp(address user, uint256 timestamp) public view virtual override returns (uint256) {
		return _balanceAtTimestamp(user, timestamp);
	}

	/// @inheritdoc IERC20
	function balanceOf(address user) public view virtual override returns (uint256) {
		return _balanceAtTimestamp(user, block.timestamp);
	}

	/// @dev Internal function to calculate total supply at a specific timestamp
	/// @param timestamp The timestamp at which to check the total supply
	/// @return The total supply at the given timestamp
	function _totalSupplyAtTimestamp(uint256 timestamp) internal view virtual returns (uint256);

	/// @inheritdoc IPoints
	function totalSupplyAtTimestamp(uint256 timestamp) public view virtual override returns (uint256) {
		return _totalSupplyAtTimestamp(timestamp);
	}

	/// @inheritdoc IERC20
	function totalSupply() public view virtual override returns (uint256) {
		return totalSupplyAtTimestamp(block.timestamp);
	}

	/// @inheritdoc IERC20
	function transfer(address, uint256) public pure virtual override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20
	function allowance(address, address) public view virtual override returns (uint256) {
		return 0;
	}

	/// @inheritdoc IERC20
	function approve(address, uint256) public pure virtual override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20
	function transferFrom(address, address, uint256) public pure virtual override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20Metadata
	function name() public view virtual override returns (string memory) {
		return _name;
	}

	/// @inheritdoc IERC20Metadata
	function symbol() public view virtual override returns (string memory) {
		return _symbol;
	}

	/// @inheritdoc IERC20Metadata
	function decimals() public view virtual override returns (uint8) {
		return _decimals;
	}
}
