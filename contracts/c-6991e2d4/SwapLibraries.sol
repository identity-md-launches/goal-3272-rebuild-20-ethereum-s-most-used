// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;
pragma abicoder v2;

interface IBotTokenSelectors {
    function approve(address spender, uint256 value) external;
    function transfer(address recipient, uint256 value) external;
}

library BotTokenCalls {
    function safeApprove(address token, address spender, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(IBotTokenSelectors.approve.selector, spender, value));
    }

    function safeTransfer(address token, address recipient, uint256 value) internal {
        callOptionalReturn(token, abi.encodeWithSelector(IBotTokenSelectors.transfer.selector, recipient, value));
    }

    function callOptionalReturn(address token, bytes memory data) private {
        // Preserve the original call pattern: returned token bytes are not decoded.
        (bool success, bytes memory result) = token.call(data);
        require(success, "SafeERC20: low-level call failed");
    }
}

library BotSafeCast {
    function toInt256(uint256 value) internal pure returns (int256 result) {
        require(value < 2 ** 255);
        result = int256(value);
    }
}

