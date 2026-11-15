// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";
import "./Interfaces.sol";

abstract contract Callbacks is StrategyStorage {
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        _swapCallback(swapState, amount0Delta, amount1Delta, data);
    }

    function pancakeV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        _swapCallback(swapState, amount0Delta, amount1Delta, data);
    }

    function _swapCallback(SwapState storage state, int256 amount0Delta, int256 amount1Delta, bytes calldata data) internal {
        require(msg.sender == state.pool, "wtf");
        state.pool = address(this);
        (address token, bool zeroForOne) = abi.decode(data, (address, bool));
        if (zeroForOne) {
            require(amount0Delta <= int256(state.amount), "o");
            state.amount = 0;
            IStrategyToken tokenContract = IStrategyToken(token);
            tokenContract.transfer(msg.sender, uint256(amount0Delta));
        } else {
            require(amount1Delta <= int256(state.amount), "o");
            state.amount = 0;
            IStrategyToken tokenContract = IStrategyToken(token);
            tokenContract.transfer(msg.sender, uint256(amount1Delta));
        }
    }
}
