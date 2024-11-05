// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IPoints, IERC20Metadata, IERC20 } from "./interfaces/IPoints.sol";
import { IPointsView } from "./interfaces/IPointsView.sol";
import { PlasaContext } from "../plasa/PlasaContext.sol";
import { Math } from "@openzeppelin/contracts/utils/math/Math.sol";

/// @title Points - A non-transferable ERC20-like token contract
/// @notice This contract implements a non-transferable token system
/// @dev This is an abstract contract that needs to be inherited and implemented
abstract contract Points is IPoints, PlasaContext {
	using Math for uint256;

	string private _name;
	string private _symbol;
	uint8 private _decimals;

	/// @notice Initializes the contract with a name, symbol, and decimals
	/// @param tokenName The name of the token
	/// @param tokenSymbol The symbol of the token
	/// @param tokenDecimals The number of decimals for the token
	constructor(
		string memory tokenName,
		string memory tokenSymbol,
		uint8 tokenDecimals,
		address _plasaContract
	) PlasaContext(_plasaContract) {
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

	/// @inheritdoc IPointsView
	function getPointsView(address user) public view virtual override returns (PointsView memory) {
		return
			PointsView({
				data: PointsData({
					contractAddress: address(this),
					name: name(),
					symbol: symbol(),
					totalSupply: totalSupply(),
					top10Holders: getTopHolders(0, 10)
				}),
				user: PointsUser({ currentBalance: balanceOf(user) })
			});
	}

	/// @inheritdoc IPoints
	function getTopHolders(uint256 start, uint256 end) public view override(IPoints) returns (HolderData[] memory) {
		if (start >= end) revert IndexOutOfBounds();

		uint256 maxSize = _getTotalUniqueHolders();
		if (maxSize == 0) return new HolderData[](0);

		// Only allocate memory for the requested range
		uint256 requestedSize = end - start;
		Holder[] memory topHolders = new Holder[](requestedSize);
		uint256 actualSize = _collectTopHolders(topHolders, start, end);

		if (actualSize == 0) return new HolderData[](0);

		return _addUsernames(topHolders);
	}

	/// @notice Returns the total number of unique holders
	/// @return The total number of unique holders
	function _getTotalUniqueHolders() internal view virtual returns (uint256);

	/// @dev Helper function to collect holders and their balances
	function _collectHolders(Holder[] memory holders) internal view virtual returns (uint256 totalHolders);

	/// @dev Helper function to paginate and sort holders
	function _paginateAndSortHolders(
		Holder[] memory holders,
		uint256 totalHolders,
		uint256 start,
		uint256 end
	) private pure returns (Holder[] memory) {
		// Validate pagination
		if (start >= totalHolders) return new Holder[](0);
		end = Math.min(end, totalHolders);
		uint256 length = end - start;

		// Sort only the actual holders (not the entire array)
		_insertionSort(holders, totalHolders);

		// Return paginated result
		Holder[] memory result = new Holder[](length);
		for (uint256 i; i < length; ) {
			result[i] = holders[start + i];
			unchecked {
				++i;
			}
		}
		return result;
	}

	/// @dev Insertion sort implementation optimized for small arrays
	function _insertionSort(Holder[] memory arr, uint256 length) private pure {
		for (uint256 i = 1; i < length; ) {
			uint256 j = i;
			while (j > 0 && arr[j - 1].balance < arr[j].balance) {
				(arr[j], arr[j - 1]) = (arr[j - 1], arr[j]);
				unchecked {
					--j;
				}
			}
			unchecked {
				++i;
			}
		}
	}

	/// @dev Helper function to add usernames to holder data
	function _addUsernames(Holder[] memory holders) internal view virtual returns (HolderData[] memory) {
		HolderData[] memory holderData = new HolderData[](holders.length);
		for (uint256 i; i < holders.length; ) {
			holderData[i] = HolderData({
				user: holders[i].user,
				name: _getUsername(holders[i].user),
				balance: holders[i].balance
			});
			unchecked {
				++i;
			}
		}
		return holderData;
	}

	// New optimized collection function
	function _collectTopHolders(Holder[] memory holders, uint256 start, uint256 end) internal view returns (uint256) {
		// Get total holders
		uint256 totalHolders = _collectHolders(holders);
		if (totalHolders == 0) return 0;

		// Sort holders by balance
		_quickSort(holders, 0, totalHolders - 1);

		// Return only the requested range
		uint256 actualEnd = Math.min(end, totalHolders);
		uint256 length = actualEnd - start;

		// Shift the array to start from 0
		if (start > 0 && start < totalHolders) {
			for (uint256 i = 0; i < length; ) {
				holders[i] = holders[i + start];
				unchecked {
					++i;
				}
			}
		}

		return length;
	}

	// Replace insertion sort with quicksort for better performance
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
}
