// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/// @title Points - A non-transferable ERC20-like token contract
/// @notice This contract implements a non-transferable token system
/// @dev This is an abstract contract that needs to be inherited and implemented
abstract contract Points is IERC20 {
	string private _name;
	string private _symbol;
	uint8 private _decimals;

	/// @notice Error thrown when attempting to transfer tokens
	error NonTransferable();

	/// @notice Initializes the contract with a name, symbol, and decimals
	/// @param tokenName The name of the token
	/// @param tokenSymbol The symbol of the token
	/// @param tokenDecimals The number of decimals for the token
	constructor(string memory tokenName, string memory tokenSymbol, uint8 tokenDecimals) {
		_name = tokenName;
		_symbol = tokenSymbol;
		_decimals = tokenDecimals;
	}

	/// @notice Gets the balance of the specified address
	/// @param account The address to query the balance of
	/// @return An uint256 representing the amount owned by the passed address
	function balanceOf(address account) public view virtual override returns (uint256);

	/// @notice Total number of tokens in existence
	/// @return An uint256 representing the total supply of tokens
	function totalSupply() public view virtual override returns (uint256);

	/// @notice Transfer is not supported for this non-transferable token
	/// @dev Always reverts with NonTransferable error
	/// @return bool This function always reverts and never returns
	function transfer(address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @notice No allowances are permitted for this non-transferable token
	/// @return uint256 Always returns 0
	function allowance(address, address) public pure override returns (uint256) {
		return 0;
	}

	/// @notice Approve is not supported for this non-transferable token
	/// @dev Always reverts with NonTransferable error
	/// @return bool This function always reverts and never returns
	function approve(address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @notice TransferFrom is not supported for this non-transferable token
	/// @dev Always reverts with NonTransferable error
	/// @return bool This function always reverts and never returns
	function transferFrom(address, address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @notice Returns the name of the token
	/// @return string The name of the token
	function name() public view returns (string memory) {
		return _name;
	}

	/// @notice Returns the symbol of the token
	/// @return string The symbol of the token
	function symbol() public view returns (string memory) {
		return _symbol;
	}

	/// @notice Returns the number of decimals the token uses
	/// @return uint8 The number of decimals
	function decimals() public view returns (uint8) {
		return _decimals;
	}
}
