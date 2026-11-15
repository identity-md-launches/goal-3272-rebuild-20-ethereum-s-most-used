// Rebuilt by the imd.fun swarm
// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

interface IERC20 {
    function transfer(address to, uint256 amount) external;
    function approve(address spender, uint256 amount) external;
}

interface IWETH {
    function deposit() external payable;
    function withdraw(uint256 amount) external;
    function approve(address spender, uint256 amount) external;
}

interface IUniswapV3Pool {
    function slot0() external view returns (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, uint16 observationCardinality, uint16 observationCardinalityNext, uint8 feeProtocol, bool unlocked);
    function swap(address recipient, bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96, bytes calldata data) external returns (int256 amount0, int256 amount1);
    function mint(address recipient, int24 tickLower, int24 tickUpper, uint128 amount, bytes calldata data) external returns (uint256 amount0, uint256 amount1);
    function burn(int24 tickLower, int24 tickUpper, uint128 amount) external returns (uint256 amount0, uint256 amount1);
    function collect(address recipient, int24 tickLower, int24 tickUpper, uint128 amount0Requested, uint128 amount1Requested) external returns (uint128 amount0, uint128 amount1);
}

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function swap(uint256 amount0Out, uint256 amount1Out, address to, bytes calldata data) external;
}

interface ICurvePool {
    function balances(uint256 i) external view returns (uint256);
}

contract MEVBot {
    address internal owner;
    mapping(address => bool) internal whitelist;

    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address internal constant V3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    bytes32 internal constant V3_INIT_CODE_HASH = 0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54;
    address internal constant UNISWAP_V2_FACTORY = 0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f;
    bytes32 internal constant UNISWAP_V2_INIT_CODE_HASH = 0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f;
    address internal constant SUSHISWAP_FACTORY = 0xC0AEe478e3658e2610c5F7A4A2E1777cE9e4f2Ac;
    bytes32 internal constant SUSHISWAP_INIT_CODE_HASH = 0xe18a34eb0e04b04f7a0ac29a6e80748dca96319b42c54d679cb821dca90c6303;
    address internal constant SHIBASWAP_FACTORY = 0x115934131916C8b277DD010Ee02de363c09d037c;
    bytes32 internal constant SHIBASWAP_INIT_CODE_HASH = 0x65d1a3b1e46c6e4f1be1ad5f99ef14dc488ae0549dc97db9b30afe2241ce1c7a;

    constructor() {
        owner = msg.sender;
        IWETH(WETH).approve(WETH, type(uint256).max);
    }

    receive() external payable {}

    fallback() external payable {
        if (msg.sig == bytes4(0xfa461e33)) {
            uniswapV3SwapCallback();
        } else if (msg.sig < 0x00000010) {
            checkCaller();
            v3Actions();
        } else if (msg.sig < 0x00000020) {
            checkCaller();
            v2Actions();
        } else if (msg.sig < 0x00000030) {
            checkCaller();
            curveActions();
        } else if (msg.sig < 0x00000040) {
            checkCaller();
            utilityActions();
        } else if (msg.sig < 0x00000050) {
            require(msg.sender == owner, "R");
            ownerActions();
        } else {
            externalActions();
        }
    }

    function uniswapV3SwapCallback() internal {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        int256 amount0Delta;
        int256 amount1Delta;
        assembly {
            tokenIn := shr(96, calldataload(0x84))
            tokenOut := shr(96, calldataload(0x98))
            fee := shr(232, calldataload(0xac))
            amount0Delta := calldataload(0x04)
            amount1Delta := calldataload(0x24)
        }
        if (tokenIn < tokenOut) {
            require(msg.sender == address(uint160(uint256(keccak256(abi.encodePacked(hex"ff1f98431c8ad98523631ae4a59f267346ea31f984", keccak256(abi.encode(tokenIn, tokenOut, fee)), V3_INIT_CODE_HASH))))), "P");
            IERC20(tokenIn).transfer(msg.sender, uint256(amount0Delta));
        } else {
            require(msg.sender == address(uint160(uint256(keccak256(abi.encodePacked(hex"ff1f98431c8ad98523631ae4a59f267346ea31f984", keccak256(abi.encode(tokenOut, tokenIn, fee)), V3_INIT_CODE_HASH))))), "P");
            IERC20(tokenIn).transfer(msg.sender, uint256(amount1Delta));
        }
    }

    function checkCaller() internal view {
        if (msg.sender < 0x86603e93BcaF1154FF346c96AE381320a156fd5e) {
            if (msg.sender < 0x444bb0F26217D513e03B4524766C7B8EA981e43A) {
                if (msg.sender < 0x1ECC89fd4fc4DEd8543204854aB4596AEc69eB47) {
                    if (msg.sender < 0x14C1F31577c61792AAfC056d87A027BE4D2ba22d) {
                        if (msg.sender < 0x0B916dA0242E20A339d64992f1ad4A77Fcd320a6) {
                            if (msg.sender < 0x098eb4CE36c2227f603D9A205CF36ACF813aC433) {
                                if (msg.sender == 0x0317692df5BFFc48D6372ac7Da5f9A4354fb003a) return;
                                if (msg.sender == 0x07Ff5Cbf35B4E5D6B598170E3BAfb3523d766fE5) return;
                            } else {
                                if (msg.sender == 0x098eb4CE36c2227f603D9A205CF36ACF813aC433) return;
                                if (msg.sender == 0x0A7642Ad1fe33Ff77948F6113e54dFC4502EFE5d) return;
                            }
                        } else {
                            if (msg.sender < 0x0D5a17fb4a430512a516F6c633CC8E7A3A351d79) {
                                if (msg.sender == 0x0B916dA0242E20A339d64992f1ad4A77Fcd320a6) return;
                                if (msg.sender == 0x0ce669be6097eDc110A598c13917fc3598B466F4) return;
                            } else {
                                if (msg.sender == 0x0D5a17fb4a430512a516F6c633CC8E7A3A351d79) return;
                                if (msg.sender == 0x102D2158C012a51139eb03989B1049b111046305) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0x1a68FCF9B38986d31ec888c9683E1c8b57cE1dF3) {
                            if (msg.sender < 0x18fDc4724EED5B84F17B2363494FEc2d4Aa99744) {
                                if (msg.sender == 0x14C1F31577c61792AAfC056d87A027BE4D2ba22d) return;
                                if (msg.sender == 0x17Abf903a6Ef9f09944EC4E39D1d7160a57b15df) return;
                            } else {
                                if (msg.sender == 0x18fDc4724EED5B84F17B2363494FEc2d4Aa99744) return;
                                if (msg.sender == 0x19D5750d7c5f8E359B53Cb1e4892E536BD54fC82) return;
                            }
                        } else {
                            if (msg.sender < 0x1d3BBd9B9978252e2fA5c830C47B63a72B8509FE) {
                                if (msg.sender == 0x1a68FCF9B38986d31ec888c9683E1c8b57cE1dF3) return;
                                if (msg.sender == 0x1B57262A312E75f62Ac0D72005F2C721b734cBD2) return;
                            } else {
                                if (msg.sender == 0x1d3BBd9B9978252e2fA5c830C47B63a72B8509FE) return;
                                if (msg.sender == 0x1dE9dD46a627b108c10c147649A3C385a8228430) return;
                            }
                        }
                    }
                } else {
                    if (msg.sender < 0x2B4cdBCf60F009889e88B1982f1D1F9CE8fD2233) {
                        if (msg.sender < 0x23E85c1d8bFcD8BfDe5128F6d47D671A3E52d359) {
                            if (msg.sender < 0x226B125e09b30ADe6B509BE7CcF88dcc0c0d8c98) {
                                if (msg.sender == 0x1ECC89fd4fc4DEd8543204854aB4596AEc69eB47) return;
                                if (msg.sender == 0x200d857951edE78f1231f5360E411Dac42567AEE) return;
                            } else {
                                if (msg.sender == 0x226B125e09b30ADe6B509BE7CcF88dcc0c0d8c98) return;
                                if (msg.sender == 0x22C6711a9283EE796eBCEaaCf3647D5531c18Db7) return;
                            }
                        } else {
                            if (msg.sender < 0x28dA618e650a83B78098f7ea0ac2113543b5B5dB) {
                                if (msg.sender == 0x23E85c1d8bFcD8BfDe5128F6d47D671A3E52d359) return;
                                if (msg.sender == 0x287d56419711eD96F8AAb78aDB73Cd89B3F2e43d) return;
                            } else {
                                if (msg.sender == 0x28dA618e650a83B78098f7ea0ac2113543b5B5dB) return;
                                if (msg.sender == 0x297d69af5D2C5449FFF1F0779878470756F59e09) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0x33F88e1956f4C1997e53c5e48e737494B56fa3Af) {
                            if (msg.sender < 0x3113548F0Fd2a6489Be07A0884fCcEBC97a8B956) {
                                if (msg.sender == 0x2B4cdBCf60F009889e88B1982f1D1F9CE8fD2233) return;
                                if (msg.sender == 0x2F4Ae1436D26340CcC128610D6d2835f5D15B3c8) return;
                            } else {
                                if (msg.sender == 0x3113548F0Fd2a6489Be07A0884fCcEBC97a8B956) return;
                                if (msg.sender == 0x33CEF21EB6068ebfCf70C7404eFb8aAa08cAD388) return;
                            }
                        } else {
                            if (msg.sender < 0x3C34B0845eC371E257100d8716358D3Aaf9B4950) {
                                if (msg.sender == 0x33F88e1956f4C1997e53c5e48e737494B56fa3Af) return;
                                if (msg.sender == 0x3a433fB0835411c774108DC58b28140F1c37FFD2) return;
                            } else {
                                if (msg.sender == 0x3C34B0845eC371E257100d8716358D3Aaf9B4950) return;
                                if (msg.sender == 0x441ff331F4F6B996b1095e72860641adD0260e3E) return;
                            }
                        }
                    }
                }
            } else {
                if (msg.sender < 0x6Cffc7fe15CAA05078e55c2EDE55FBBBcceEBc84) {
                    if (msg.sender < 0x5cF12b07f7575A1958F97F115E93159fB980845d) {
                        if (msg.sender < 0x552ed1312F87EE679af33e4B8fBde9A2cBA3626f) {
                            if (msg.sender < 0x45506Db839658030e85B0b8ff55bF2e40C4a75b7) {
                                if (msg.sender == 0x444bb0F26217D513e03B4524766C7B8EA981e43A) return;
                                if (msg.sender == 0x44d5f3526d13dD97f6C9BB58C6AeDD275290A535) return;
                            } else {
                                if (msg.sender == 0x45506Db839658030e85B0b8ff55bF2e40C4a75b7) return;
                                if (msg.sender == 0x46E30A3323daeEA6EE19a88E0Dd9E5ac307C6Aa4) return;
                            }
                        } else {
                            if (msg.sender < 0x5A21DA3F8002cA5aE70a3Bf5Bf4FAb139939403b) {
                                if (msg.sender == 0x552ed1312F87EE679af33e4B8fBde9A2cBA3626f) return;
                                if (msg.sender == 0x5848BD7506171673A626257Bee5414c277F9706b) return;
                            } else {
                                if (msg.sender == 0x5A21DA3F8002cA5aE70a3Bf5Bf4FAb139939403b) return;
                                if (msg.sender == 0x5b9f3E16d980Eb14D0f54Dc15aA79af6a983F269) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0x63B7F7C47F5410d3ce86A715dF97F46283187167) {
                            if (msg.sender < 0x608B724283F1DDeC86D8F6d4F7F6F51964E8b18D) {
                                if (msg.sender == 0x5cF12b07f7575A1958F97F115E93159fB980845d) return;
                                if (msg.sender == 0x5Fdaab01e258342Cb4C972b658aE9a5437Dfb277) return;
                            } else {
                                if (msg.sender == 0x608B724283F1DDeC86D8F6d4F7F6F51964E8b18D) return;
                                if (msg.sender == 0x62FB2AD2DD89DdFd743310A67030c713ABAd2B1F) return;
                            }
                        } else {
                            if (msg.sender < 0x6c870DAb9D3D1C038aeA007D9375fC7bd696759e) {
                                if (msg.sender == 0x63B7F7C47F5410d3ce86A715dF97F46283187167) return;
                                if (msg.sender == 0x66D6B5ef907f5581fcd2d0bdBCA52945BC6dEb7E) return;
                            } else {
                                if (msg.sender == 0x6c870DAb9D3D1C038aeA007D9375fC7bd696759e) return;
                                if (msg.sender == 0x6C96769A08ddEfa92e06dE0a32089272c57F79b2) return;
                            }
                        }
                    }
                } else {
                    if (msg.sender < 0x7b018835d45F02Cac14FE9B38F5AaE2F5205200E) {
                        if (msg.sender < 0x73f858acD93866902f59A8b53Ab5f8aE1824c74b) {
                            if (msg.sender < 0x707fd8f69E3296eFC7558b94E69b74A41E040E2C) {
                                if (msg.sender == 0x6Cffc7fe15CAA05078e55c2EDE55FBBBcceEBc84) return;
                                if (msg.sender == 0x6E1D6334d6d37A5E9aCAD13c6cB5e5927D468937) return;
                            } else {
                                if (msg.sender == 0x707fd8f69E3296eFC7558b94E69b74A41E040E2C) return;
                                if (msg.sender == 0x71D4E376AF71578AD11b5de426e609C601618f64) return;
                            }
                        } else {
                            if (msg.sender < 0x77cc581B72f3173B85b8C76eEE00414990c79237) {
                                if (msg.sender == 0x73f858acD93866902f59A8b53Ab5f8aE1824c74b) return;
                                if (msg.sender == 0x74678B900d450bd0e5FaEa87dba8d49C77c79527) return;
                            } else {
                                if (msg.sender == 0x77cc581B72f3173B85b8C76eEE00414990c79237) return;
                                if (msg.sender == 0x789cDfE9F8AFE21717bc26Fd3f450f76fb37478a) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0x817E5E6b627FD6A7aFB7B913f05A279C2a736152) {
                            if (msg.sender < 0x7Ee3022dc45eFbbc284740e1FbF9611755da9B9a) {
                                if (msg.sender == 0x7b018835d45F02Cac14FE9B38F5AaE2F5205200E) return;
                                if (msg.sender == 0x7e3865741b7D703AE63030ADcB9576d38B41d6Ab) return;
                            } else {
                                if (msg.sender == 0x7Ee3022dc45eFbbc284740e1FbF9611755da9B9a) return;
                                if (msg.sender == 0x7F73832bcdEaaCb3a971C41a0cc13423057953bE) return;
                            }
                        } else {
                            if (msg.sender < 0x83c553bc43f4062c1516D1B65De10F5e8D225D70) {
                                if (msg.sender == 0x817E5E6b627FD6A7aFB7B913f05A279C2a736152) return;
                                if (msg.sender == 0x83701d5faDc493fbc770aFfe6d6F3Af92c06eD26) return;
                            } else {
                                if (msg.sender == 0x83c553bc43f4062c1516D1B65De10F5e8D225D70) return;
                                if (msg.sender == 0x84a237cc082675852D133B91F98B2dFB5255254a) return;
                            }
                        }
                    }
                }
            }
        } else {
            if (msg.sender < 0xb77168354546DcFE69511eD375F1E1259CDd4DcA) {
                if (msg.sender < 0xab825b752143B0aFF895a353f598C1661a3A155B) {
                    if (msg.sender < 0x9EcC4a823841262903B342d08468595196F6a63e) {
                        if (msg.sender < 0x92824d144c6543f70A649b2C3E7596612375FD4D) {
                            if (msg.sender < 0x8dAB36Ee57328E700380D1fD6588BC3De5Fe8Ec3) {
                                if (msg.sender == 0x86603e93BcaF1154FF346c96AE381320a156fd5e) return;
                                if (msg.sender == 0x892133B6D73Ff2B6cfe183588ad3FAed19a25b81) return;
                            } else {
                                if (msg.sender == 0x8dAB36Ee57328E700380D1fD6588BC3De5Fe8Ec3) return;
                                if (msg.sender == 0x8dfDFC470104a7Afc12e175B2Eef4025bdEa3a64) return;
                            }
                        } else {
                            if (msg.sender < 0x9Cacc0DF7CA15E4B9029Ab352aa0aF110717fB8F) {
                                if (msg.sender == 0x92824d144c6543f70A649b2C3E7596612375FD4D) return;
                                if (msg.sender == 0x9aB9742Af41EF177e0d6136b0f4094aC2f2Df1Bf) return;
                            } else {
                                if (msg.sender == 0x9Cacc0DF7CA15E4B9029Ab352aa0aF110717fB8F) return;
                                if (msg.sender == 0x9cf269bc104648718922689DF44d7AEeb6F33Db7) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0xA231655e7b9Ec81903788e94eA68c9CD446D9662) {
                            if (msg.sender < 0xa10E55A8E6A1ba909dA30935910Bc8819eEBcb28) {
                                if (msg.sender == 0x9EcC4a823841262903B342d08468595196F6a63e) return;
                                if (msg.sender == 0xA04303464D48Be64EE0Fc51Fa924cfDcAbDbdAdE) return;
                            } else {
                                if (msg.sender == 0xa10E55A8E6A1ba909dA30935910Bc8819eEBcb28) return;
                                if (msg.sender == 0xa1b9cb05Bdd0962C63076bAbb8a12f55F5Dbe487) return;
                            }
                        } else {
                            if (msg.sender < 0xA62AC73C7CCeA4cA19B7E5e053Ac653CcfB6c89C) {
                                if (msg.sender == 0xA231655e7b9Ec81903788e94eA68c9CD446D9662) return;
                                if (msg.sender == 0xa5e24801F6fA2685A1cEf37f388E1AAE77c37aa3) return;
                            } else {
                                if (msg.sender == 0xA62AC73C7CCeA4cA19B7E5e053Ac653CcfB6c89C) return;
                                if (msg.sender == 0xA96d374262272675da83ca4Bf1DCC7BF9273e33D) return;
                            }
                        }
                    }
                } else {
                    if (msg.sender < 0xB1520B468ec6A426B65509fD8B65feB10EC4d926) {
                        if (msg.sender < 0xaEb05c104E3BF892cF66F0DCd0a01B96dB6ac145) {
                            if (msg.sender < 0xAE465fc293ae122d5609dbbFdb8990fE1a0d6643) {
                                if (msg.sender == 0xab825b752143B0aFF895a353f598C1661a3A155B) return;
                                if (msg.sender == 0xaD3019DFb0094626a779D56077A35E52591ebCA1) return;
                            } else {
                                if (msg.sender == 0xAE465fc293ae122d5609dbbFdb8990fE1a0d6643) return;
                                if (msg.sender == 0xAE4Bc54Af752962AfF29e329BE8fE724A56934E4) return;
                            }
                        } else {
                            if (msg.sender < 0xB0804b228C1C1449cDc94DD16fc8910421F45Df1) {
                                if (msg.sender == 0xaEb05c104E3BF892cF66F0DCd0a01B96dB6ac145) return;
                                if (msg.sender == 0xb0305E86B143fe018663a5cE6a3781FfCcEcb719) return;
                            } else {
                                if (msg.sender == 0xB0804b228C1C1449cDc94DD16fc8910421F45Df1) return;
                                if (msg.sender == 0xB0a7b3b335C82D9B7aFB54966C85f1Cf0663665e) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0xB37eff819cd627055F00Fa3DBCaCE046d4A7876f) {
                            if (msg.sender < 0xb18b2D589f5258D1D99b7645fd94bd1F2DB46938) {
                                if (msg.sender == 0xB1520B468ec6A426B65509fD8B65feB10EC4d926) return;
                                if (msg.sender == 0xB171E771ac8136115e05De5ACeEb59805708Ed39) return;
                            } else {
                                if (msg.sender == 0xb18b2D589f5258D1D99b7645fd94bd1F2DB46938) return;
                                if (msg.sender == 0xB32560386c3aFc53f9014bb516f4b627541C6193) return;
                            }
                        } else {
                            if (msg.sender < 0xb6cdCeF317604201A5EB24c897B81046b0F39ea6) {
                                if (msg.sender == 0xB37eff819cd627055F00Fa3DBCaCE046d4A7876f) return;
                                if (msg.sender == 0xB58b63027276Fc6eC716d6dAc9952BAf0B7612BB) return;
                            } else {
                                if (msg.sender == 0xb6cdCeF317604201A5EB24c897B81046b0F39ea6) return;
                                if (msg.sender == 0xB7092e36FE9ad8dB424Bc568e3877F01441f37BE) return;
                            }
                        }
                    }
                }
            } else {
                if (msg.sender < 0xD9aDa041a9B9DC8D2B32e5269712567dA3C908e3) {
                    if (msg.sender < 0xcaf212E2909284B7ECF1315516aAb44E0B5Bf8fc) {
                        if (msg.sender < 0xc3B890CAB725A1f2646459Fdb6C9CAec3aA8f984) {
                            if (msg.sender < 0xc0F4d3e2B06B77379bcbeeCC8a09C49a4D92829f) {
                                if (msg.sender == 0xb77168354546DcFE69511eD375F1E1259CDd4DcA) return;
                                if (msg.sender == 0xBFFa506CAC8E6a74EF7E253FF6876881a457c892) return;
                            } else {
                                if (msg.sender == 0xc0F4d3e2B06B77379bcbeeCC8a09C49a4D92829f) return;
                                if (msg.sender == 0xC182Bd3C0a96B8765358A54D77D56C2cB1aF8aac) return;
                            }
                        } else {
                            if (msg.sender < 0xC91e8EE9A1a4eD279dB73f7a499531C753D29df9) {
                                if (msg.sender == 0xc3B890CAB725A1f2646459Fdb6C9CAec3aA8f984) return;
                                if (msg.sender == 0xc8eC8f91A369DFCF1EA6142Ff26f98985aA64556) return;
                            } else {
                                if (msg.sender == 0xC91e8EE9A1a4eD279dB73f7a499531C753D29df9) return;
                                if (msg.sender == 0xC978303655CFE6BC415FF657f0cF63434cFA732E) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0xD39c0d8ee9FbB78839cac0630b520B7E2263E126) {
                            if (msg.sender < 0xD160E36097e5FE5CE5C3f02867216845c0a255cd) {
                                if (msg.sender == 0xcaf212E2909284B7ECF1315516aAb44E0B5Bf8fc) return;
                                if (msg.sender == 0xccaA726829009cd8E13bC288d8e06ebc53A9338e) return;
                            } else {
                                if (msg.sender == 0xD160E36097e5FE5CE5C3f02867216845c0a255cd) return;
                                if (msg.sender == 0xD2006fcC22DF4a674839b357Ba1525cCb05efe92) return;
                            }
                        } else {
                            if (msg.sender < 0xd74e2D68510786311F05A898EA6FA7A36727eE55) {
                                if (msg.sender == 0xD39c0d8ee9FbB78839cac0630b520B7E2263E126) return;
                                if (msg.sender == 0xd5F8599710A3d1403587931B7770e6677b4e9821) return;
                            } else {
                                if (msg.sender == 0xd74e2D68510786311F05A898EA6FA7A36727eE55) return;
                                if (msg.sender == 0xd820187CAE7dbBfb8e12891bb55b8A352D463E60) return;
                            }
                        }
                    }
                } else {
                    if (msg.sender < 0xea9D00b3e0Aa90D6393Ecb62e7F59cAd086B3A8c) {
                        if (msg.sender < 0xE1a7775191A44dB2Cff011c7B6a0E6aEf1a7255D) {
                            if (msg.sender < 0xdE228Ad778000F44cdae772482ed53302BcCF840) {
                                if (msg.sender == 0xD9aDa041a9B9DC8D2B32e5269712567dA3C908e3) return;
                                if (msg.sender == 0xDb988d8651217155E4B18096A5a7F28c287917ef) return;
                            } else {
                                if (msg.sender == 0xdE228Ad778000F44cdae772482ed53302BcCF840) return;
                                if (msg.sender == 0xDfa34B96790BC57EB23982072cf8b186D4936ca0) return;
                            }
                        } else {
                            if (msg.sender < 0xE9759380FBB6b5Ef999Ba3c267675452f19dE92a) {
                                if (msg.sender == 0xE1a7775191A44dB2Cff011c7B6a0E6aEf1a7255D) return;
                                if (msg.sender == 0xE3F90E9fD46EA7EF19b399EeE1ab27B557CC0d69) return;
                            } else {
                                if (msg.sender == 0xE9759380FBB6b5Ef999Ba3c267675452f19dE92a) return;
                                if (msg.sender == 0xE9F09456aa9a660784b8AC4806E98091aEB71A89) return;
                            }
                        }
                    } else {
                        if (msg.sender < 0xf50814D1E060Ef124f052f6C7Df8a2a0Aadadd83) {
                            if (msg.sender < 0xeE010a7476Bc5ADc88f1Befc68c3b58f27F90419) {
                                if (msg.sender == 0xea9D00b3e0Aa90D6393Ecb62e7F59cAd086B3A8c) return;
                                if (msg.sender == 0xeaE280b314f9891bf9118e4b0CDac18bA6880549) return;
                            } else {
                                if (msg.sender == 0xeE010a7476Bc5ADc88f1Befc68c3b58f27F90419) return;
                                if (msg.sender == 0xef71d6C646E4c109cB8E1DF89F3f33c2E3A5A91C) return;
                            }
                        } else {
                            if (msg.sender < 0xF7B989D8afE019aD2358c31A035DD362cBA411b8) {
                                if (msg.sender == 0xf50814D1E060Ef124f052f6C7Df8a2a0Aadadd83) return;
                                if (msg.sender == 0xf5E322fD6fadBeF5D14EAf0F45A809c00739d1E7) return;
                            } else {
                                if (msg.sender == 0xF7B989D8afE019aD2358c31A035DD362cBA411b8) return;
                                if (msg.sender == 0xF92DC08D81900626aC56edf96E2f3802615605F1) return;
                            }
                        }
                    }
                }
            }
        }
        if (whitelist[msg.sender]) return;
        if (msg.sender == owner) return;
        revert("A");
    }

    function v3Actions() internal {
        if (msg.sig == bytes4(0x00000001)) {
            swapV3(address(this), 0);
        } else if (msg.sig == bytes4(0x00000002)) {
            swapV3(address(this), 0);
            uint256 bribe;
            assembly { bribe := calldataload(0x6f) }
            block.coinbase.transfer(bribe);
        } else if (msg.sig == bytes4(0x00000004)) {
            uint160 priceLimit;
            assembly { priceLimit := shr(96, calldataload(0x6f)) }
            swapV3(address(this), priceLimit);
        } else if (msg.sig == bytes4(0x00000005)) {
            address recipient;
            assembly { recipient := shr(96, calldataload(0x6f)) }
            swapV3(recipient, 0);
        } else if (msg.sig == bytes4(0x00000006)) {
            address recipient;
            uint256 bribe;
            assembly {
                recipient := shr(96, calldataload(0x6f))
                bribe := calldataload(0x83)
            }
            swapV3(recipient, 0);
            block.coinbase.transfer(bribe);
        } else if (msg.sig == bytes4(0x00000007)) {
            uint160 priceLimit;
            address recipient;
            assembly {
                priceLimit := shr(96, calldataload(0x6f))
                recipient := shr(96, calldataload(0x83))
            }
            swapV3(recipient, priceLimit);
        } else if (msg.sig == bytes4(0x00000008)) {
            mintV3();
        } else if (msg.sig == bytes4(0x00000009)) {
            burnV3();
        } else if (msg.sig == bytes4(0x0000000a)) {
            require(msg.value >= block.number, "U");
            burnV3();
            uint256 bribe;
            assembly { bribe := calldataload(0x45) }
            block.coinbase.transfer(bribe);
        }
    }

    function v2Actions() internal {
        if (msg.sig == bytes4(0x00000017)) {
            swapV2(address(this), false);
        } else if (msg.sig == bytes4(0x00000015)) {
            swapV2(address(this), false);
            uint256 bribe;
            assembly { bribe := calldataload(0x6d) }
            block.coinbase.transfer(bribe);
        } else if (msg.sig == bytes4(0x00000011)) {
            swapV2(address(this), true);
        } else if (msg.sig == bytes4(0x00000018)) {
            address recipient;
            assembly { recipient := shr(96, calldataload(0x6d)) }
            swapV2(recipient, false);
        } else if (msg.sig == bytes4(0x00000016)) {
            address recipient;
            uint256 bribe;
            assembly {
                recipient := shr(96, calldataload(0x6d))
                bribe := calldataload(0x81)
            }
            swapV2(recipient, false);
            block.coinbase.transfer(bribe);
        } else if (msg.sig == bytes4(0x00000013)) {
            address recipient;
            assembly { recipient := shr(96, calldataload(0x6d)) }
            swapV2(recipient, true);
        }
    }

    function curveActions() internal {
        if (msg.sig == bytes4(0x00000022)) {
            require(msg.value >= block.number, "U");
            curveCall();
            uint256 bribe;
            assembly { bribe := calldataload(0xbc) }
            block.coinbase.transfer(bribe);
        } else if (msg.sig == bytes4(0x00000021)) {
            curveCall();
        }
    }

    function utilityActions() internal {
        if (msg.sig == bytes4(0x00000031)) {
            wrap();
        } else if (msg.sig == bytes4(0x00000032)) {
            unwrap();
        } else if (msg.sig == bytes4(0x00000033)) {
            delegate();
        } else if (msg.sig == bytes4(0x00000034)) {
            multicall();
        } else if (msg.sig == bytes4(0x00000035)) {
            multicallWithBribe();
        } else if (msg.sig == bytes4(0x00000036)) {
            sendToken();
        } else if (msg.sig == bytes4(0x00000038)) {
            approveToken();
        } else if (msg.sig == bytes4(0x00000037)) {
            sendTokens();
        } else if (msg.sig == bytes4(0x00000039)) {
            approveTokens();
        } else if (msg.sig == bytes4(0x0000003a)) {
            sendEther();
        } else if (msg.sig == bytes4(0x0000003b)) {
            sendEthers();
        }
    }

    function ownerActions() internal {
        if (msg.sig == bytes4(0x00000040)) {
            setOwner();
        } else if (msg.sig == bytes4(0x00000041)) {
            setWhitelist();
        }
    }

    function externalActions() internal {
        if (msg.sig == bytes4(0xd3487997)) {
            uniswapV3MintCallback();
        } else if (msg.sig == bytes4(0x1626ba7e)) {
            isValidSignature();
        }
    }

    function swapV3(address recipient, uint160 sqrtPriceLimitX96) internal {
        int256 amountSpecified;
        uint256 amountLimit;
        address tokenIn;
        address tokenOut;
        uint24 fee;
        bytes calldata path;
        assembly {
            amountSpecified := calldataload(0x04)
            amountLimit := calldataload(0x24)
            tokenIn := shr(96, calldataload(0x44))
            tokenOut := shr(96, calldataload(0x58))
            fee := shr(232, calldataload(0x6c))
            path.offset := 0x44
            path.length := 0x2b
        }
        bool zeroForOne = tokenIn < tokenOut;
        address pool;
        pool = address(uint160(uint256(keccak256(abi.encodePacked(hex"ff1f98431c8ad98523631ae4a59f267346ea31f984", zeroForOne ? keccak256(abi.encode(tokenIn, tokenOut, fee)) : keccak256(abi.encode(tokenOut, tokenIn, fee)), V3_INIT_CODE_HASH)))));
        if (sqrtPriceLimitX96 != 0) {
            (uint160 sqrtPriceX96, , , , , , ) = IUniswapV3Pool(pool).slot0();
            if (zeroForOne) {
                require(sqrtPriceLimitX96 <= sqrtPriceX96);
            } else {
                require(sqrtPriceLimitX96 >= sqrtPriceX96);
            }
        } else {
            require(msg.value >= block.number, "U");
        }
        int256 amountIn;
        int256 amountOut;
        if (zeroForOne) {
            (amountIn, amountOut) = IUniswapV3Pool(pool).swap(recipient, true, amountSpecified, uint160(4295128740), path);
        } else {
            (amountOut, amountIn) = IUniswapV3Pool(pool).swap(recipient, false, amountSpecified, uint160(1461446703485210103287273052203988822378723970341), path);
        }
        if (amountSpecified > 0) {
            require(uint256(-amountOut) >= amountLimit, "S");
        } else {
            require(uint256(amountIn) <= amountLimit, "S");
        }
    }

    function poolFromCalldata() internal pure returns (address) {
        address token0;
        address token1;
        uint24 fee;
        assembly {
            token0 := shr(96, calldataload(0x04))
            token1 := shr(96, calldataload(0x18))
            fee := shr(232, calldataload(0x2c))
        }
        return address(uint160(uint256(keccak256(abi.encodePacked(hex"ff1f98431c8ad98523631ae4a59f267346ea31f984", keccak256(abi.encode(token0, token1, fee)), V3_INIT_CODE_HASH)))));
    }

    function mintV3() internal {
        address token0;
        address token1;
        uint24 fee;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        assembly {
            token0 := shr(96, calldataload(0x04))
            token1 := shr(96, calldataload(0x18))
            fee := shr(232, calldataload(0x2c))
            tickLower := shr(232, calldataload(0x2f))
            tickUpper := shr(232, calldataload(0x32))
            liquidity := shr(128, calldataload(0x35))
        }
        address pool;
        pool = poolFromCalldata();
        IUniswapV3Pool(pool).mint(address(this), tickLower, tickUpper, liquidity, abi.encodePacked(token0, token1, fee));
    }

    function burnV3() internal {
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        assembly {
            tickLower := shr(232, calldataload(0x2f))
            tickUpper := shr(232, calldataload(0x32))
            liquidity := shr(128, calldataload(0x35))
        }
        address pool;
        pool = poolFromCalldata();
        IUniswapV3Pool(pool).burn(tickLower, tickUpper, liquidity);
        IUniswapV3Pool(pool).collect(address(this), tickLower, tickUpper, type(uint128).max, type(uint128).max);
    }

    function swapV2(address recipient, bool checkOutput) internal {
        address tokenIn;
        address tokenOut;
        uint256 amountIn;
        uint256 amountOut;
        uint8 dex;
        assembly {
            tokenIn := shr(96, calldataload(0x04))
            tokenOut := shr(96, calldataload(0x18))
            amountIn := calldataload(0x2c)
            amountOut := calldataload(0x4c)
            dex := shr(248, calldataload(0x6c))
        }
        bool zeroForOne = tokenIn < tokenOut;
        address pair;
        if (dex == uint8(0)) {
            pair = address(uint160(uint256(keccak256(abi.encodePacked(hex"ff5c69bee701ef814a2b6a3edd4b1652cb9cc5aa6f", keccak256(zeroForOne ? abi.encodePacked(tokenIn, tokenOut) : abi.encodePacked(tokenOut, tokenIn)), UNISWAP_V2_INIT_CODE_HASH)))));
        } else if (dex == uint8(1)) {
            pair = address(uint160(uint256(keccak256(abi.encodePacked(hex"ffc0aee478e3658e2610c5f7a4a2e1777ce9e4f2ac", keccak256(zeroForOne ? abi.encodePacked(tokenIn, tokenOut) : abi.encodePacked(tokenOut, tokenIn)), SUSHISWAP_INIT_CODE_HASH)))));
        } else if (dex == uint8(2)) {
            pair = address(uint160(uint256(keccak256(abi.encodePacked(hex"ff115934131916c8b277dd010ee02de363c09d037c", keccak256(zeroForOne ? abi.encodePacked(tokenIn, tokenOut) : abi.encodePacked(tokenOut, tokenIn)), SHIBASWAP_INIT_CODE_HASH)))));
        } else {
            revert("V2ID");
        }
        if (checkOutput) {
            uint256 expected;
            expected = getAmountOut(pair, amountIn, zeroForOne);
            require(expected >= amountOut);
            amountOut = expected;
        } else {
            require(msg.value >= block.number, "U");
        }
        IERC20(tokenIn).transfer(pair, amountIn);
        if (zeroForOne) {
            IUniswapV2Pair(pair).swap(0, amountOut, recipient, "");
        } else {
            IUniswapV2Pair(pair).swap(amountOut, 0, recipient, "");
        }
    }

    function curveCall() internal {
        address pool;
        uint256 expectedBalance;
        bytes calldata data;
        assembly {
            pool := shr(96, calldataload(0x04))
            expectedBalance := calldataload(0x18)
            data.offset := 0x38
            data.length := 0x84
        }
        require(expectedBalance == ICurvePool(pool).balances(0));
        (bool success, ) = pool.call(data);
        require(success);
    }

    function wrap() internal {
        uint256 amount;
        assembly { amount := calldataload(0x04) }
        IWETH(WETH).deposit{value: amount}();
    }

    function unwrap() internal {
        uint256 amount;
        assembly { amount := calldataload(0x04) }
        IWETH(WETH).withdraw(amount);
    }

    function delegate() internal {
        (address target, bytes memory data) = abi.decode(msg.data[4:], (address, bytes));
        (bool success, ) = target.delegatecall(data);
        require(success);
    }

    function multicall() internal {
        (address[] memory targets, bytes[] memory datas) = abi.decode(msg.data[4:], (address[], bytes[]));
        for (uint256 i = 0; i < targets.length; ) {
            (bool success, ) = targets[i].call(datas[i]);
            require(success);
            unchecked { ++i; }
        }
    }

    function multicallWithBribe() internal {
        require(msg.value >= block.number, "U");
        (address[] memory targets, bytes[] memory datas, uint256 bribe) = abi.decode(msg.data[4:], (address[], bytes[], uint256));
        for (uint256 i = 0; i < targets.length; ) {
            (bool success, ) = targets[i].call(datas[i]);
            require(success);
            unchecked { ++i; }
        }
        block.coinbase.transfer(bribe);
    }

    function sendToken() internal {
        address token;
        uint256 amount;
        address to;
        assembly {
            token := shr(96, calldataload(0x04))
            amount := calldataload(0x18)
            to := shr(96, calldataload(0x38))
        }
        require(to != address(0), "Send 0x0");
        IERC20(token).transfer(to, amount);
    }

    function approveToken() internal {
        address token;
        uint256 amount;
        address spender;
        assembly {
            token := shr(96, calldataload(0x04))
            amount := calldataload(0x18)
            spender := shr(96, calldataload(0x38))
        }
        IERC20(token).approve(spender, amount);
    }

    function sendTokens() internal {
        (address[] memory tokens, uint256[] memory amounts, address to) = abi.decode(msg.data[4:], (address[], uint256[], address));
        require(tokens.length == amounts.length, "invalid data");
        require(uint256(uint160(to)) > tokens.length, "invalid recipient");
        require(to != address(0), "Send 0x0");
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20(tokens[i]).transfer(to, amounts[i]);
        }
    }

    function approveTokens() internal {
        (address[] memory tokens, uint256[] memory amounts, address[] memory spenders) = abi.decode(msg.data[4:], (address[], uint256[], address[]));
        require(tokens.length == amounts.length, "invalid data");
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20(tokens[i]).approve(spenders[i], amounts[i]);
        }
    }

    function sendEther() internal {
        uint256 amount;
        address to;
        assembly {
            amount := calldataload(0x04)
            to := shr(96, calldataload(0x24))
        }
        require(to != address(0), "Send 0x0");
        payable(to).transfer(amount);
    }

    function sendEthers() internal {
        (uint256 unwrapAmount, address[] memory recipients, uint256[] memory amounts) = abi.decode(msg.data[4:], (uint256, address[], uint256[]));
        if (unwrapAmount > 0) {
            IWETH(WETH).withdraw(unwrapAmount);
        }
        for (uint256 i = 0; i < recipients.length; i++) {
            payable(recipients[i]).transfer(amounts[i]);
        }
    }

    function setOwner() internal {
        address newOwner;
        assembly { newOwner := shr(96, calldataload(0x04)) }
        owner = newOwner;
    }

    function setWhitelist() internal {
        (address[] memory accounts, bool[] memory allowed) = abi.decode(msg.data[4:], (address[], bool[]));
        require(accounts.length == allowed.length, "invalid data");
        for (uint256 i = 0; i < accounts.length; ++i) {
            whitelist[accounts[i]] = allowed[i];
        }
    }

    function uniswapV3MintCallback() internal {
        address token0;
        address token1;
        uint24 fee;
        uint256 amount0Owed;
        uint256 amount1Owed;
        assembly {
            token0 := shr(96, calldataload(0x84))
            token1 := shr(96, calldataload(0x98))
            fee := shr(232, calldataload(0xac))
            amount0Owed := calldataload(0x04)
            amount1Owed := calldataload(0x24)
        }
        require(msg.sender == address(uint160(uint256(keccak256(abi.encodePacked(hex"ff1f98431c8ad98523631ae4a59f267346ea31f984", keccak256(abi.encode(token0, token1, fee)), V3_INIT_CODE_HASH))))), "P");
        if (amount0Owed > 0) IERC20(token0).transfer(msg.sender, amount0Owed);
        if (amount1Owed > 0) IERC20(token1).transfer(msg.sender, amount1Owed);
    }

    function isValidSignature() internal view {
        (bytes32 hash, bytes memory signature) = abi.decode(msg.data[4:], (bytes32, bytes));
        bytes4 magic;
        if (whitelist[ECDSA.recover(hash, signature)] == true) {
            magic = 0x1626ba7e;
        } else {
            magic = 0xffffffff;
        }
        assembly {
            mstore(0, magic)
            return(0, 0x20)
        }
    }

    function getAmountOut(address pair, uint256 amountIn, bool zeroForOne) internal view returns (uint256 amountOut) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(pair).getReserves();
        uint256 reserveIn;
        uint256 reserveOut;
        if (zeroForOne) {
            (reserveIn, reserveOut) = (reserve0, reserve1);
        } else {
            (reserveIn, reserveOut) = (reserve1, reserve0);
        }
        unchecked {
            uint256 amountInWithFee = amountIn * 997;
            uint256 numerator = amountInWithFee * reserveOut;
            uint256 denominator = reserveIn * 1000 + amountInWithFee;
            amountOut = numerator / denominator;
        }
    }
}
