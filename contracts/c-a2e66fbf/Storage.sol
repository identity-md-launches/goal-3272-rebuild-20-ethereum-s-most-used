// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;
import "./Interfaces.sol";

abstract contract StrategyStorage {
    address internal owner;                 // slot 0
    mapping(address => bool) public imd_000000008ccdb524;       // slot 1
    mapping(address => bool) public imd_0000000006aa7afa;      // slot 2
    mapping(address => bool) public imd_000000024e34972c;      // slot 3
    mapping(address => bool) public imd_0000000015096b66;      // slot 4
    struct SwapState {
        uint256 amount;
        address pool;
    }
    SwapState internal swapState;            // slots 5 and 6

    modifier onlyOwner() {
        require(msg.sender == owner, "!");
        _;
    }

    modifier correctBlock() {
        require(block.number == msg.value, "b");
        _;
    }

    modifier onlyTrader(address pool) {
        require(imd_000000008ccdb524[msg.sender], "?");
        require(imd_000000024e34972c[pool], "a");
        _;
    }

    modifier onlyRebalancerRecipient(address recipient) {
        require(imd_0000000006aa7afa[msg.sender], ";");
        require(imd_0000000015096b66[recipient], "t");
        _;
    }

    function _getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut) internal pure returns (uint256) {
        uint256 amountInWithFee = amountIn * 997;
        uint256 numerator = amountInWithFee * reserveOut;
        uint256 denominator = reserveIn * 1000 + amountInWithFee;
        return numerator / denominator;
    }

    function _addToken(address token) internal {
        IStrategyToken(token).approve(owner, type(uint256).max);
    }

    function _grantTrader(address account) internal {
        imd_000000008ccdb524[account] = true;
    }

    function _grantOperator(address account) internal {
        imd_000000024e34972c[account] = true;
    }

    function _grantRecipient(address account) internal {
        imd_0000000015096b66[account] = true;
    }

    function _grantRebalancer(address account) internal {
        imd_0000000006aa7afa[account] = true;
    }
}
