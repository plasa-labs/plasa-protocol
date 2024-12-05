// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPoints, IERC20Metadata } from "./interfaces/IPoints.sol";
import { IPointsView } from "./interfaces/IPointsView.sol";
import { PlasaContext } from "../plasa/PlasaContext.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";
import { IStamp } from "../stamps/interfaces/IStamp.sol";

/// @title Points - A non-transferable ERC20-like token contract
/// @notice This contract implements a non-transferable token system
/// @dev This is an abstract contract that needs to be inherited and implemented
contract Points is IPoints, PlasaContext {
	using Math for uint256;

	string private _name;
	string private _symbol;

	// Add storage for stamps and their multipliers
	StampInfo[] private _stamps;

	/// @notice Initializes the contract with a name and symbol
	/// @param tokenName The name of the token
	/// @param tokenSymbol The symbol of the token
	constructor(
		string memory tokenName,
		string memory tokenSymbol,
		address[] memory stampAddresses,
		uint256[] memory multipliers,
		address _plasaContract
	) PlasaContext(_plasaContract) {
		_name = tokenName;
		_symbol = tokenSymbol;

		if (stampAddresses.length != multipliers.length) revert ArrayLengthMismatch();

		for (uint256 i; i < stampAddresses.length; ) {
			_addStamp(IStamp(stampAddresses[i]), multipliers[i]);

			unchecked {
				++i;
			}
		}
	}

	/// @inheritdoc IPoints
	function balanceAtTimestamp(address user, uint256 timestamp) public view virtual returns (uint256) {
		uint256 totalPoints;

		for (uint256 i; i < _stamps.length; ) {
			// Get the stamp value for the user at the given timestamp
			uint256 stampValue = _stamps[i].stamp.userValueAtTimestamp(user, timestamp);

			// If the user has a non-zero stamp value, multiply it by the stamp's multiplier
			if (stampValue != 0) {
				unchecked {
					// Overflow is unlikely as stamp values and multipliers are controlled by admin
					totalPoints += stampValue * _stamps[i].multiplier;
				}
			}

			unchecked {
				++i;
			}
		}

		return totalPoints;
	}

	/// @inheritdoc IERC20
	function balanceOf(address user) public view override returns (uint256) {
		return balanceAtTimestamp(user, block.timestamp);
	}

	/// @inheritdoc IPoints
	function totalSupplyAtTimestamp(uint256 timestamp) public view override returns (uint256) {
		uint256 totalPoints;

		for (uint256 i; i < _stamps.length; ) {
			totalPoints += _stamps[i].stamp.totalValueAtTimestamp(timestamp);

			unchecked {
				++i;
			}
		}

		return totalPoints;
	}

	/// @inheritdoc IERC20
	function totalSupply() public view returns (uint256) {
		return totalSupplyAtTimestamp(block.timestamp);
	}

	/// @inheritdoc IERC20
	function transfer(address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20
	function allowance(address, address) public view override returns (uint256) {
		return 0;
	}

	/// @inheritdoc IERC20
	function approve(address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20
	function transferFrom(address, address, uint256) public pure override returns (bool) {
		revert NonTransferable();
	}

	/// @inheritdoc IERC20Metadata
	function name() public view override returns (string memory) {
		return _name;
	}

	/// @inheritdoc IERC20Metadata
	function symbol() public view override returns (string memory) {
		return _symbol;
	}

	/// @inheritdoc IERC20Metadata
	function decimals() public pure override returns (uint8) {
		return 18;
	}

	/// @inheritdoc IPointsView
	function getPointsView(address user) public view override returns (PointsView memory) {
		return
			PointsView({
				data: PointsData({
					contractAddress: address(this),
					name: name(),
					symbol: symbol(),
					totalSupply: totalSupply(),
					top10Holders: getTopHolders(0, 10)
				}),
				user: PointsUser({ currentBalance: balanceOf(user) }),
				stamps: _getPointsStampViews(user)
			});
	}

	/// @inheritdoc IPoints
	function getTopHolders(uint256 start, uint256 end) public view override(IPoints) returns (HolderData[] memory) {
		if (start >= end) revert IndexOutOfBounds();

		// Get all users from PlasaContext
		address[] memory users = _getUsers();
		uint256 usersLength = users.length;

		// Return empty array if no users
		if (usersLength == 0) return new HolderData[](0);

		// Create temporary array to store holders with non-zero balances
		Holder[] memory holders = new Holder[](usersLength);
		uint256 totalHolders;

		// Collect users with non-zero balances
		for (uint256 i; i < usersLength; ) {
			uint256 balance = balanceOf(users[i]);
			if (balance > 0) {
				holders[totalHolders] = Holder({ user: users[i], balance: balance });
				unchecked {
					++totalHolders;
				}
			}
			unchecked {
				++i;
			}
		}

		// Return empty array if no holders with balance
		if (totalHolders == 0) return new HolderData[](0);

		// Sort holders by balance (using quicksort)
		_quickSort(holders, 0, totalHolders - 1);

		// Calculate actual end index
		end = Math.min(end, totalHolders);
		uint256 length = end - start;

		// Create result array with usernames
		HolderData[] memory result = new HolderData[](length);

		if (length == 0) return result;

		for (uint256 i; i < length; ) {
			Holder memory holder = holders[start + i];
			result[i] = HolderData({ user: holder.user, name: _getUsername(holder.user), balance: holder.balance });
			unchecked {
				++i;
			}
		}

		return result;
	}

	/// @dev Quicksort implementation for sorting holders by balance
	/// @param arr The array of holders to sort
	/// @param left The left index of the array
	/// @param right The right index of the array
	function _quickSort(Holder[] memory arr, uint256 left, uint256 right) private pure {
		if (left >= right) return;

		uint256 pivot = arr[(left + right) / 2].balance;
		uint256 i = left;
		uint256 j = right;

		while (i <= j) {
			while (arr[i].balance > pivot) i++;
			while (arr[j].balance < pivot) j--;

			if (i <= j) {
				(arr[i], arr[j]) = (arr[j], arr[i]);
				i++;
				if (j > 0) j--;
			}
		}

		if (left < j) _quickSort(arr, left, j);
		if (i < right) _quickSort(arr, i, right);
	}

	/// @notice Adds a new stamp with its multiplier
	/// @dev This function should be called by authorized roles only
	/// @param stamp The stamp contract address
	/// @param multiplier The point multiplier for this stamp
	function _addStamp(IStamp stamp, uint256 multiplier) internal {
		_stamps.push(StampInfo({ stamp: stamp, multiplier: multiplier }));
		emit StampAdded(address(stamp), multiplier);
	}

	/// @inheritdoc IPoints
	function getStamps() public view override returns (StampInfo[] memory) {
		return _stamps;
	}

	/// @dev Returns the stamp views for a given user
	/// @param user The address of the user
	/// @return An array of stamp views
	function _getPointsStampViews(address user) internal view returns (PointsStamp[] memory) {
		PointsStamp[] memory stamps = new PointsStamp[](_stamps.length);
		for (uint256 i; i < _stamps.length; ) {
			stamps[i] = PointsStamp({ stamp: _stamps[i].stamp.getStampView(user), multiplier: _stamps[i].multiplier });
			unchecked {
				++i;
			}
		}
		return stamps;
	}
}
