// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.24;

import "./Storage.sol";
import "./Interfaces.sol";

abstract contract Admin is StrategyStorage {
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function addToken_8zSNM7(address token) external onlyOwner {
        _addToken(token);
    }

    function wrap_62lZAo() external payable {
        IStrategyWETH(WETH).deposit{value: msg.value}();
    }

    function wrapETH_8tbLBk(uint256 amount) external {
        require(imd_0000000006aa7afa[msg.sender], ";");
        IStrategyWETH(WETH).deposit{value: amount}();
    }

    function withdraw() external onlyOwner {
        (bool ok,) = payable(owner).call{value: address(this).balance}("");
        require(ok, "f");
    }

    function withdrawETH_94X0gZ(address recipient, uint256 amount) external onlyRebalancerRecipient(recipient) {
        IStrategyWETH(WETH).withdraw(amount);
        (bool ok,) = payable(recipient).call{value: amount}("");
        require(ok, "f");
    }

    function withdrawToken_61riqI(address recipient, address token, uint256 amount) external onlyRebalancerRecipient(recipient) {
        IStrategyToken(token).transfer(recipient, amount);
    }

    function fundTraders(address[] calldata accounts, uint256[] calldata amounts) external onlyOwner {
        require(accounts.length == amounts.length);
        uint256 total;
        for (uint256 i; i < amounts.length; ++i) total += amounts[i];
        IStrategyWETH(WETH).withdraw(total);
        for (uint256 i; i < amounts.length; ++i) {
            (bool ok,) = payable(accounts[i]).call{value: amounts[i]}("");
            require(ok, "f");
        }
    }
}
