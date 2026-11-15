// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";

abstract contract UnknownSelectors is StrategyStorage {
    // Alternate names preserve the selectors when the original names are unavailable.
    function imd_00000000423df052(address account) external onlyOwner {
        _grantOperator(account);
    }

    function imd_000000000f3f485f(address account) external onlyOwner {
        imd_000000024e34972c[account] = false;
    }

    function imd_000000014534d0e4(address[] calldata tokens, address[] calldata accounts, address[] calldata traders_) external onlyOwner {
        for (uint256 i; i < tokens.length; ++i) _addToken(tokens[i]);
        for (uint256 i; i < accounts.length; ++i) _grantOperator(accounts[i]);
        for (uint256 i; i < traders_.length; ++i) _grantTrader(traders_[i]);
    }
}
