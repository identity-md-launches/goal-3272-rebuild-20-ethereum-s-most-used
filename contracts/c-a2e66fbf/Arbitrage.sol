// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";
import "./Interfaces.sol";

abstract contract Arbitrage is StrategyStorage {
    function arbV2b_0y21qv(
        address pair,
        bool oneForZero,
        uint256 amountIn,
        uint256 maxReserveIn,
        address tokenIn,
        uint256 gasCost,
        uint256 priceIn,
        uint256 priceOut,
        uint256 bribeBps,
        uint256 kLast,
        address coinbase
    ) external payable correctBlock onlyTrader(pair) {
        require(block.coinbase == coinbase, "C");
        require(int256(gasCost) > 0, "G");
        require(bribeBps < 10000, "B");
        (uint256 spent, uint256 received) = _arbV2Swap(pair, oneForZero, amountIn, maxReserveIn, tokenIn, kLast);
        int256 gain = (int256(received) * int256(priceOut) - int256(spent) * int256(priceIn)) / int256(1 ether) - int256(gasCost);
        require(gain > 0, "L");
        uint256 bribe = uint256(gain) * bribeBps / 10000;
        if (bribe > address(this).balance) {
            (bool ok,) = payable(block.coinbase).call{value: address(this).balance}("");
            require(ok);
        } else {
            (bool ok,) = payable(block.coinbase).call{value: bribe}("");
            require(ok);
        }
    }

    function _arbV2Swap(
        address pair,
        bool oneForZero,
        uint256 amountIn,
        uint256 maxReserveIn,
        address tokenIn,
        uint256 kLast
    ) internal returns (uint256 spent, uint256 received) {
        IStrategyV2Pair p = IStrategyV2Pair(pair);
        require(kLast == p.kLast(), "k");
        (uint112 reserve0, uint112 reserve1,) = p.getReserves();
        if (oneForZero) {
            require(maxReserveIn > reserve1, "s");
            spent = (maxReserveIn - reserve1) * 1000 / 997;
            if (amountIn < spent) spent = amountIn;
            received = _getAmountOut(spent, reserve1, reserve0);
        } else {
            require(maxReserveIn > reserve0, "S");
            spent = (maxReserveIn - reserve0) * 1000 / 997;
            if (amountIn < spent) spent = amountIn;
            received = _getAmountOut(spent, reserve0, reserve1);
        }
        IStrategyToken token = IStrategyToken(tokenIn);
        token.transfer(pair, spent);
        if (oneForZero) {
            p.swap(received, 0, address(this), bytes(""));
        } else {
            p.swap(0, received, address(this), bytes(""));
        }
    }

    function arbV3b_0ye3FH(
        address pool,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        address tokenIn,
        uint256 gasCost,
        uint256 price0,
        uint256 price1,
        uint256 bribeBps,
        address coinbase
    ) external payable correctBlock onlyTrader(pool) {
        require(block.coinbase == coinbase, "C");
        require(int256(gasCost) > 0, "G");
        require(bribeBps < 10000, "B");
        (int256 amount0, int256 amount1) = _arbV3Swap(swapState, pool, zeroForOne, amountSpecified, sqrtPriceLimitX96, tokenIn);
        int256 gain = ((-amount0) * int256(price0) - amount1 * int256(price1)) / int256(1 ether) - int256(gasCost);
        require(gain > 0, "L");
        uint256 bribe = uint256(gain) * bribeBps / 10000;
        if (bribe > address(this).balance) {
            (bool ok,) = payable(block.coinbase).call{value: address(this).balance}("");
            require(ok);
        } else {
            (bool ok,) = payable(block.coinbase).call{value: bribe}("");
            require(ok);
        }
    }

    function _arbV3Swap(
        SwapState storage state,
        address pool,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        address tokenIn
    ) internal returns (int256 amount0, int256 amount1) {
        state.pool = pool;
        state.amount = uint256(amountSpecified);
        IStrategyV3Pool p = IStrategyV3Pool(pool);
        (amount0, amount1) = p.swap(
            address(this), zeroForOne, amountSpecified, sqrtPriceLimitX96, abi.encode(tokenIn, zeroForOne)
        );
        require(state.pool == address(this), "x");
        require(state.amount == 0, "y");
    }
}
