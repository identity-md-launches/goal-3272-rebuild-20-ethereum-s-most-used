// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.7.6;

// The packed path readers used by Uniswap v3-periphery BytesLib.
library BotBytes {
    function toAddress(bytes memory data, uint256 start) internal pure returns (address) {
        require(start + 20 >= start, "toAddress_overflow");
        require(data.length >= start + 20, "toAddress_outOfBounds");
        address result;
        assembly {
            result := div(mload(add(add(data, 0x20), start)), 0x1000000000000000000000000)
        }
        return result;
    }

    function toUint24(bytes memory data, uint256 start) internal pure returns (uint24) {
        require(start + 3 >= start, "toUint24_overflow");
        require(data.length >= start + 3, "toUint24_outOfBounds");
        uint24 result;
        assembly {
            result := mload(add(add(data, 0x3), start))
        }
        return result;
    }
}

