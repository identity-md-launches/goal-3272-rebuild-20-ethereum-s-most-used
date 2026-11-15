// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.0;
pragma experimental ABIEncoderV2;

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
}

interface IGasToken {
    function free(uint256 amount) external returns (bool);
}

interface IChiToken {
    function free(uint256 amount) external returns (uint256);
}

/// @notice Reconstruction of mainnet 0xe33c8e3a0d14a81f0dd7e174830089e82f65fc85.
contract Executor {
    uint256 private constant GAS_DATA = 12;
    uint256 private constant GAS_REFUND = 30000;

    // Slot 0 holds the library registry. The refund routines separately use
    // slots 50 and 51 for the consumed and created child-contract counters.
    mapping(uint256 => address) private libraries;

    receive() external payable {}

    // Packed calldata:
    //   bytes 0..4: refund mode, first library ID, first argument count,
    //               second library ID, second argument count;
    //   bytes 5..20: two quote selectors followed by two execution selectors;
    //   byte 21 onward: the first and second argument lists, in 32-byte words.
    // Quote calls return an amount and the number of refund units already used.
    fallback() external {
        uint256 gasStart = gasleft();
        uint256 balanceStart = address(this).balance;
        uint256 refunds = 0;
        checkCaller();
        checkGasLimit();

        uint256 input;
        assembly { input := calldataload(0) }
        uint256 header = input;
        input = input * 256;
        address firstLibrary = libraries[input >> 248];
        input = input * 256;
        uint256 firstLength = input >> 248;
        input = input * 256;
        address secondLibrary = libraries[input >> 248];
        input = input * 256;
        uint256 secondLength = input >> 248;
        uint256 firstQuote = 0;
        assembly {
            let ptr := mload(64)
            calldatacopy(ptr, 5, 4)
            calldatacopy(add(ptr, 4), 21, mul(firstLength, 32))
            let success := delegatecall(gas(), firstLibrary, ptr, add(4, mul(firstLength, 32)), 0, 64)
            firstQuote := mload(0)
            refunds := add(refunds, mload(32))
            switch success
            case 0 { revert(0, 0) }
        }
        if (firstQuote > 0) {
            if (secondLibrary != address(0)) {
                uint256 secondQuote;
                assembly {
                    let ptr := mload(64)
                    calldatacopy(ptr, 9, 4)
                    calldatacopy(add(ptr, 4), add(21, mul(firstLength, 32)), mul(secondLength, 32))
                    let success := delegatecall(gas(), secondLibrary, ptr, add(4, mul(secondLength, 32)), 0, 64)
                    secondQuote := mload(0)
                    refunds := add(refunds, mload(32))
                    switch success
                    case 0 { revert(0, 0) }
                }
                if (secondQuote > 0) {
                    // The last argument of each list is its requested amount.
                    // Reduce the first quote when the second proportional fill
                    // is smaller, using the original 18-decimal arithmetic.
                    assembly {
                        let firstRatio := div(mul(firstQuote, 1000000000000000000), calldataload(sub(mul(firstLength, 32), 11)))
                        let secondRatio := div(mul(secondQuote, 1000000000000000000), calldataload(sub(mul(add(firstLength, secondLength), 32), 11)))
                        switch lt(secondRatio, firstRatio)
                        case 1 {
                            firstQuote := div(mul(calldataload(sub(mul(firstLength, 32), 11)), secondRatio), 1000000000000000000)
                        }
                    }
                    assembly {
                        let ptr := mload(64)
                        calldatacopy(ptr, 13, 4)
                        calldatacopy(add(ptr, 4), 21, mul(firstLength, 32))
                        mstore(add(add(ptr, 4), sub(mul(firstLength, 32), 32)), firstQuote)
                        let success := delegatecall(gas(), firstLibrary, ptr, add(4, mul(firstLength, 32)), 0, 0)
                        switch success
                        case 0 { revert(0, 0) }
                    }
                    assembly {
                        let ptr := mload(64)
                        calldatacopy(ptr, 17, 4)
                        calldatacopy(add(ptr, 4), add(21, mul(firstLength, 32)), mul(secondLength, 32))
                        mstore(add(add(ptr, 4), sub(mul(secondLength, 32), 32)), secondQuote)
                        let success := delegatecall(gas(), secondLibrary, ptr, add(4, mul(secondLength, 32)), 0, 0)
                        switch success
                        case 0 { revert(0, 0) }
                    }
                } else {
                    refunds = 0;
                }
            } else {
                assembly {
                    let ptr := mload(64)
                    calldatacopy(ptr, 13, 4)
                    calldatacopy(add(ptr, 4), 21, mul(firstLength, 32))
                    mstore(add(add(ptr, 4), sub(mul(firstLength, 32), 32)), firstQuote)
                    let success := delegatecall(gas(), firstLibrary, ptr, add(4, mul(firstLength, 32)), 0, 0)
                    switch success
                    case 0 { revert(0, 0) }
                }
            }
        } else {
            refunds = 0;
        }
        require(address(this).balance >= balanceStart);
        if ((header & (uint256(255) << 248)) != 0) {
            uint256 amount = subtractFloor(
                msg.data.length * GAS_DATA + gasStart - gasleft() + 21000,
                refunds * GAS_REFUND
            );
            assembly {
                amount := add(div(add(amount, 2730), 42000), 1)
            }
            // Modes 1, 2 and 3 consume local children, GST2 and CHI respectively.
            if (amount > 0) {
                if ((header & (uint256(255) << 248)) == 0x0100000000000000000000000000000000000000000000000000000000000000) {
                    freeStorage(amount);
                } else if ((header & (uint256(255) << 248)) == 0x0200000000000000000000000000000000000000000000000000000000000000) {
                    IGasToken token = IGasToken(0x0000000000b3F879cb30FE243b4Dfee438691c04);
                    token.free(amount);
                } else if ((header & (uint256(255) << 248)) == 0x0300000000000000000000000000000000000000000000000000000000000000) {
                    IChiToken token = IChiToken(0x0000000000004946c0e9F43F4Dee607b0eF1fA1c);
                    token.free(amount);
                }
            }
        }
    }

    function checkCaller() private view {
        if (msg.sender == 0xfF1b9745f68F84F036E5e92c920038d895FB701A) return;
        if (msg.sender == 0xFF28319a7cD2136ea7283E7cDb0675B50AC29Dd2) return;
        if (msg.sender == 0xFF3769cdBD31893EF1b10A01EE0d8bD1f3773899) return;
        if (msg.sender == 0xff49432a1Ea8ac6d12285099ba426d1F16f23c8d) return;
        if (msg.sender == 0xfF59364722A4622A8D33623548926375B1B07767) return;
        if (msg.sender == 0xff6d62bc882c2Fca5Af5CBFe1e6C10b97Ba251A4) return;
        if (msg.sender == 0xfF7Baf00edF054E249e9f498aa51d1934B8d3526) return;
        if (msg.sender == 0xfF86C0AA0Cc44C3B054C5FDb25F85d555C1d2C3A) return;
        if (msg.sender == 0xff910355ad1D3d12E8Be75a512553e479726ab45) return;
        if (msg.sender == 0xFFA5bFe92B6791DAd23c7837abb790b48C2F8995) return;
        if (msg.sender == 0xFFbFDb803D38D794B5785eE0ac09F83b429d11b5) return;
        if (msg.sender == 0xFFCdfD98c455c29818697Ab2eEaFccBc4e59Fd3D) return;
        if (msg.sender == 0xFfdcE1aE835d35Bb603c95163e510Bb2604a1A41) return;
        if (msg.sender == 0xffE1c5696d924438fba5274d7B5D8fFa29239a6f) return;
        if (msg.sender == 0xFfF66732389866aeaF8f7305Da53f442c29e1b8F) return;
        if (msg.sender == 0xfFF804bd7487B4E2AaDb32Def0Efc9c3127687A2) return;
        if (msg.sender == 0xffFb0526a6EB87E85Ba0bacB38Dd5b53e9bFC097) return;
        if (msg.sender == 0xfffc4a1C98687254c7CF6B1A3Bc27db464f3600B) return;
        if (msg.sender == 0xfFFDcbE1e77fBF1D0Ba78FC39ce4aB0BF5c9f94C) return;
        if (msg.sender == 0xfFFef0974279825a633a295D7eBc3f7afEB33c17) return;
        if (msg.sender == 0x21F179DF331CdC8583373Ca5925bf386880Cf49e) return;
        if (msg.sender == 0x228E402a8eEEDD5D1062287BFb1fa0C87DF6F69C) return;
        if (msg.sender == 0x23e28b5ADbDF08319b4919471cdB0551f0c64dFE) return;
        if (msg.sender == 0x24DF3880DDE1F005548ba9334547D7F317F13D29) return;
        if (msg.sender == 0x2560A6B230BADBAC68cb6667E202cF0C1CaA17B7) return;
        if (msg.sender == 0x26AFD91411226d4c2A13b8c8b5547cb6aC1c6cDC) return;
        if (msg.sender == 0x2762C99F14E987EC71346e33735959B7D9180311) return;
        if (msg.sender == 0x2886F28a2c58a3DDF7A4847ceD88720125D63b80) return;
        if (msg.sender == 0x299DB3A6e900681C2436417eF8d13d2AF0531f7E) return;
        if (msg.sender == 0x30906C083E2ad69c9dcC5b753b86a14f7065d22b) return;
        if (msg.sender == 0xFfff46E05A09314DaAE9176FC32Dba0f4172DcDB) return;
        revert();
    }

    function checkGasLimit() private view {
        require(block.gaslimit <= 40000000);
    }

    function subtractFloor(uint256 a, uint256 b) private pure returns (uint256) {
        if (b >= a) {
            return 0;
        } else {
            return a - b;
        }
    }

    // Reconstruct CREATE addresses from RLP(address(this), nonce). These
    // overlapping memory writes and independent branches reproduce the original
    // child lookup for the different nonce lengths.
    function freeStorage(uint256 amount) private {
        assembly {
            let freed := sload(50)
            let total := sload(51)
            if gt(add(sub(total, freed), 1), amount) {
                for { let i := add(freed, 1) } lt(i, add(add(freed, amount), 1)) { i := add(i, 1) } {
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
                sstore(50, add(amount, freed))
            }
        }
    }

    // Registry IDs begin at one; entries beyond this list are left untouched.
    function setLibraries(address[] calldata entries) external {
        checkCaller();
        checkGasLimit();
        uint256 length = entries.length;
        for (uint256 i = 1; i < length + 1; i++) {
            libraries[i] = entries[i - 1];
        }
    }

    function checkStorage() external view returns (uint256 result) {
        assembly { result := sub(sload(51), sload(50)) }
    }

    function withdraw(uint256 amount) external {
        checkCaller();
        checkGasLimit();
        if (amount > 0) {
            msg.sender.transfer(amount);
        }
    }

    function withdrawTokens(address tokenAddress) external {
        checkCaller();
        checkGasLimit();
        IERC20 token = IERC20(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        if (balance > 0) {
            require(token.transfer(msg.sender, balance));
        }
    }

    // Deploy 53 children using the original compact initialization template.
    // Each child's runtime permits its creator to trigger SELFDESTRUCT.
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

    function tokenFallback(address, uint256, bytes calldata) external {}

    // The amount is a switch: zero clears approval; nonzero grants the maximum.
    function approve(address tokenAddress, address spender, uint256 amount) external {
        checkCaller();
        checkGasLimit();
        IERC20 token = IERC20(tokenAddress);
        if (token.allowance(address(this), spender) > 0) {
            token.approve(spender, 0);
        }
        if (amount > 0) {
            token.approve(spender, uint256(-1));
        }
    }

    function cancel() external {
        checkCaller();
        checkGasLimit();
        freeStorage(1);
    }
}
