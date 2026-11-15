// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

interface Token {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

/// @notice Reconstructed library-based execution and gas-refund contract.
contract Executor {
    // Library identifiers occupy mapping slot 0; gas-refund counters use slots 50 and 51.
    mapping(uint256 => address) private libraries;
    uint256[49] private reserved;
    uint256 private freed;
    uint256 private created;

    // Preserve the deployed caller allowlist and its original evaluation order.
    function checkSender() internal view {
        if (address(0xfF1b9745f68F84F036E5e92c920038d895FB701A) == msg.sender) return;
        if (address(0xFF28319a7cD2136ea7283E7cDb0675B50AC29Dd2) == msg.sender) return;
        if (address(0xFF3769cdBD31893EF1b10A01EE0d8bD1f3773899) == msg.sender) return;
        if (address(0xff49432a1Ea8ac6d12285099ba426d1F16f23c8d) == msg.sender) return;
        if (address(0xfF59364722A4622A8D33623548926375B1B07767) == msg.sender) return;
        if (address(0xff6d62bc882c2Fca5Af5CBFe1e6C10b97Ba251A4) == msg.sender) return;
        if (address(0xfF7Baf00edF054E249e9f498aa51d1934B8d3526) == msg.sender) return;
        if (address(0xfF86C0AA0Cc44C3B054C5FDb25F85d555C1d2C3A) == msg.sender) return;
        if (address(0xff910355ad1D3d12E8Be75a512553e479726ab45) == msg.sender) return;
        if (address(0xFFA5bFe92B6791DAd23c7837abb790b48C2F8995) == msg.sender) return;
        if (address(0xFFbFDb803D38D794B5785eE0ac09F83b429d11b5) == msg.sender) return;
        if (address(0xFFCdfD98c455c29818697Ab2eEaFccBc4e59Fd3D) == msg.sender) return;
        if (address(0xFfdcE1aE835d35Bb603c95163e510Bb2604a1A41) == msg.sender) return;
        if (address(0xffE1c5696d924438fba5274d7B5D8fFa29239a6f) == msg.sender) return;
        if (address(0xFfF66732389866aeaF8f7305Da53f442c29e1b8F) == msg.sender) return;
        if (address(0xfFF804bd7487B4E2AaDb32Def0Efc9c3127687A2) == msg.sender) return;
        if (address(0xffFb0526a6EB87E85Ba0bacB38Dd5b53e9bFC097) == msg.sender) return;
        if (address(0xfffc4a1C98687254c7CF6B1A3Bc27db464f3600B) == msg.sender) return;
        if (address(0xfFFDcbE1e77fBF1D0Ba78FC39ce4aB0BF5c9f94C) == msg.sender) return;
        if (address(0xfFFef0974279825a633a295D7eBc3f7afEB33c17) == msg.sender) return;
        if (address(0xFfff46E05A09314DaAE9176FC32Dba0f4172DcDB) == msg.sender) return;
        if (address(0x21F179DF331CdC8583373Ca5925bf386880Cf49e) == msg.sender) return;
        if (address(0x228E402a8eEEDD5D1062287BFb1fa0C87DF6F69C) == msg.sender) return;
        if (address(0x23e28b5ADbDF08319b4919471cdB0551f0c64dFE) == msg.sender) return;
        if (address(0x24DF3880DDE1F005548ba9334547D7F317F13D29) == msg.sender) return;
        if (address(0x2560A6B230BADBAC68cb6667E202cF0C1CaA17B7) == msg.sender) return;
        if (address(0x26AFD91411226d4c2A13b8c8b5547cb6aC1c6cDC) == msg.sender) return;
        if (address(0x2762C99F14E987EC71346e33735959B7D9180311) == msg.sender) return;
        if (address(0x2886F28a2c58a3DDF7A4847ceD88720125D63b80) == msg.sender) return;
        if (address(0x299DB3A6e900681C2436417eF8d13d2AF0531f7E) == msg.sender) return;
        if (address(0x30906C083E2ad69c9dcC5b753b86a14f7065d22b) == msg.sender) return;
        if (address(0x31893157f8D17a5dC3328eD3081fCA67Ac16B4D9) == msg.sender) return;
        if (address(0x325eb11541684dcb487a5c6c7e89C98c3f3d6Ad0) == msg.sender) return;
        if (address(0x330f620168e2f3C2BDBA60b68574b74358611688) == msg.sender) return;
        if (address(0x34e2a44518B39601633ac9d848F16480ef73bE48) == msg.sender) return;
        if (address(0x3500CFCaeCaFcf5e0607F38A3C7eAfb1750830eb) == msg.sender) return;
        if (address(0x366d92fa7f6C565d6B831Dc6850EE1d299E54F07) == msg.sender) return;
        if (address(0x3741D4FfB44E77Fa9b56ea22019c3498c975FA0c) == msg.sender) return;
        if (address(0x389Fd1c46E93Cff16ed530A76E44E79b99Ae240a) == msg.sender) return;
        if (address(0x393246FD310aEC7CbC174D9dF0168989A623A71D) == msg.sender) return;
        if (address(0x40535fa07Dae9054c2F8598199883FC62c23f12D) == msg.sender) return;
        if (address(0x41Ed16c0982099Bf5dA7BC44217E74e8847a4EeB) == msg.sender) return;
        if (address(0x42815f4f05298B748fA40F47E272dC2a9F9064CC) == msg.sender) return;
        if (address(0x4306ccAadC07c235cf857D062e80Fff6c4948e59) == msg.sender) return;
        if (address(0x44BF59C7AA434Bcb7207749672134819294E7C4E) == msg.sender) return;
        if (address(0x45DD0E024d618465003a1cdEC68426187C5218b0) == msg.sender) return;
        if (address(0x4614d68b1d13b6ff55eF3a9070212026F7c18d3D) == msg.sender) return;
        if (address(0x47be5812Cd4059f15aC7bc125FEBFe700d55eeBc) == msg.sender) return;
        if (address(0x4895D41376C5172CAA5DE975d89b13Fd994Cd174) == msg.sender) return;
        if (address(0x4964F173A96326D408958931E690a0900E1517f5) == msg.sender) return;
        if (address(0x50BB07E549702848dcF689c8AD31b4774B34b164) == msg.sender) return;
        if (address(0x51AA0eda9c3367aE897513D6ecb54A687AA5A618) == msg.sender) return;
        if (address(0x527a5889Db1bfA948A71c53f9BD5679E25A0b643) == msg.sender) return;
        if (address(0x5350Ef3850c227F62D84266335c726C8bC5FdF76) == msg.sender) return;
        if (address(0x542636CA6C9D37908bbB3973b1853d367fc14177) == msg.sender) return;
        if (address(0x556E4894Dbe587cb661B4d412fD54A442c4c98e2) == msg.sender) return;
        if (address(0x569911a297eBa566FE5dab8B162F39F2c4A58c5f) == msg.sender) return;
        if (address(0x57AD4BFCa0Ca9bA91C885068970d429647581c45) == msg.sender) return;
        if (address(0x5868F93c5127dfe53C5C4E770858484e78d986fB) == msg.sender) return;
        if (address(0x59f228a6c65A12d17bCA2031CBf7b0CC3a0D9566) == msg.sender) return;
        if (address(0x60530f5Ca4CB9907e0FBE67cA3AFCbFE56D19A5c) == msg.sender) return;
        if (address(0x6199686CB7e49193D4e4D9ba5a7352d51dF65D47) == msg.sender) return;
        if (address(0x62d2EC49F8F6Fc01E81cc81ccab354d508049717) == msg.sender) return;
        if (address(0x63166Dc8c4820362e2a99d06F044fA64ed1935aD) == msg.sender) return;
        if (address(0x64F88984c5Ed6D16cA5aa119f4d79018F4b23322) == msg.sender) return;
        if (address(0x655d76Da7523A385BA22BfF8abbCB22B268F65e2) == msg.sender) return;
        if (address(0x663168c2d70A31Aeb18062d51af303276fD1fFCe) == msg.sender) return;
        if (address(0x676C0068402fC45f05e4dDe5260249D2B7eDcF85) == msg.sender) return;
        if (address(0x684b00CE95Cb4c3331dC99B75e6517964297D555) == msg.sender) return;
        if (address(0x695bc4aF453C6c01E07818DaC067a14982e9F958) == msg.sender) return;
        if (address(0x70E949aE46A1D52dBC3ab2b7BcEaA81f1a613CE8) == msg.sender) return;
        if (address(0x7171858b7d8381475da5805B1633B084409354DE) == msg.sender) return;
        if (address(0x7270a8a3D44a86711c56BB74d9fD5FFB85456462) == msg.sender) return;
        if (address(0x73821e7a51aFE6ad1603D1D0FE3E2c14157366b1) == msg.sender) return;
        if (address(0x7433ec80c8d878d6F04677Ae2be7Ef7ea772caE9) == msg.sender) return;
        if (address(0x75DB2F804d95C17227Df9E8102925d1EF5A2e383) == msg.sender) return;
        if (address(0x76555c36FB12c4bcA5e4dBa06BC089B0D031c0f5) == msg.sender) return;
        if (address(0x77893ECf8cBc63ee020B140A6F4216d9C1479135) == msg.sender) return;
        if (address(0x783D9c137A2ad4FD5A61B93a6C6EB4b997f0aBeE) == msg.sender) return;
        if (address(0x792c938df8D0ef2Ba9F578d98e852Fb9d8E3deb3) == msg.sender) return;
        if (address(0x80D87340E754bF2Ec226f8ad948F831BEF57a261) == msg.sender) return;
        if (address(0x81f4E690552687a37eD08b791C626D6C3d3a5E4C) == msg.sender) return;
        if (address(0x82407FBb1244e9b12E00fc753099072FEf8c8fFb) == msg.sender) return;
        if (address(0x8353Ea423C1Cb59722C6D06b3468E072e6B265AD) == msg.sender) return;
        if (address(0x8439A6A573eBA2Fb29D4BFf8ed1cAECae1eb6249) == msg.sender) return;
        if (address(0x8572508cd0Fc1989f265E667415359DFbf5C43B5) == msg.sender) return;
        if (address(0x86CDFf297e5C5524648777DD34D991e23c682d9e) == msg.sender) return;
        if (address(0x874e509d2B14D5984E11D5b0Da11d8382ca4be9b) == msg.sender) return;
        if (address(0x887fB345640112Fd699279aE6222CED22a666C9d) == msg.sender) return;
        if (address(0x897Dcc8Dc2127C7911e0dA427FF293692c2D71BE) == msg.sender) return;
        if (address(0x905161a26557F387e84bFD0dcB0Ac9e97b7B1B2d) == msg.sender) return;
        if (address(0x917Fbe2F902cB5Ff9ff9a69bb05E99c0b31a2876) == msg.sender) return;
        if (address(0x92d2b377C0AF1EecF72140efC9976Eb052396Bf0) == msg.sender) return;
        if (address(0x93bBCFff71140Ff3993BF6f3d2EE6586320A0f7C) == msg.sender) return;
        if (address(0x941bb5C31E715324a0BDB6569e125f3b1000B32b) == msg.sender) return;
        if (address(0x95c955f41059418dDbBAA02C8855648dA85A08e9) == msg.sender) return;
        if (address(0x96dB81969A5cBaD48fE868d8530c81589aBE1b35) == msg.sender) return;
        if (address(0x97B3960CA7be6853B542C60FE8c4dfcDC3167513) == msg.sender) return;
        if (address(0x9828975989EDC9B281DF1b705ae70D1fC8aa5336) == msg.sender) return;
        if (address(0x997132E8d309dd2b7795b58B9Fc45D1C8076a263) == msg.sender) return;
        if (address(0x100ee41d061328BD5dcF9b0973132ffFcd8596B6) == msg.sender) return;
        revert();
    }
    function checkGas() internal view {
        require(block.gaslimit <= 40000000);
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        if (b >= a) return 0;
        return a - b;
    }
    // Derive CREATE child addresses from RLP(address(this), nonce) and release them.
    function freeStorage(uint256 count) internal {
        assembly {
            let f := sload(50)
            let c := sload(51)
            if gt(add(sub(c, f), 1), count) {
                for { let i := add(f, 1) } lt(i, add(add(f, count), 1)) { i := add(i, 1) } {
                    if gt(i, 65535) {
                        mstore(90, i)
                        mstore(87, 0x83)
                        mstore(86, address())
                        mstore(66, 0xd994)
                        pop(call(gas(), keccak256(96, 26), 0, 0, 0, 0, 0))
                    }
                    if gt(i, 255) {
                        mstore(89, i)
                        mstore(87, 0x82)
                        mstore(86, address())
                        mstore(66, 0xd894)
                        pop(call(gas(), keccak256(96, 25), 0, 0, 0, 0, 0))
                    }
                    if gt(i, 127) {
                        mstore(88, i)
                        mstore(87, 0x81)
                        mstore(86, address())
                        mstore(66, 0xd794)
                        pop(call(gas(), keccak256(96, 24), 0, 0, 0, 0, 0))
                    }
                    mstore(87, i)
                    mstore(86, address())
                    mstore(66, 0xd694)
                    pop(call(gas(), keccak256(96, 23), 0, 0, 0, 0, 0))
                }
                sstore(50, add(count, f))
            }
        }
    }
    function setLibraries(address[] calldata addresses) external {
        checkSender();
        checkGas();
        uint256 n = addresses.length;
        for (uint256 i = 1; i < 1 + n; i++) {
            libraries[i] = addresses[i - 1];
        }
    }
    function checkStorage() external view returns (uint256) {
        return created - freed;
    }
    function withdraw(uint256 amount) external {
        checkSender();
        checkGas();
        if (amount > 0) msg.sender.transfer(amount);
    }
    function withdrawTokens(address token) external {
        checkSender();
        checkGas();
        Token t = Token(token);
        uint256 amount = t.balanceOf(address(this));
        if (amount > 0) require(t.transfer(msg.sender, amount));
    }
    // Deploy 53 minimal refund children. The child permits destruction by its creator.
    function refillStorage() external {
        assembly {
            mstore(100, 0x3318585733ff600052601b6005f3)
            mstore(86, address())
            mstore8(96, 0x7a)
            mstore8(97, 0x73)
            for { let i := 0 } lt(i, 53) { i := add(i, 1) } {
                pop(create(0, 96, 36))
            }
            sstore(51, add(53, sload(51)))
        }
    }
    function approve(address token, address spender) external {
        checkSender();
        checkGas();
        Token t = Token(token);
        t.approve(spender, 0);
        bool success = t.approve(spender, uint256(-1));
        require(success);
    }
    function tokenFallback(address, uint256, bytes calldata) external {}
    function cancel() external {
        checkSender();
        checkGas();
        freeStorage(1);
    }
    receive() external payable {}
    // Packed calldata: flags, library 1, word count 1, library 2, word count 2,
    // four 4-byte selectors, then the two argument sequences beginning at byte 21.
    fallback() external {
        uint256 startGas = gasleft();
        uint256 balanceBefore = address(this).balance;
        uint256 used = 0;
        checkSender();
        checkGas();
        // Retain the shifted payload register emitted by the original compiler.
        uint256 packedPayload;
        uint256 raw;
        assembly { raw := calldataload(0) }
        address lib1 = libraries[uint8(bytes1(bytes32(raw * 256)))];
        uint256 len1 = uint8(bytes1(bytes32(raw * 65536)));
        address lib2 = libraries[uint8(bytes1(bytes32(raw * 16777216)))];
        uint256 len2 = uint8(bytes1(bytes32(raw * 4294967296)));
        packedPayload = raw * 1099511627776;
        // Quote calls return an amount and a count of refund units already consumed.
        uint256 result;
        assembly {
            let ptr := mload(64)
            calldatacopy(ptr,5,4)
            calldatacopy(add(ptr,4),21,mul(len1,32))
            let success := delegatecall(gas(), lib1, ptr, add(4,mul(len1,32)),0,64)
            result := mload(0)
            used := add(used,mload(32))
            switch success case 0 { revert(0,0) }
        }
        if (result > 0) {
            if (lib2 != address(0)) {
                uint256 result2;
                assembly {
                    let ptr := mload(64)
                    calldatacopy(ptr,9,4)
                    calldatacopy(add(ptr,4),add(21,mul(len1,32)),mul(len2,32))
                    let success := delegatecall(gas(),lib2,ptr,add(4,mul(len2,32)),0,64)
                    result2 := mload(0)
                    used := add(used,mload(32))
                    switch success case 0 {revert(0,0)}
                }
                if (result2 > 0) {
                    assembly {
                        let v1 := div(mul(result,1000000000000000000),calldataload(sub(mul(len1,32),11)))
                        let v2 := div(mul(result2,1000000000000000000),calldataload(sub(mul(add(len1,len2),32),11)))
                        switch lt(v2,v1) case 1 {
                            result := div(mul(calldataload(sub(mul(len1,32),11)), v2),1000000000000000000)
                        }
                    }
                    assembly {
                        let ptr := mload(64)
                        calldatacopy(ptr,13,4)
                        calldatacopy(add(ptr,4),21,mul(len1,32))
                        mstore(add(add(ptr,4),sub(mul(len1,32),32)),result)
                        let ok := delegatecall(gas(),lib1,ptr,add(4,mul(len1,32)),0,0)
                        switch ok case 0 {revert(0,0)}
                    }
                    assembly {
                        let ptr := mload(64)
                        calldatacopy(ptr,17,4)
                        calldatacopy(add(ptr,4),add(21,mul(len1,32)),mul(len2,32))
                        mstore(add(add(ptr,4),sub(mul(len2,32),32)),result2)
                        let ok := delegatecall(gas(),lib2,ptr,add(4,mul(len2,32)),0,0)
                        switch ok case 0 {revert(0,0)}
                    }
                } else { used = 0; }
            } else {
                assembly {
                    let ptr := mload(64)
                    calldatacopy(ptr,13,4)
                    calldatacopy(add(ptr,4),21,mul(len1,32))
                    mstore(add(add(ptr,4),sub(mul(len1,32),32)),result)
                    let ok := delegatecall(gas(),lib1,ptr,add(4,mul(len1,32)),0,0)
                    switch ok case 0 {revert(0,0)}
                }
            }
        } else { used = 0; }
        require(address(this).balance >= balanceBefore);
        // The leading flag enables the historical gas-refund calculation.
        if (bytes1(0x01) == bytes1(bytes32(raw))) {
            uint256 count = sub((21000 + ((msg.data.length * 12 + startGas) - gasleft())), used * 30000);
            assembly { count := add(div(add(count, 2730), 42000), 1) }
            if (count > 0) freeStorage(count);
        }
    }
}
