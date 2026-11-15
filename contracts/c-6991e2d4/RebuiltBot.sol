// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma abicoder v2;

import "./SwapLibraries.sol";
import "./BotBytes.sol";
import "./BotPoolAddress.sol";

interface IERC20Bot {
    function balanceOf(address account) external returns (uint256);
}

interface IWETHBot {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}

interface IStableSwapBot {
    function exchange(uint256 i, uint256 j, uint256 amount, uint256 minimum) external;
}

interface IUniswapV2PairBot {
    function getReserves() external view returns (uint112, uint112, uint32);
    function swap(uint256 amount0, uint256 amount1, address recipient, bytes calldata data) external;
}

interface IUniswapV3PoolBot {
    function slot0() external view returns (uint160, int24, uint16, uint16, uint16, uint8, bool);
    function swap(address recipient, bool zeroForOne, int256 amount, uint160 limit, bytes calldata data)
        external
        returns (int256, int256);
}

/// @notice Rebuilt mainnet MEV executor at 0x000000000dfde7deaf24138722987c9a6991e2d4.
/// @dev Some identifiers include a computed hexadecimal suffix to preserve the
/// deployed function selectors.
contract RebuiltBot {
    using BotTokenCalls for address;
    using BotBytes for bytes;

    mapping(address => uint256) private whiteList;
    address payable private constant OWNER = 0xcD40532686B94aBc88b06B9705AAcBc14c8364D6;
    address private constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address private constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address private constant CURVE = 0xD51a44d3FaE010294C616388b506AcdA1bfAAE46;
    // Prices one unit inside Uniswap V3 TickMath bounds.
    uint160 private constant V3_MIN_PRICE_LIMIT = 4295128740;
    uint160 private constant V3_MAX_PRICE_LIMIT = 1461446703485210103287273052203988822378723970341;

    constructor() {
        address(0xdAC17F958D2ee523a2206206994597C13D831ec7).safeApprove(CURVE, uint256(-1));
        WETH.safeApprove(CURVE, uint256(-1));
        address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599).safeApprove(CURVE, uint256(-1));
    }

    modifier onlyOwner() {
        require(OWNER == msg.sender, "NOT_OWNER");
        _;
    }

    modifier onlyWhiteListed() {
        require(isWhiteListed(), "NOT_WHITE_LISTED");
        _;
    }

    receive() external payable {}

    function removeFromWhiteList(address account) external onlyOwner {
        whiteList[account] = 0;
    }

    function wrapETH(uint256 amount) external onlyWhiteListed {
        IWETHBot(WETH).deposit{value: amount}();
    }

    function withdraw(uint256 amount) external onlyWhiteListed {
        address payable wallet = OWNER;
        wallet.transfer(amount);
    }

    // Reduce the Curve order when the observed pool balance exceeds the expected balance.
    // Original selector 0x32698bd5.
    function exchangeWithBalanceCheck_00008b7e3e12(
        IStableSwapBot pool,
        uint256 i,
        uint256 j,
        uint256 amount,
        uint256 minimum,
        IERC20Bot balanceToken,
        uint256 expectedBalance
    ) external onlyWhiteListed {
        uint256 balance = IERC20Bot(balanceToken).balanceOf(address(pool));
        if (balance > expectedBalance) {
            uint256 difference = balance - expectedBalance;
            uint256 percent = difference * 100 / amount;
            if (percent <= 35) {
                amount = amount * 60 / 100;
                minimum = minimum * 60 / 100;
            } else {
                return;
            }
        }
        IStableSwapBot(pool).exchange(i, j, amount, minimum);
    }

    // V3 exact-input swap; msg.value encodes the last permitted block number.
    // Original selector 0x355ec152.
    function swapV3_0000c84072a8(bytes memory path, uint256 amount, uint256 minimum) external payable onlyWhiteListed {
        require(block.number <= msg.value, "EXPIRED");
        (address tokenIn, address tokenOut, uint24 fee) = decodeFirstPool(path);
        (int256 amount0, int256 amount1) = IUniswapV3PoolBot(getPool(tokenIn, tokenOut, fee))
            .swap(
                address(this),
                tokenIn < tokenOut,
                BotSafeCast.toInt256(amount),
                tokenIn < tokenOut ? V3_MIN_PRICE_LIMIT : V3_MAX_PRICE_LIMIT,
                path
            );
        require(uint256(-(tokenIn < tokenOut ? amount1 : amount0)) >= minimum, "Too little received");
    }

    // Withdraw tokens to the secondary wallet embedded in the deployed bytecode.
    // Original selector 0x5db3b4df.
    function withdrawTokenToSecondaryWallet_00009f8ac623(IERC20Bot token, uint256 amount) external onlyWhiteListed {
        address wallet = 0x410ed1cbceA3B3990A3f27362c06C3C5D1E75d08;
        address(token).safeTransfer(wallet, amount);
    }

    // V3 tick gate: msg.value == 1 selects tick > limit; otherwise select tick < limit.
    // Original selector 0x827b0425.
    function swapV3WithTickCheck_00018b45e954(bytes memory path, uint256 amount, uint256 minimum, int256 tickLimit)
        external
        payable
        onlyWhiteListed
    {
        (address tokenIn, address tokenOut, uint24 fee) = decodeFirstPool(path);
        address pool = getPool(tokenIn, tokenOut, fee);
        {
            (, int256 tick,,,,,) = IUniswapV3PoolBot(pool).slot0();
            if (msg.value == 1) {
                if (tick <= tickLimit) return;
            } else {
                if (tick >= tickLimit) return;
            }
        }
        (int256 amount0, int256 amount1) = IUniswapV3PoolBot(pool)
            .swap(
                address(this),
                tokenIn < tokenOut,
                BotSafeCast.toInt256(amount),
                tokenIn < tokenOut ? V3_MIN_PRICE_LIMIT : V3_MAX_PRICE_LIMIT,
                path
            );
        require(uint256(-(tokenIn < tokenOut ? amount1 : amount0)) >= minimum, "Too little received");
    }

    // Scale or skip the V3 order according to the input-token balance at the pool.
    // Original selector 0x83ec0022.
    function swapV3_00007136dd0c(bytes memory path, uint256 amount, uint256 minimum, uint256 expectedBalance)
        external
        onlyWhiteListed
    {
        (address tokenIn, address tokenOut, uint24 fee) = decodeFirstPool(path);
        address pool = getPool(tokenIn, tokenOut, fee);
        {
            uint256 balance = IERC20Bot(tokenIn).balanceOf(pool);
            if (balance > expectedBalance) {
                uint256 difference = balance - expectedBalance;
                uint256 percent = difference * 100 / amount;
                if (percent <= 35) {
                    amount = amount * 70 / 100;
                    minimum = minimum * 70 / 100;
                } else if (percent <= 50) {
                    amount = amount * 40 / 100;
                    minimum = minimum * 40 / 100;
                } else {
                    return;
                }
            }
        }
        (int256 amount0, int256 amount1) = IUniswapV3PoolBot(pool)
            .swap(
                address(this),
                tokenIn < tokenOut,
                BotSafeCast.toInt256(amount),
                tokenIn < tokenOut ? V3_MIN_PRICE_LIMIT : V3_MAX_PRICE_LIMIT,
                path
            );
        require(uint256(-(tokenIn < tokenOut ? amount1 : amount0)) >= minimum, "Too little received");
    }

    // Curve exchange with a block-number limit encoded in msg.value.
    // Original selector 0x8834aa42.
    function exchange_00008e5f836a(IStableSwapBot pool, uint256 i, uint256 j, uint256 amount, uint256 minimum)
        external
        payable
        onlyWhiteListed
    {
        require(block.number <= msg.value);
        IStableSwapBot(pool).exchange(i, j, amount, minimum);
    }

    // Curve exchange followed by an ETH payment to the block producer.
    // Original selector 0x95fd2b33.
    function exchangeWithMinerPayment_0001385de33f(
        IStableSwapBot pool,
        uint256 i,
        uint256 j,
        uint256 amount,
        uint256 minimum,
        uint256 minerPayment
    ) external payable onlyWhiteListed {
        require(block.number <= msg.value);
        IStableSwapBot(pool).exchange(i, j, amount, minimum);
        block.coinbase.transfer(minerPayment);
    }

    // V3 exact-input swap followed by an ETH payment to the block producer.
    // Original selector 0x9861a082.
    function swapV3_000108e1faeb(bytes memory path, uint256 amount, uint256 minimum, uint256 minerPayment)
        external
        payable
        onlyWhiteListed
    {
        require(block.number <= msg.value, "EXPIRED");
        (address tokenIn, address tokenOut, uint24 fee) = decodeFirstPool(path);
        (int256 amount0, int256 amount1) = IUniswapV3PoolBot(getPool(tokenIn, tokenOut, fee))
            .swap(
                address(this),
                tokenIn < tokenOut,
                BotSafeCast.toInt256(amount),
                tokenIn < tokenOut ? V3_MIN_PRICE_LIMIT : V3_MAX_PRICE_LIMIT,
                path
            );
        require(uint256(-(tokenIn < tokenOut ? amount1 : amount0)) >= minimum, "Too little received");
        block.coinbase.transfer(minerPayment);
    }

    function withdrawTokenToWallet(IERC20Bot token, uint256 amount) external onlyWhiteListed {
        address wallet = OWNER;
        address(token).safeTransfer(wallet, amount);
    }

    function addToWhiteListMultiple(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            whiteList[accounts[i]] = 1;
        }
    }

    // Grant the spender unlimited allowance for each token.
    // Original selector 0xb4beb923.
    function approveMultipleTokens_000041a69b3e(address[] memory tokens, address spender) external onlyWhiteListed {
        for (uint256 i = 0; i < tokens.length; i++) {
            address token = tokens[i];
            token.safeApprove(spender, uint256(-1));
        }
    }

    // Execute a delegate call and wrap its failure bytes in an Error(string).
    // Original selector 0xc18a84bc.
    function executeDelegateCall_000162399e39(address target, bytes memory data) external onlyWhiteListed {
        (bool success, bytes memory result) = target.delegatecall(data);
        require(success, string(result));
    }

    function unwrapETH(uint256 amount) external onlyWhiteListed {
        IWETHBot(WETH).withdraw(amount);
    }

    // V2 swap with exact output amounts and a block-number limit in msg.value.
    // Original selector 0xe0f6740b.
    function swapV2WithBlockCheck_00004154b943(
        IUniswapV2PairBot pair,
        address tokenIn,
        address tokenOut,
        uint256 amount,
        uint256 minimum
    ) external payable onlyWhiteListed {
        require(block.number <= msg.value);
        (address token0, address token1) = sortTokens(tokenIn, tokenOut);
        swapV2Exact(tokenOut, token0, token1, tokenIn, amount, address(pair), minimum);
    }

    function swap(IUniswapV2PairBot pair, address tokenIn, address tokenOut, uint256 amount, uint256 minimum)
        external
        onlyWhiteListed
    {
        (address token0, address token1) = sortTokens(tokenIn, tokenOut);
        swapV2Adjusted(tokenOut, token0, token1, tokenIn, amount, address(pair), minimum);
    }

    // V2 swap with exact output amounts followed by a block-producer payment.
    // Original selector 0xf8c0cbe8.
    function swapV2WithMinerPayment_00002124c753(
        IUniswapV2PairBot pair,
        address tokenIn,
        address tokenOut,
        uint256 amount,
        uint256 minimum,
        uint256 minerPayment
    ) external payable onlyWhiteListed {
        require(block.number <= msg.value);
        (address token0, address token1) = sortTokens(tokenIn, tokenOut);
        swapV2Exact(tokenOut, token0, token1, tokenIn, amount, address(pair), minimum);
        block.coinbase.transfer(minerPayment);
    }

    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        require(amount0Delta > 0 || amount1Delta > 0);
        (address tokenIn, address tokenOut, uint24 fee) = decodeFirstPool(data);
        verifyCallback(FACTORY, tokenIn, tokenOut, fee);
        (bool isExactInput, uint256 amountToPay) =
            amount0Delta > 0 ? (tokenIn < tokenOut, uint256(amount0Delta)) : (tokenOut < tokenIn, uint256(amount1Delta));
        if (isExactInput) {
            tokenIn.safeTransfer(msg.sender, amountToPay);
        } else {
            tokenIn = tokenOut;
            tokenIn.safeTransfer(msg.sender, amountToPay);
        }
    }

    function isWhiteListed() internal view returns (bool) {
        address account = msg.sender;
        if (whiteList[account] == 1) {
            return true;
        } else {
            return false;
        }
    }

    function decodeFirstPool(bytes memory path) internal pure returns (address tokenIn, address tokenOut, uint24 fee) {
        tokenIn = path.toAddress(0);
        fee = path.toUint24(20);
        tokenOut = path.toAddress(23);
    }

    function getPool(address tokenA, address tokenB, uint24 fee) internal pure returns (address) {
        return BotPoolAddress.computeAddress(FACTORY, BotPoolAddress.getPoolKey(tokenA, tokenB, fee));
    }

    function verifyCallback(address factory, address tokenA, address tokenB, uint24 fee)
        internal
        view
        returns (address pool)
    {
        BotPoolAddress.PoolKey memory key = BotPoolAddress.getPoolKey(tokenA, tokenB, fee);
        pool = BotPoolAddress.computeAddress(factory, key);
        require(msg.sender == pool, "NIGGA NO");
    }

    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, "UniswapV2Library: IDENTICAL_ADDRESSES");
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), "UniswapV2Library: ZERO_ADDRESS");
    }

    function swapV2Exact(
        address tokenOut,
        address token0,
        address token1,
        address tokenIn,
        uint256 amount,
        address pair,
        uint256 amountOut
    ) internal {
        uint256 amount0Out = tokenOut == token0 ? amountOut : uint256(0);
        uint256 amount1Out = tokenOut == token1 ? amountOut : uint256(0);
        tokenIn.safeTransfer(pair, amount);
        IUniswapV2PairBot(pair).swap(amount0Out, amount1Out, address(this), "");
    }

    function swapV2Adjusted(
        address tokenOut,
        address token0,
        address token1,
        address tokenIn,
        uint256 amount,
        address pair,
        uint256 minimum
    ) internal {
        uint256 reserveIn;
        uint256 reserveOut;
        {
            (uint256 reserve0, uint256 reserve1,) = IUniswapV2PairBot(pair).getReserves();
            reserveIn = tokenIn == token0 ? reserve0 : reserve1;
            reserveOut = tokenOut == token0 ? reserve0 : reserve1;
        }
        uint256 amountOut;
        uint256 originalAmount = amount;
        uint256 originalMinimum = minimum;
        for (uint256 i = 3; i >= 2; i--) {
            amount = originalAmount * i / 3;
            minimum = originalMinimum * i / 3;
            amountOut = getAmountOut(amount, reserveIn, reserveOut);
            if (amountOut >= minimum) break;
        }
        if (amountOut >= minimum) {
            uint256 amount0Out = tokenOut == token0 ? amountOut : uint256(0);
            uint256 amount1Out = tokenOut == token1 ? amountOut : uint256(0);
            tokenIn.safeTransfer(pair, amount);
            IUniswapV2PairBot(pair).swap(amount0Out, amount1Out, address(this), "");
        }
    }

    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        internal
        pure
        returns (uint256 amountOut)
    {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        amountOut = numerator / denominator;
    }
}
