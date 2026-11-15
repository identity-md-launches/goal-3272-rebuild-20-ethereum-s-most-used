// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
}
interface IWETH is IERC20 {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
}
interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}
interface IUniswapV3Pool {
    function fee() external view returns (uint24);
    function swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data) external returns (int256 amount0, int256 amount1);
}
library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) { require((z = x + y) >= x, 'ds-math-add-overflow'); }
    function sub(uint x, uint y) internal pure returns (uint z) { require((z = x - y) <= x, 'ds-math-sub-underflow'); }
    function mul(uint x, uint y) internal pure returns (uint z) { require(y == 0 || (z = x * y) / y == x, 'ds-math-mul-overflow'); }
}
library TransferHelper {
    function safeTransfer(address token, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }
    function safeTransferFrom(address token, address from, address to, uint value) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }
    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}
library BytesLib {
    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        require(_start + 20 >= _start, 'toAddress_overflow');
        require(_bytes.length >= _start + 20, 'toAddress_outOfBounds');
        address tempAddress;
        assembly { tempAddress := div(mload(add(add(_bytes, 0x20), _start)), 0x1000000000000000000000000) }
        return tempAddress;
    }
    function toUint24(bytes memory _bytes, uint256 _start) internal pure returns (uint24) {
        require(_start + 3 >= _start, 'toUint24_overflow');
        require(_bytes.length >= _start + 3, 'toUint24_outOfBounds');
        uint24 tempUint;
        assembly { tempUint := mload(add(add(_bytes, 0x3), _start)) }
        return tempUint;
    }
}
library Path {
    using BytesLib for bytes;
    uint256 private constant ADDR_SIZE = 20;
    uint256 private constant FEE_SIZE = 3;
    function decodeFirstPool(bytes memory path) internal pure returns (address tokenA, address tokenB, uint24 fee) {
        tokenA = path.toAddress(0);
        fee = path.toUint24(ADDR_SIZE);
        tokenB = path.toAddress(ADDR_SIZE + FEE_SIZE);
    }
}
library PoolAddress {
    struct PoolKey { address token0; address token1; uint24 fee; }
    function getPoolKey(address tokenA, address tokenB, uint24 fee) internal pure returns (PoolKey memory) {
        if (tokenA > tokenB) (tokenA, tokenB) = (tokenB, tokenA);
        return PoolKey({token0: tokenA, token1: tokenB, fee: fee});
    }
    function initCodeHash(uint256 chainId) internal pure returns (bytes32) {
        if (chainId == 1) return 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
        if (chainId == 56) return 0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2;
        if (chainId == 42161) return 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
        if (chainId == 81457) return 0xd0c3a51b16dbc778f000c620eaabeecd33b33a80bd145e1f7cbc0d4de335193d;
        return 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
    }
    function computeAddress(address factory, PoolKey memory key) internal view returns (address pool) {
        require(key.token0 < key.token1);
        pool = address(uint160(uint256(keccak256(abi.encodePacked(hex'ff', factory, keccak256(abi.encode(key.token0, key.token1, key.fee)), initCodeHash(block.chainid))))));
    }
}
library CallbackValidation {
    function verifyCallback(address factory, address tokenA, address tokenB, uint24 fee) internal view returns (IUniswapV3Pool pool) {
        return verifyCallback(factory, PoolAddress.getPoolKey(tokenA, tokenB, fee));
    }
    function verifyCallback(address factory, PoolAddress.PoolKey memory poolKey) internal view returns (IUniswapV3Pool pool) {
        pool = IUniswapV3Pool(PoolAddress.computeAddress(factory, poolKey));
        require(msg.sender == address(pool));
    }
}
library UniswapV2Library {
    using SafeMath for uint;
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }
}
contract StrategyExecutor {
    using SafeMath for uint;
    using Path for bytes;
    address public owner;
    address private WETH;
    address private factory;
    struct SwapCallbackData { bytes path; address payer; }
    constructor() {
        owner = msg.sender;
        if (block.chainid == 1) {
            WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
            factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        }
        if (block.chainid == 56) {
            WETH = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
            factory = 0x41ff9AA7e16B8B1a8a8dc4f0eFacd93D02d071c9;
        }
        if (block.chainid == 42161) {
            WETH = 0x82aF49447D8a07e3bd95BD0d56f35241523fBab1;
            factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
        }
        if (block.chainid == 81457) {
            WETH = 0x4300000000000000000000000000000000000004;
            factory = 0xa08ae3d3f4dA51C22d3c041E468bdF4C61405AaB;
        }
    }
    modifier onlyOwner() { require(msg.sender == owner); _; }
    modifier ensure(uint deadline) { require(deadline >= block.timestamp, 'BXRouter: EXPIRED'); _; }
    receive() external payable {}
    fallback() external payable {}
    function recoverETH() external onlyOwner { payable(owner).transfer(address(this).balance); }
    function recoverTokens(address token) external onlyOwner {
        uint balance = IERC20(token).balanceOf(address(this));
        IERC20(token).transfer(owner, balance);
    }
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        require(amount0Delta > 0 || amount1Delta > 0);
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);
        (bool isExactInput, uint256 amountToPay) = amount0Delta > 0 ? (tokenIn < tokenOut, uint256(amount0Delta)) : (tokenOut < tokenIn, uint256(amount1Delta));
        require(isExactInput, 'BXRouter: EXACT_INPUT');
        pay(tokenIn, data.payer, msg.sender, amountToPay);
    }
    function pancakeV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata _data) external {
        require(amount0Delta > 0 || amount1Delta > 0);
        SwapCallbackData memory data = abi.decode(_data, (SwapCallbackData));
        (address tokenIn, address tokenOut, uint24 fee) = data.path.decodeFirstPool();
        CallbackValidation.verifyCallback(factory, tokenIn, tokenOut, fee);
        (bool isExactInput, uint256 amountToPay) = amount0Delta > 0 ? (tokenIn < tokenOut, uint256(amount0Delta)) : (tokenOut < tokenIn, uint256(amount1Delta));
        require(isExactInput, 'BXRouter: EXACT_INPUT');
        pay(tokenIn, data.payer, msg.sender, amountToPay);
    }
    function buyUniswapV3(address token, address pair, uint amountOutMin, uint deadline) external payable ensure(deadline) {
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        uint balanceBefore = IERC20(token).balanceOf(msg.sender);
        swapV3(WETH, token, pair, amountIn, msg.sender, WETH < token);
        require(IERC20(token).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin, 'BXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    }
    function sellUniswapV2(address token, address pair, uint amountOutMin, uint deadline, uint amountIn) external ensure(deadline) {
        uint balanceBefore = IERC20(WETH).balanceOf(address(this));
        TransferHelper.safeTransferFrom(token, msg.sender, pair, amountIn);
        swapV2(token, WETH, pair, address(this));
        uint balanceAfter = IERC20(WETH).balanceOf(address(this));
        uint amountOut = balanceAfter - balanceBefore;
        require(amountOut >= amountOutMin, 'BXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(msg.sender, amountOut);
    }
    function sellUniswapV3(address token, address pair, uint amountOutMin, uint deadline, uint amountIn) external ensure(deadline) {
        uint balanceBefore = IERC20(WETH).balanceOf(address(this));
        TransferHelper.safeTransferFrom(token, msg.sender, address(this), amountIn);
        swapV3(token, WETH, pair, amountIn, address(this), token < WETH);
        uint balanceAfter = IERC20(WETH).balanceOf(address(this));
        uint amountOut = balanceAfter - balanceBefore;
        require(amountOut >= amountOutMin, 'BXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
        IWETH(WETH).withdraw(amountOut);
        TransferHelper.safeTransferETH(msg.sender, amountOut);
    }
    function buyUniswapV2(address token, address pair, uint amountOutMin, uint deadline) external payable ensure(deadline) {
        uint amountIn = msg.value;
        IWETH(WETH).deposit{value: amountIn}();
        assert(IWETH(WETH).transfer(pair, amountIn));
        uint balanceBefore = IERC20(token).balanceOf(msg.sender);
        swapV2(WETH, token, pair, msg.sender);
        require(IERC20(token).balanceOf(msg.sender).sub(balanceBefore) >= amountOutMin, 'BXRouter: INSUFFICIENT_OUTPUT_AMOUNT');
    }
    function pay(address token, address payer, address recipient, uint value) internal {
        require(payer == address(this), 'BXRouter: Payer not allowed');
        TransferHelper.safeTransfer(token, recipient, value);
    }
    function swapV3(address tokenIn, address tokenOut, address pair, uint amountIn, address recipient, bool zeroForOne) internal {
        IUniswapV3Pool pool = IUniswapV3Pool(pair);
        uint24 fee = pool.fee();
        bytes memory encodedData = abi.encode(SwapCallbackData({path: abi.encodePacked(tokenIn, fee, tokenOut), payer: address(this)}));
        pool.swap(recipient, zeroForOne, int256(amountIn), zeroForOne ? uint160(4295128739) + 1 : uint160(1461446703485210103287273052203988822378723970342) - 1, encodedData);
    }
    function swapV2(address input, address output, address pair, address to) internal {
        (address token0,) = UniswapV2Library.sortTokens(input, output);
        IUniswapV2Pair pool = IUniswapV2Pair(pair);
        uint amountInput;
        uint amountOutput;
        {
            (uint reserve0, uint reserve1,) = pool.getReserves();
            (uint reserveInput, uint reserveOutput) = input == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
            amountInput = IERC20(input).balanceOf(address(pool)).sub(reserveInput);
            amountOutput = UniswapV2Library.getAmountOut(amountInput, reserveInput, reserveOutput);
        }
        (uint amount0Out, uint amount1Out) = input == token0 ? (uint(0), amountOutput) : (amountOutput, uint(0));
        pool.swap(amount0Out, amount1Out, to, new bytes(0));
    }
}
