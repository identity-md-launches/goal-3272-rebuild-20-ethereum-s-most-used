// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "./token/ERC20/utils/SafeERC20.sol";
import "./RouteCodec.sol";
import "./Interfaces.sol";

/// @notice Executes packed V2/V3 routes for authorized operators.
/// @dev Suffixed names preserve deployed selectors whose original names were not recovered.
contract StrategyExecutor {
    using SafeERC20 for IERC20;

    address public owner;
    mapping(address => bool) private _operators;

    constructor() {
        owner = msg.sender;
        _operators[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Permission denied");
        _;
    }

    modifier onlyOperator() {
        require(_operators[msg.sender], "Not operator");
        _;
    }

    receive() external payable {}

    /// @notice Whether an address may execute routes and manage funds.
    function operatorStatus_aadf64ba(address account) external view returns (bool) {
        return _operators[account];
    }

    /// @notice Authorizes each account (selector 0x13e1a988).
    function configureOperators_3063333c(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            _operators[account] = true;
        }
    }

    /// @notice Revokes each account (selector 0xb44f4a40).
    function setOperators_bdf2ad1a(address[] calldata accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            address account = accounts[i];
            _operators[account] = false;
        }
    }

    function withdrawEth(address payable receiver) external onlyOperator {
        uint256 balance = address(this).balance;
        receiver.transfer(balance);
    }

    function withdrawToken(address token, address receiver) external onlyOperator {
        uint256 balance = IERC20(token).balanceOf(address(this));
        IERC20(token).safeTransfer(receiver, balance);
    }

    function approveToken(address spender, address token, uint256 amount) external payable onlyOperator {
        IERC20(token).safeApprove(spender, amount);
    }

    function approveTokens(address spender, address[] memory tokens, uint256 amount) external payable onlyOperator {
        for (uint256 i = 0; i < tokens.length; i++) {
            IERC20(tokens[i]).safeApprove(spender, amount);
        }
    }

    /// @notice Executes an encrypted packed route (selector 0x6ac56d4e).
    function executeStrategy_13810034(uint256 nonce, bytes memory encrypted) external onlyOperator {
        (
            RouteCodec.Dex[] memory dexes,
            RouteCodec.Checks memory checks,
            address receiver,
            uint256 amountIn,
            uint256 minOut
        ) = RouteCodec.decode(encrypted, nonce);
        require(checks.deadline >= block.timestamp, "deadline");
        RouteCodec.Dex memory last = dexes[dexes.length - 1];
        if (!last.isV2 && checks.sqrtPrice > 0) {
            require(checks.pool != address(0), "V3Pool Address 0");
            (uint160 sqrtPrice,,,,,,) = IV3Pool(checks.pool).slot0();
            if (checks.sqrtPriceCmpMustGreater) {
                require(checks.sqrtPrice >= sqrtPrice, "V3PriceCheck");
            } else {
                require(checks.sqrtPrice <= sqrtPrice, "V3PriceCheck");
            }
        }
        if (dexes.length == 1) {
            if (last.isV2) {
                if (checks.taxBps > 0) {
                    uint256[] memory amounts =
                        IV2Router(last.router).getAmountsOut(amountIn, RouteCodec.decodeV2Path(last.path));
                    require(amounts[amounts.length - 1] * checks.taxBps >= minOut * 10000, "SafeMoonPreCheckAmount");
                }
            }
        } else {
            require(dexes.length == 2, "Max 2 Dex");
            if (dexes[0].isV2 && dexes[1].isV2) {
                uint256[] memory amounts0 =
                    IV2Router(dexes[0].router).getAmountsOut(amountIn, RouteCodec.decodeV2Path(dexes[0].path));
                uint256[] memory amounts1 = IV2Router(dexes[1].router)
                    .getAmountsOut(amounts0[amounts0.length - 1], RouteCodec.decodeV2Path(dexes[1].path));
                if (checks.taxBps > 0) {
                    require(amounts1[amounts1.length - 1] * checks.taxBps >= minOut * 10000, "SafeMoonPreCheckAmount");
                } else {
                    require(amounts1[amounts1.length - 1] >= minOut, "InsufficientOutAmount");
                }
            } else if (checks.preCheckAmount > 0 && dexes[1].isV2) {
                uint256[] memory amounts = IV2Router(dexes[1].router)
                    .getAmountsOut(checks.preCheckAmount, RouteCodec.decodeV2Path(dexes[1].path));
                if (checks.taxBps > 0) {
                    require(amounts[amounts.length - 1] * checks.taxBps >= minOut * 10000, "SafeMoonPreCheckAmount");
                } else {
                    require(amounts[amounts.length - 1] >= minOut, "InsufficientOutAmount");
                }
            }
        }
        uint256 currentAmount = amountIn;
        for (uint256 i = 0; i < dexes.length; i++) {
            address recipient = i < dexes.length - 1 ? address(this) : receiver;
            uint256 amountOutMin = i < dexes.length - 1 ? 1 : minOut;
            if (dexes[i].isV2) {
                if (i == dexes.length - 1 && checks.taxBps > 0) {
                    IV2Router(dexes[i].router)
                        .swapExactTokensForTokensSupportingFeeOnTransferTokens(
                            currentAmount,
                            amountOutMin,
                            RouteCodec.decodeV2Path(dexes[i].path),
                            recipient,
                            checks.deadline
                        );
                } else {
                    uint256[] memory amounts = IV2Router(dexes[i].router)
                        .swapExactTokensForTokens(
                            currentAmount,
                            amountOutMin,
                            RouteCodec.decodeV2Path(dexes[i].path),
                            recipient,
                            checks.deadline
                        );
                    currentAmount = amounts[amounts.length - 1];
                }
            } else {
                IV3Router.ExactInputParams memory params =
                    IV3Router.ExactInputParams(dexes[i].path, recipient, checks.deadline, currentAmount, amountOutMin);
                currentAmount = IV3Router(dexes[i].router).exactInput(params);
            }
        }
    }
}
