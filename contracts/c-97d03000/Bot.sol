// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.7.6;

/// @notice Reconstruction of the packed-command execution contract.
/// @dev Assembly scopes and expression order preserve the original compiler output.
///      Caller addresses, token addresses, factories and pool hashes come from the deployed code.
contract Bot {
    receive() external payable {}

    fallback() external payable {
        assembly {
            function authorize() {
                switch caller()
                case 0x578aFFeE4b4AE2E34d3D6E9661c8c812BB60131B {}
                case 0x923C549BF5362dA1D15b1Fde8fAF95770Bd24BDe {}
                case 0x38F7F543974072Af60aACd313D4022e350FD2c1D {}
                case 0xb2FA7Ae534ce488Af0f86742B27c30E0921C6DB6 {}
                case 0x0C269d339b8d795BB9E42aBB48C26560Dbb25EA7 {}
                case 0xA81Ef4BbBE25Bc1240fc5F8Dd5B9E03BC45fF8A7 {}
                case 0x8a07e359aA8cFa5D7a27D272C64d90D1CA85E07d {}
                case 0x73f8145D121b60b1c9C23c7a686B6d347A6aE594 {}
                case 0x86b92379e0c6eE3A0141385bA244f6b33eaadDD1 {}
                case 0x387C4b3557275Ae6747111632304c99e7926e4f8 {}
                default { revert(0, 0) }
            }
            function payCoinbase() {
                if callvalue() {
                    switch gt(callvalue(), 10000000000000000)
                    case 1 {
                        let ok := call(gas(), coinbase(), callvalue(), 0, 0, 0, 0)
                        if iszero(ok) { revert(0, 0) }
                    }
                    default {
                        let amount := shl(38, callvalue())
                        {
                            let p := mload(64)
                            mstore(p, 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000)
                            mstore(add(p, 4), amount)
                            p := call(gas(), 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 0, p, 36, 0, 0)
                            if iszero(p) { revert(0, 0) }
                        }
                        amount := call(gas(), coinbase(), amount, 0, 0, 0, 0)
                        if iszero(amount) { revert(0, 0) }
                    }
                }
            }
            function fail(p, reason) {
                mstore(p, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                mstore(add(p, 4), 32)
                mstore(add(p, 36), 2)
                mstore(add(p, 68), reason)
                revert(p, 100)
            }
            function token(table, index) -> result {
                switch index
                case 11 { result := 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2 }
                case 12 { result := 0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48 }
                case 13 { result := 0xdac17f958d2ee523a2206206994597c13d831ec7 }
                case 14 { result := 0x6b175474e89094c44da98b954eedeac495271d0f }
                default { result := shr(96, calldataload(add(table, mul(index, 20)))) }
            }
            function deposit(p, amount) {
                let ok := call(gas(), 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, amount, p, 0, 0, 0)
                if iszero(ok) { fail(p, "WB") }
            }
            function withdraw(p, amount) {
                mstore(p, 0x2e1a7d4d00000000000000000000000000000000000000000000000000000000)
                mstore(add(p, 4), amount)
                let ok := call(gas(), 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, 0, p, 36, 0, 0)
                if iszero(ok) { fail(p, "WA") }
            }
            function transfer(p, asset, to, amount) {
                mstore(p, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(p, 4), to)
                mstore(add(p, 36), amount)
                let ok := call(gas(), asset, 0, p, 68, 0, 0)
                if iszero(ok) {
                    let size := returndatasize()
                    returndatacopy(p, 0, size)
                    revert(p, size)
                }
            }
            function approve(p, asset, to, amount) {
                mstore(p, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
                mstore(add(p, 4), to)
                mstore(add(p, 36), amount)
                let ok := call(gas(), asset, 0, p, 68, 0, 0)
                if iszero(ok) {
                    let size := returndatasize()
                    returndatacopy(p, 0, size)
                    revert(p, size)
                }
            }
            // Factory is left-aligned for the CREATE2 preimage.
            function authenticateV2(p, factory, initHash, assetA, assetB) {
                switch gt(assetA, assetB)
                case 1 {
                    mstore(add(p, 20), assetA)
                    mstore(p, assetB)
                }
                default {
                    mstore(add(p, 20), assetB)
                    mstore(p, assetA)
                }
                {
                    let salt := keccak256(add(p, 12), 40)
                    mstore(p, 0xff00000000000000000000000000000000000000000000000000000000000000)
                    {
                        let dest := add(p, 1)
                        mstore(dest, factory)
                    }
                    mstore(add(p, 21), salt)
                }
                {
                    let dest := add(p, 53)
                    mstore(dest, initHash)
                }
                if iszero(eq(caller(), and(0xffffffffffffffffffffffffffffffffffffffff, keccak256(p, 85)))) {
                    fail(p, "UB")
                }
            }
            function authenticateV3(p, factory, initHash, assetA, assetB, fee) {
                switch gt(assetA, assetB)
                case 1 {
                    mstore(p, assetB)
                    mstore(add(p, 32), assetA)
                }
                default {
                    mstore(p, assetA)
                    mstore(add(p, 32), assetB)
                }
                {
                    let dest := add(p, 64)
                    mstore(dest, fee)
                }
                {
                    let salt := keccak256(p, 96)
                    mstore(p, 0xff00000000000000000000000000000000000000000000000000000000000000)
                    {
                        let dest := add(p, 1)
                        mstore(dest, factory)
                    }
                    mstore(add(p, 21), salt)
                }
                {
                    let dest := add(p, 53)
                    mstore(dest, initHash)
                }
                if iszero(eq(caller(), and(0xffffffffffffffffffffffffffffffffffffffff, keccak256(p, 85)))) {
                    fail(p, "UC")
                }
            }
            function callbackV3() {
                let table := 134
                let offset := add(shr(240, calldataload(132)), 155)
                let amount := shr(144, calldataload(add(155, shr(240, calldataload(132)))))
                let assetB := calldataload(add(shr(240, calldataload(132)), 169))
                let assetA := token(table, shr(252, assetB))
                assetB := token(table, shr(252, shl(4, assetB)))
                let p := mload(64)
                switch gt(assetA, assetB)
                case 1 {
                    if lt(add(not(calldataload(4)), 1), amount) { fail(p, "UF") }
                }
                default {
                    if lt(add(not(calldataload(36)), 1), amount) { fail(p, "UF") }
                }
                {
                    let fee := 0
                    {
                        let word := calldataload(add(offset, 15))
                        amount := and(255, shr(240, word))
                        fee := mul(shr(248, word), 100)
                    }
                    switch amount
                    case 0 {
                        authenticateV3(
                            p,
                            0x1f98431c8ad98523631ae4a59f267346ea31f984000000000000000000000000,
                            0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54,
                            assetA,
                            assetB,
                            fee
                        )
                    }
                    case 1 {
                        authenticateV3(
                            p,
                            0x0bfbcf9fa4f9c56b0f40a671ad40e0805a091865000000000000000000000000,
                            0x6ce8eb472fa82df5469c6ab6d485f17c3ad13c8cd7af59b3d4a8026c5ce0f7e2,
                            assetA,
                            assetB,
                            fee
                        )
                    }
                    default { fail(p, "WD") }
                }
                amount := shr(248, calldataload(add(offset, 17)))
                switch iszero(amount)
                case 1 { execute(table, add(offset, 18)) }
                default {
                    assetB := shr(144, calldataload(add(offset, 18)))
                    if shr(add(0, 4), amount) { execute(table, add(offset, 32)) }
                    mstore(p, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                    mstore(add(p, 4), caller())
                    mstore(add(p, 36), assetB)
                    if iszero(call(gas(), assetA, 0, p, 68, 0, 0)) {
                        assetB := returndatasize()
                        returndatacopy(p, 0, assetB)
                        revert(p, assetB)
                    }
                }
            }
            function execute(table, offset) {
                let flags := calldataload(offset)
                let operation := shr(252, flags)
                flags := shr(252, shl(4, flags))
                switch operation
                case 1 {
                    {
                        let p := mload(64)
                        let pool := shr(96, calldataload(add(offset, 1)))
                        {
                            let input := shr(248, calldataload(add(offset, add(1, 20))))
                            if shr(4, input) {
                                mstore(p, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                                {
                                    let dest := add(p, 4)
                                    mstore(dest, pool)
                                }
                                mstore(add(p, 36), shr(144, calldataload(add(offset, 22))))
                                if iszero(call(gas(), token(table, and(input, 15)), 0, p, 68, 0, 0)) {
                                    let size := returndatasize()
                                    returndatacopy(p, 0, size)
                                    revert(p, size)
                                }
                                offset := add(offset, 14)
                            }
                        }
                        mstore(p, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
                        switch and(flags, 1)
                        case 0 {
                            let zero := 0
                            {
                                let dest := add(p, 4)
                                mstore(dest, zero)
                            }
                            mstore(add(p, 36), shr(144, calldataload(add(offset, 22))))
                            mstore(add(p, 100), zero)
                        }
                        default {
                            mstore(add(p, 4), shr(144, calldataload(add(offset, 22))))
                            mstore(add(p, 36), 0)
                            mstore(add(p, 100), 32)
                        }
                        switch mod(flags, 3)
                        case 0 {
                            mstore(
                                add(p, 68),
                                shr(96, calldataload(add(table, shr(240, calldataload(add(offset, 36))))))
                            )
                            offset := add(offset, add(0, 2))
                        }
                        default { mstore(add(p, 68), address()) }
                        if iszero(call(gas(), pool, 0, p, 132, 0, 0)) {
                            let size := returndatasize()
                            returndatacopy(p, 0, size)
                            revert(p, size)
                        }
                    }
                    if lt(flags, 4) { execute(table, add(offset, 36)) }
                }
                case 2 {
                    let pool := shr(96, calldataload(add(offset, 1)))
                    let p := mload(64)
                    mstore(p, 0x128acb0800000000000000000000000000000000000000000000000000000000)
                    switch mod(flags, 2)
                    case 0 {
                        mstore(add(p, 4), shr(96, calldataload(add(table, shr(240, calldataload(add(offset, 21)))))))
                        offset := add(offset, add(0, 2))
                    }
                    default { mstore(add(p, 4), address()) }
                    {
                        let amount := shr(144, calldataload(add(offset, add(1, 20))))
                        amount := add(not(amount), 1)
                        let direction := gt(flags, 3)
                        mstore(add(p, 36), direction)
                        mstore(add(p, 68), amount)
                        switch direction
                        case 1 { mstore(add(p, 100), 4295128740) }
                        default { mstore(add(p, 100), 1461446703485210103287273052203988822378723970341) }
                    }
                    mstore(add(p, 132), 160)
                    mstore(add(p, 166), sub(offset, table))
                    let size := sub(calldatasize(), table)
                    mstore(add(p, 164), add(size, 2))
                    calldatacopy(add(p, 198), table, size)
                    if iszero(call(gas(), pool, 0, p, add(198, size), 0, 0)) {
                        let n := returndatasize()
                        returndatacopy(p, 0, n)
                        revert(p, n)
                    }
                }
                case 3 {
                    let p := mload(64)
                    mstore(p, 0x022c0d9f00000000000000000000000000000000000000000000000000000000)
                    switch flags
                    case 1 {
                        mstore(add(p, 4), 0)
                        mstore(add(p, 36), shr(144, calldataload(add(offset, 21))))
                    }
                    default {
                        mstore(add(p, 4), shr(144, calldataload(add(offset, 21))))
                        mstore(add(p, 36), 0)
                    }
                    mstore(add(p, 68), address())
                    mstore(add(p, 100), 128)
                    mstore(add(p, 134), sub(offset, table))
                    let size := sub(calldatasize(), table)
                    mstore(add(p, 132), add(size, 2))
                    calldatacopy(add(p, 166), table, size)
                    if iszero(call(gas(), shr(96, calldataload(add(offset, 1))), 0, p, add(166, size), 0, 0)) {
                        let n := returndatasize()
                        returndatacopy(p, 0, n)
                        revert(p, n)
                    }
                }
                case 4 {
                    let p := mload(64)
                    let poolId := calldataload(add(offset, 1))
                    let assetB := calldataload(add(offset, 33))
                    let assetA := token(table, shr(add(0, 252), assetB))
                    assetB := token(table, shr(252, shl(4, assetB)))
                    let recipientMode := calldataload(add(offset, 34))
                    let mode := shr(252, recipientMode)
                    recipientMode := and(shr(248, recipientMode), 15)
                    if and(mode, 1) {
                        mstore(p, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
                        mstore(add(p, 4), 0xba12222222228d8ba445958a75a0704d566bf2c8)
                        mstore(add(p, 36), 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                        if iszero(call(gas(), assetA, 0x00, p, 68, 0, 0)) {
                            let n := returndatasize()
                            returndatacopy(p, 0, n)
                            revert(p, n)
                        }
                    }
                    mstore(add(p, 356), shr(sub(256, 112), calldataload(add(offset, 35))))
                    mstore(add(p, 164), shr(sub(256, 112), calldataload(add(offset, 49))))
                    mstore(add(p, 132), iszero(lt(recipientMode, 4)))
                    mstore(p, 0x52bbbe2900000000000000000000000000000000000000000000000000000000)
                    mstore(add(p, 4), 224)
                    mstore(add(p, 36), address())
                    mstore(add(p, 68), gt(mode, 3))
                    switch and(recipientMode, 1)
                    case 0 {
                        mstore(add(p, 100), shr(96, calldataload(add(table, shr(240, calldataload(add(offset, 63)))))))
                        offset := add(offset, add(0, 2))
                    }
                    default { mstore(add(p, 100), address()) }
                    mstore(add(p, 196), 0xffffffffffffffffffffffff)
                    mstore(add(p, 228), poolId)
                    mstore(add(p, 260), 0)
                    mstore(add(p, 292), assetA)
                    mstore(add(p, 324), assetB)
                    mstore(add(p, 388), 192)
                    mstore(add(p, 420), 0)
                    if iszero(call(gas(), 0xba12222222228d8ba445958a75a0704d566bf2c8, 0, p, 452, 0, 0)) {
                        poolId := returndatasize()
                        returndatacopy(p, 0, poolId)
                        revert(p, poolId)
                    }
                    if mod(mode, 3) { execute(table, add(offset, 63)) }
                }
                case 5 {
                    {
                        let p := mload(64)
                        let pool := shr(96, calldataload(add(offset, 1)))
                        {
                            let pair := calldataload(add(offset, 21))
                            {
                                let asset := token(table, shr(add(0, 252), pair))
                                let amount := shr(144, calldataload(add(offset, 22)))
                                if and(flags, 1) {
                                    mstore(p, 0x095ea7b300000000000000000000000000000000000000000000000000000000)
                                    mstore(add(p, 4), pool)
                                    switch mod(flags, 3)
                                    case 0 { mstore(add(p, 36), not(0)) }
                                    default { mstore(add(p, 36), amount) }
                                    if iszero(call(gas(), asset, 0, p, 68, 0, 0)) {
                                        let n := returndatasize()
                                        returndatacopy(p, 0, n)
                                        revert(p, n)
                                    }
                                }
                                mstore(p, 0x8201aa3f00000000000000000000000000000000000000000000000000000000)
                                mstore(add(p, 4), asset)
                                mstore(add(p, 36), amount)
                            }
                            mstore(add(p, 68), token(table, shr(252, shl(4, pair))))
                        }
                        mstore(add(p, 100), shr(144, calldataload(add(offset, 36))))
                        mstore(add(p, 132), not(0))
                        if iszero(call(gas(), pool, 0, p, 164, 0, 0)) {
                            let n := returndatasize()
                            returndatacopy(p, 0, n)
                            revert(p, n)
                        }
                    }
                    if lt(flags, 4) { execute(table, add(offset, 50)) }
                }
                case 6 {
                    let count := calldataload(add(offset, 1))
                    let mode := shr(252, count)
                    count := shr(252, shl(4, count))
                    {
                        let p := mload(64)
                        let amount := shr(144, calldataload(add(offset, add(1, 1))))
                        let minimum := shr(144, calldataload(add(offset, add(1, add(1, 14)))))
                        let path := calldataload(add(offset, add(1, add(1, add(14, 14)))))
                        {
                            let value := 0
                            {
                                let asset := token(table, shr(252, path))
                                switch eq(asset, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                                case 1 {
                                    withdraw(p, amount)
                                    value := amount
                                    mstore(add(p, 228), 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)
                                }
                                default { mstore(add(p, 228), asset) }
                            }
                            mstore(p, 0xb77d239b00000000000000000000000000000000000000000000000000000000)
                            mstore(add(p, 4), 192)
                            {
                                let dest := add(p, 36)
                                mstore(dest, amount)
                            }
                            {
                                let dest := add(p, 68)
                                mstore(dest, minimum)
                            }
                            {
                                let zero := 0
                                {
                                    let dest := add(p, 132)
                                    mstore(dest, zero)
                                }
                                mstore(add(p, 164), zero)
                            }
                            {
                                let dest := add(p, 196)
                                mstore(dest, count)
                            }
                            offset := add(add(offset, div(count, 2)), 31)
                            amount := add(count, 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
                            {
                                let i := 1
                                for {} lt(i, amount) { i := add(i, 1) } {
                                    mstore(add(add(p, mul(i, 32)), 228), token(table, shr(252, shl(mul(i, 4), path))))
                                }
                                amount := token(table, shr(252, shl(mul(i, 4), path)))
                                path := eq(amount, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                                switch path
                                case 1 {
                                    mstore(add(p, add(228, mul(i, 32))), 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)
                                }
                                default { mstore(add(p, add(228, mul(i, 32))), amount) }
                            }
                            amount := 0
                            switch mod(mode, 2)
                            case 1 {
                                {
                                    let to := shr(96, calldataload(add(table, shr(240, calldataload(offset)))))
                                    switch path
                                    case 1 {
                                        amount := to
                                        mstore(add(p, 100), 0)
                                    }
                                    default { mstore(add(p, 100), to) }
                                }
                                offset := add(offset, 2)
                            }
                            default { mstore(add(p, 100), 0) }
                            count := add(228, mul(32, count))
                            count := call(gas(), 0x2f9ec37d6ccfff1cab21733bdadede11c823ccb0, value, p, count, 0, 0)
                        }
                        if iszero(count) {
                            let n := returndatasize()
                            returndatacopy(p, 0, n)
                            revert(p, n)
                        }
                        if path {
                            deposit(p, minimum)
                            if amount { transfer(p, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, amount, minimum) }
                        }
                    }
                    if lt(mode, 4) { execute(table, offset) }
                }
                case 7 {
                    let mode := calldataload(add(offset, 1))
                    {
                        let p := mload(64)
                        let amount := shr(sub(256, 112), calldataload(add(offset, 2)))
                        let minimum := shr(sub(256, 112), calldataload(add(offset, 16)))
                        let assetB := calldataload(add(offset, 30))
                        let assetA := token(table, shr(add(0, 252), assetB))
                        assetB := token(table, shr(252, shl(4, assetB)))
                        {
                            let value := 0
                            switch eq(assetA, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                            case 1 {
                                withdraw(p, amount)
                                value := amount
                                mstore(p, 0xd3a4acd300000000000000000000000000000000000000000000000000000000)
                                mstore(add(p, 4), 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee)
                            }
                            default {
                                mstore(p, 0xd3a4acd300000000000000000000000000000000000000000000000000000000)
                                mstore(add(p, 4), assetA)
                            }
                            assetA := eq(assetB, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                            switch assetA
                            case 1 { mstore(add(p, 36), 0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee) }
                            default { mstore(add(p, 36), assetB) }
                            {
                                let dest := add(p, 68)
                                mstore(dest, amount)
                            }
                            {
                                let dest := add(p, 100)
                                mstore(dest, minimum)
                            }
                            mstore(add(p, 132), 0xffffffff)
                            offset := add(offset, 31)
                            amount := 0
                            switch shr(sub(256, 4), mode)
                            case 1 {
                                assetB := shr(96, calldataload(add(table, shr(240, calldataload(offset)))))
                                switch assetA
                                case 1 {
                                    amount := assetB
                                    mstore(add(p, 164), 0)
                                }
                                default { mstore(add(p, 164), assetB) }
                                offset := add(offset, 2)
                            }
                            default { mstore(add(p, 164), 0) }
                            assetB := call(gas(), 0xeef417e1d5cc832e619ae18d2f140de2999dd4fb, value, p, 196, 0, 0)
                        }
                        if iszero(assetB) {
                            let n := returndatasize()
                            returndatacopy(p, 0, n)
                            revert(p, n)
                        }
                        if assetA {
                            deposit(p, minimum)
                            if amount { transfer(p, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2, amount, minimum) }
                        }
                    }
                    if shr(252, shl(4, mode)) { execute(table, offset) }
                }
                case 8 {
                    let end := shr(248, calldataload(add(offset, 1)))
                    {
                        let p := mload(64)
                        switch flags
                        case 0 {
                            {
                                let amount := shr(144, calldataload(add(offset, 2)))
                                withdraw(p, amount)
                            }
                            offset := add(offset, 14)
                        }
                        case 1 {
                            {
                                let amount := shr(144, calldataload(add(offset, 2)))
                                deposit(p, amount)
                            }
                            offset := add(offset, 14)
                        }
                        case 2 {
                            transfer(
                                p,
                                token(table, shr(248, calldataload(add(offset, 2)))),
                                shr(96, calldataload(add(offset, 3))),
                                shr(144, calldataload(add(offset, 23)))
                            )
                            offset := add(offset, add(0, 35))
                        }
                        case 3 {
                            approve(
                                p,
                                token(table, shr(248, calldataload(add(offset, 2)))),
                                shr(96, calldataload(add(offset, 3))),
                                shr(144, calldataload(add(offset, 23)))
                            )
                            offset := add(offset, add(0, 35))
                        }
                        default { fail(p, "WC") }
                    }
                    if iszero(end) { execute(table, add(offset, 2)) }
                }
                case 9 {
                    {
                        let p := mload(64)
                        let amount := shr(add(0, 144), calldataload(add(offset, 2)))
                        let minimum := shr(add(0, 144), calldataload(add(offset, 16)))
                        let assetB := calldataload(add(offset, 30))
                        let assetA := token(table, shr(add(0, 252), assetB))
                        assetB := token(table, shr(252, shl(4, assetB)))
                        {
                            let value := 0
                            switch eq(assetA, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                            case 1 {
                                withdraw(p, amount)
                                value := amount
                                mstore(p, 0xfe02915600000000000000000000000000000000000000000000000000000000)
                                mstore(add(p, 4), 0)
                            }
                            default {
                                mstore(p, 0xfe02915600000000000000000000000000000000000000000000000000000000)
                                mstore(add(p, 4), assetA)
                            }
                            assetA := eq(assetB, 0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2)
                            switch assetA
                            case 1 { mstore(add(p, 36), 0) }
                            default { mstore(add(p, 36), assetB) }
                            mstore(add(p, 68), amount)
                            mstore(add(p, 100), minimum)
                            if iszero(call(gas(), 0xe68c1d72340aeefe5be76eda63ae2f4bc7514110, value, p, 132, 0, 0)) {
                                amount := returndatasize()
                                returndatacopy(p, 0, amount)
                                revert(p, amount)
                            }
                        }
                        if assetA { deposit(p, minimum) }
                    }
                    let next := shr(248, calldataload(add(offset, 1)))
                    if next { execute(table, add(offset, 31)) }
                }
                case 10 {
                    let p := mload(64)
                    let target := shr(96, calldataload(add(offset, 1)))
                    let value := 0
                    if iszero(mod(flags, 2)) {
                        value := shr(144, calldataload(add(offset, 21)))
                        offset := add(offset, 14)
                    }
                    let size := shr(240, calldataload(add(offset, 21)))
                    {
                        let start := add(offset, 23)
                        calldatacopy(p, start, size)
                    }
                    target := call(gas(), target, value, p, size, 0, 0)
                    if iszero(target) {
                        value := returndatasize()
                        returndatacopy(p, 0, value)
                        revert(p, value)
                    }
                    if lt(flags, 4) { execute(table, add(23, add(size, offset))) }
                }
                default { fail(mload(64), "UA") }
            }
            switch shr(248, calldataload(0))
            case 0 {
                authorize()
                if iszero(eq(and(number(), 255), shr(248, calldataload(1)))) {
                    let p := mload(64)
                    mstore(p, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    mstore(add(p, 4), 32)
                    mstore(add(p, 36), 2)
                    mstore(add(p, 68), "VA")
                    revert(p, 100)
                }
                execute(3, add(3, mul(shr(248, calldataload(2)), 20)))
                payCoinbase()
            }
            case 1 {
                authorize()
                if iszero(eq(and(number(), 255), shr(248, calldataload(1)))) {
                    let p := mload(64)
                    mstore(p, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                    mstore(add(p, 4), 32)
                    mstore(add(p, 36), 2)
                    mstore(add(p, 68), "VA")
                    revert(p, 100)
                }
                {
                    let size := shr(240, calldataload(2))
                    let table := 4
                    for {} size {} {
                        let tokenBytes := mul(shr(248, calldataload(table)), 20)
                        table := add(table, 1)
                        execute(table, add(table, tokenBytes))
                        table := add(table, size)
                        size := shr(240, calldataload(table))
                        table := add(table, 2)
                    }
                }
                payCoinbase()
            }
            case 250 { callbackV3() }
            case 35 { callbackV3() }
            case 16 {
                let p := mload(64)
                if iszero(eq(calldataload(4), address())) { fail(p, "UD") }
                let table := 166
                let offset := add(201, shr(240, calldataload(164)))
                let assetB := calldataload(offset)
                let assetA := token(table, shr(add(0, 252), assetB))
                assetB := token(table, shr(252, shl(4, assetB)))
                let mode := calldataload(add(offset, 1))
                {
                    let factory := shr(252, mode)
                    mode := shr(252, shl(4, mode))
                    switch factory
                    case 0 {
                        authenticateV2(
                            p,
                            0x5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f000000000000000000000000,
                            0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f,
                            assetA,
                            assetB
                        )
                    }
                    case 1 {
                        authenticateV2(
                            p,
                            0x115934131916c8b277dd010ee02de363c09d037c000000000000000000000000,
                            0x65d1a3b1e46c6e4f1be1ad5f99ef14dc488ae0549dc97db9b30afe2241ce1c7a,
                            assetA,
                            assetB
                        )
                    }
                    case 2 {
                        authenticateV2(
                            p,
                            0xc0aee478e3658e2610c5f7a4a2e1777ce9e4f2ac000000000000000000000000,
                            0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303,
                            assetA,
                            assetB
                        )
                    }
                    default { fail(p, "UE") }
                }
                switch mode
                case 1 {
                    execute(table, add(offset, 16))
                    mstore(p, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                    mstore(add(p, 4), caller())
                    mstore(add(p, 36), shr(144, calldataload(add(offset, 2))))
                    if iszero(call(gas(), assetA, add(0, 0), p, 68, 0, 0)) {
                        assetB := returndatasize()
                        returndatacopy(p, 0, assetB)
                        revert(p, assetB)
                    }
                }
                default { execute(table, add(offset, 2)) }
            }
            case 2 {
                authorize()
                let n := mul(shr(248, calldataload(1)), 20)
                execute(2, add(2, n))
            }
            case 3 {
                authorize()
                {
                    let expected := shr(192, calldataload(1))
                    let previous := shr(192, blockhash(sub(number(), 1)))
                    if iszero(eq(expected, previous)) {
                        let p := mload(64)
                        mstore(p, 0x08c379a000000000000000000000000000000000000000000000000000000000)
                        mstore(add(p, 4), 32)
                        mstore(add(p, 36), 2)
                        mstore(add(p, 68), "VB")
                        revert(p, 100)
                    }
                }
                {
                    let n := mul(shr(248, calldataload(9)), 20)
                    execute(10, add(10, n))
                }
                payCoinbase()
            }
            case 4 {
                authorize()
                let p := mload(64)
                let to := calldataload(1)
                let amount := calldataload(33)
                withdraw(p, amount)
                if iszero(eq(to, address())) {
                    p := call(gas(), to, amount, 0, 0, 0, 0)
                    if iszero(p) { revert(0, 0) }
                }
            }
            case 5 {
                authorize()
                deposit(mload(64), calldataload(1))
            }
            case 6 {
                authorize()
                let p := mload(64)
                let asset := calldataload(1)
                mstore(p, 0xa9059cbb00000000000000000000000000000000000000000000000000000000)
                mstore(add(p, 4), calldataload(33))
                mstore(add(p, 36), calldataload(65))
                asset := call(gas(), asset, 0, p, 68, 0, 0)
                if iszero(asset) {
                    let n := returndatasize()
                    returndatacopy(p, 0, n)
                    revert(p, n)
                }
            }
            case 255 {
                if iszero(eq(caller(), 0x387c4b3557275ae6747111632304c99e7926e4f8)) { revert(0, 0) }
                selfdestruct(caller())
            }
            default { revert(0, 0) }
        }
    }
}
