// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";

abstract contract Roles is StrategyStorage {
    function grantRebalancerRole(address account) external onlyOwner {
        _grantRebalancer(account);
    }

    function revokeRebalancerRole(address account) external onlyOwner {
        imd_0000000006aa7afa[account] = false;
    }

    function grantTraderRole(address account) external onlyOwner {
        _grantTrader(account);
    }

    function revokeTraderRole(address account) external onlyOwner {
        imd_000000008ccdb524[account] = false;
    }

    function grantRecipientRole_1rGXXA(address account) external onlyOwner {
        _grantRecipient(account);
    }

    function revokeRecipientRole_19Gx2g(address account) external onlyOwner {
        imd_0000000015096b66[account] = false;
    }
}
