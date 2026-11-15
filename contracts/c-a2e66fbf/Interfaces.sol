// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

interface IStrategyToken {
    function approve(address spender, uint256 amount) external;
    function transfer(address recipient, uint256 amount) external;
}

interface IStrategyWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface IStrategyV3Pool {
    function swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data) external returns (int256 amount0, int256 amount1);
}

interface IStrategyBalancerPool {
    function swapExactAmountIn(address tokenIn, uint256 amountIn, address tokenOut, uint256 minAmountOut, uint256 maxPrice) external;
}

interface IStrategyV2Pair {
    function kLast() external view returns (uint256);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 timestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

interface IStrategyAsset {}

interface IStrategyBalancerVault {
    enum SwapKind { GIVEN_IN, GIVEN_OUT }

    struct SingleSwap {
        bytes32 poolId;
        SwapKind kind;
        IStrategyAsset assetIn;
        IStrategyAsset assetOut;
        uint256 amount;
        bytes userData;
    }

    struct FundManagement {
        address sender;
        bool fromInternalBalance;
        address payable recipient;
        bool toInternalBalance;
    }

    function swap(SingleSwap memory singleSwap, FundManagement memory funds, uint256 limit, uint256 deadline) external payable returns (uint256);
}
