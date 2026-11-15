// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

/// @dev Packed route format recovered from the deployed executor.
library RouteCodec {
    struct Checks {
        uint256 deadline;
        uint256 taxBps;
        uint256 preCheckAmount;
        uint256 sqrtPrice;
        bool sqrtPriceCmpMustGreater;
        address pool;
    }

    struct Dex {
        address router;
        bool isV2;
        bytes path;
    }

    function decode(bytes memory encrypted, uint256 nonce)
        internal
        pure
        returns (Dex[] memory dexes, Checks memory checks, address receiver, uint256 amountIn, uint256 minOut)
    {
        (uint256 length, bytes memory data) = decrypt(encrypted, nonce);
        require(data.length >= length + 2, "invalid decode len");
        uint256 offset = 2;
        receiver = toAddress(data, offset);
        offset += 20;
        amountIn = toUint104(data, offset);
        offset += 13;
        minOut = toUint104(data, offset);
        offset += 13;
        checks.deadline = toUint32(data, offset);
        offset += 4;
        checks.taxBps = toUint16(data, offset);
        offset += 2;
        checks.preCheckAmount = toUint104(data, offset);
        offset += 13;
        checks.sqrtPrice = toUint160(data, offset);
        offset += 20;
        checks.pool = toAddress(data, offset);
        offset += 20;
        uint8 value = toUint8(data, offset);
        offset += 1;
        require(value == 1 || value == 2, "sqrtPriceCmpMustGreater");
        checks.sqrtPriceCmpMustGreater = value == 2;
        uint256 count = toUint8(data, offset);
        offset += 1;
        dexes = new Dex[](count);
        for (uint256 i = 0; i < count; i++) {
            dexes[i].router = toAddress(data, offset);
            offset += 20;
            value = toUint8(data, offset);
            offset += 1;
            require(value == 1 || value == 2, "isV2");
            dexes[i].isV2 = value == 2;
            value = toUint8(data, offset);
            offset += 1;
            dexes[i].path = slice(data, offset, value);
            offset += value;
        }
    }

    function decodeV2Path(bytes memory path) internal pure returns (address[] memory) {
        uint256 count = path.length / 20;
        require(count * 20 == path.length, "V2 Path Len Check");
        address[] memory addresses = new address[](count);
        for (uint256 i = 0; i < count; i++) {
            addresses[i] = toAddress(path, i * 20);
        }
        return addresses;
    }

    function decrypt(bytes memory encrypted, uint256 nonce) internal pure returns (uint256, bytes memory) {
        uint256 secret = 0xcafe1111cafe2222cafe3333cafe4444;
        bytes memory seed = abi.encodePacked(nonce ^ secret);
        bytes32 digest = keccak256(seed);
        uint256 key = uint256(digest);
        uint256 size = encrypted.length;
        bytes memory data = new bytes(size - 32);
        uint256 checksum;
        assembly { checksum := mload(add(encrypted, size)) }
        uint256 i = 32;
        while (i < size) {
            uint256 word;
            assembly {
                word := xor(mload(add(encrypted, i)), key)
                mstore(add(data, i), word)
            }
            checksum ^= word;
            i += 32;
        }
        require(checksum == 0, "CS");
        uint16 declaredLength = toUint16(data, 0);
        require(declaredLength + 2 <= encrypted.length, "LEN");
        return (declaredLength, data);
    }

    // These word readers deliberately have no individual bounds checks in the
    // original. The caller checks the declared packed length before decoding.
    function toAddress(bytes memory data, uint256 offset) internal pure returns (address value) {
        assembly { value := div(mload(add(add(data, offset), 32)), 0x1000000000000000000000000) }
        return value;
    }

    function toUint160(bytes memory data, uint256 offset) internal pure returns (uint160 value) {
        assembly { value := mload(add(add(data, offset), 20)) }
        return value;
    }

    function toUint104(bytes memory data, uint256 offset) internal pure returns (uint104 value) {
        assembly { value := mload(add(add(data, offset), 13)) }
        return value;
    }

    function toUint32(bytes memory data, uint256 offset) internal pure returns (uint32 value) {
        assembly { value := mload(add(add(data, offset), 4)) }
        return value;
    }

    function toUint16(bytes memory data, uint256 offset) internal pure returns (uint16 value) {
        assembly { value := mload(add(add(data, offset), 2)) }
        return value;
    }

    function toUint8(bytes memory data, uint256 offset) internal pure returns (uint8 value) {
        assembly { value := mload(add(add(data, 1), offset)) }
        return value;
    }

    function slice(bytes memory data, uint256 start, uint256 length) internal pure returns (bytes memory) {
        require(length + 31 >= length, "slice_overflow");
        require(start + length >= start, "slice_overflow");
        require(data.length >= start + length, "slice_outOfBounds");
        bytes memory result;
        assembly {
            switch iszero(length)
            case 0 {
                result := mload(0x40)
                let lengthmod := and(length, 31)
                let mc := add(add(result, lengthmod), mul(0x20, iszero(lengthmod)))
                let end := add(mc, length)
                for { let cc := add(add(add(data, lengthmod), mul(0x20, iszero(lengthmod))), start) } lt(mc, end) {
                    mc := add(mc, 0x20)
                    cc := add(cc, 0x20)
                } { mstore(mc, mload(cc)) }
                mstore(result, length)
                mstore(0x40, and(add(mc, 31), not(31)))
            }
            default {
                result := mload(0x40)
                mstore(result, 0)
                mstore(0x40, add(result, 0x20))
            }
        }
        return result;
    }
}
