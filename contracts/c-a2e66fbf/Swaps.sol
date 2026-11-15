// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";
import "./Interfaces.sol";

abstract contract Swaps is StrategyStorage {
    address internal constant BALANCER_VAULT = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;

    function swapBalancerV2_63j4UQ(bytes32 poolId, address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) external payable correctBlock onlyTrader(address(bytes20(poolId))) {
        _swapBalancerVault(poolId, tokenIn, tokenOut, amountIn, minAmountOut);
    }

    function _swapBalancerVault(bytes32 poolId, address tokenIn, address tokenOut, uint256 amountIn, uint256 minAmountOut) internal {
        IStrategyToken(tokenIn).approve(BALANCER_VAULT, amountIn + 1);
        IStrategyBalancerVault(BALANCER_VAULT).swap(
            IStrategyBalancerVault.SingleSwap({
                poolId: poolId,
                kind: IStrategyBalancerVault.SwapKind.GIVEN_IN,
                assetIn: IStrategyAsset(tokenIn),
                assetOut: IStrategyAsset(tokenOut),
                amount: amountIn,
                userData: ""
            }),
            IStrategyBalancerVault.FundManagement({
                sender: address(this),
                fromInternalBalance: false,
                recipient: payable(address(this)),
                toInternalBalance: false
            }),
            minAmountOut,
            block.timestamp
        );
    }

    function imd_00000000b519b5ed(address pair, bool oneForZero, uint256 amountIn, uint256 minAmountOut, address tokenIn) external payable correctBlock onlyTrader(pair) {
        _swapV2(pair, oneForZero, amountIn, minAmountOut, tokenIn);
    }

    function _swapV2(address pair, bool oneForZero, uint256 amountIn, uint256 minAmountOut, address tokenIn) internal {
        uint256 amountOut;
        IStrategyV2Pair p = IStrategyV2Pair(pair);
        (uint112 reserve0, uint112 reserve1,) = p.getReserves();
        if (oneForZero) {
            amountOut = _getAmountOut(amountIn, reserve1, reserve0);
        } else {
            amountOut = _getAmountOut(amountIn, reserve0, reserve1);
        }
        require(amountOut >= minAmountOut, "n");
        IStrategyToken token = IStrategyToken(tokenIn);
        token.transfer(pair, amountIn);
        if (oneForZero) {
            p.swap(amountOut, 0, address(this), bytes(""));
        } else {
            p.swap(0, amountOut, address(this), bytes(""));
        }
    }

    function swapV3b_2lJInn(address pool, bool zeroForOne, int256 amountSpecified, uint256 minAmountOut, address tokenIn) external payable correctBlock onlyTrader(pool) {
        _swapV3(swapState, pool, zeroForOne, amountSpecified, minAmountOut, tokenIn);
    }

    function _swapV3(SwapState storage state, address pool, bool zeroForOne, int256 amountSpecified, uint256 minAmountOut, address tokenIn) internal {
        state.pool = pool;
        state.amount = uint256(amountSpecified);
        IStrategyV3Pool p = IStrategyV3Pool(pool);
        (int256 amount0, int256 amount1) = p.swap(
            address(this), zeroForOne, amountSpecified,
            zeroForOne ? uint160(4295128740) : uint160(1461446703485210103287273052203988822378723970341),
            abi.encode(tokenIn, zeroForOne)
        );
        require(state.pool == address(this), "x");
        require(state.amount == 0, "y");
        if (zeroForOne) {
            require(-amount1 >= int256(minAmountOut), "m");
        } else {
            require(-amount0 >= int256(minAmountOut), "M");
        }
    }

    function swapBalancerV1_FQbkQe(address pool, address tokenIn, uint256 amountIn, address tokenOut, uint256 minAmountOut) external payable correctBlock onlyTrader(pool) {
        _swapBalancer(pool, tokenIn, amountIn, tokenOut, minAmountOut);
    }

    function _swapBalancer(address pool, address tokenIn, uint256 amountIn, address tokenOut, uint256 minAmountOut) internal {
        IStrategyToken(tokenIn).approve(pool, amountIn + 1);
        IStrategyBalancerPool(pool).swapExactAmountIn(tokenIn, amountIn, tokenOut, minAmountOut, type(uint256).max);
    }
}
