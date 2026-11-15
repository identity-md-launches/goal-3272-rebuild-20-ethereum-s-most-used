// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Roles.sol";
import "./Admin.sol";
import "./Swaps.sol";
import "./Arbitrage.sol";
import "./Callbacks.sol";
import "./UnknownSelectors.sol";

contract StrategyExecutor is Roles, Admin, Swaps, Arbitrage, Callbacks, UnknownSelectors {
    constructor() {
        owner = msg.sender;
        swapState.pool = address(this);
    }

    receive() external payable {}
}
