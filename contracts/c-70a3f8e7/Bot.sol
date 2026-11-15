// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

/// @dev Cache for deployed delegatecall implementations.
interface Cache {
    function read(bytes memory code) external view returns (address);
    function write(bytes memory code) external returns (address);
}

/// @notice Authorized execution proxy with an authenticated Uniswap V3 payment callback.
contract Bot {
    // Factory address shifted into the CREATE2 preimage immediately after its prefix.
    bytes32 constant FACTORY = 0x1f98431c8ad98523631ae4a59f267346ea31f984000000000000000000000000;
    mapping(address => uint256) public wards;
    Cache public cache;

    modifier auth { require(wards[msg.sender] == 1); _; }

    constructor(address cache_) {
        wards[msg.sender] = 1;
        setCache(cache_);
    }

    function rely(address usr) external auth { wards[usr] = 1; }
    function deny(address usr) external auth { wards[usr] = 0; }
    function rely(address[] memory usrs) external auth {
        for (uint i = 0; i < usrs.length; i++) wards[usrs[i]] = 1;
    }
    function deny(address[] memory usrs) external auth {
        for (uint i = 0; i < usrs.length; i++) wards[usrs[i]] = 0;
    }

    function execute(bytes memory code, bytes memory data) public payable {
        address target = cache.read(code);
        if (target == address(0)) target = cache.write(code);
        execute(target, data);
    }

    function execute(address target, bytes memory data) public payable auth {
        assembly {
            let result := delegatecall(gas(), target, add(data, 0x20), mload(data), 0, 0)
            switch iszero(result)
            case 1 { revert(0, 0) }
        }
    }

    function exec_with_response(bytes memory code, bytes memory data) public payable returns (bytes memory response) {
        address target = cache.read(code);
        if (target == address(0)) target = cache.write(code);
        response = executeFFsYo(target, data);
    }

    function executeFFsYo(address target, bytes memory data) public payable auth returns (bytes memory response) {
        assembly {
            let result := delegatecall(gas(), target, add(data, 0x20), mload(data), 0, 0)
            let size := returndatasize()
            response := mload(0x40)
            mstore(0x40, add(response, and(add(add(size, 0x20), 0x1f), not(0x1f))))
            mstore(response, size)
            returndatacopy(add(response, 0x20), 0, size)
            switch iszero(result)
            case 1 { revert(add(response, 0x20), size) }
        }
    }

    function setCache(address cache_) public auth returns (bool) {
        require(cache_ != address(0), "ds-proxy-cache-address-required");
        cache = Cache(cache_);
        return true;
    }

    // Unknown selectors are accepted; the V3 callback selector authenticates its pool
    // against the factory, salt and pool init-code hash before paying the positive delta.
    fallback() external payable {
        assembly {
            function fail(code) {
                mstore(0, shl(224, 0x08c379a0))
                mstore(4, 32)
                mstore(36, 2)
                mstore(68, code)
                revert(0, 100)
            }
            let selector := shr(224, calldataload(0))
            if eq(selector, 0xfa461e33) {
                mstore8(0, 0xff)
                mstore(1, FACTORY)
                mstore(21, calldataload(132))
                mstore(53, 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54)
                let pool := keccak256(0, 85)
                pool := and(pool, 0xffffffffffffffffffffffffffffffffffffffff)
                if iszero(eq(pool, caller())) { fail("02") }
                let amount := calldataload(4)
                if iszero(sgt(amount, 0)) {
                    amount := calldataload(36)
                    if iszero(sgt(amount, 0)) { fail("01") }
                }
                mstore(0, 0x23b872dd00000000000000000000000000000000000000000000000000000000)
                mstore(4, calldataload(164))
                mstore(36, pool)
                // Release the scratch values after writing the transferFrom arguments.
                pool := 0
                mstore(68, amount)
                amount := 0
                if iszero(call(gas(), calldataload(196), 0, 0, 100, 0, 0)) { fail("03") }
            }
        }
    }
}
