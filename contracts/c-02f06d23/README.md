# StrategyExecutor reconstruction

Target: Ethereum mainnet `0x75ab076a00d76478e5fcc21cfd95113802f06d23`.

`StrategyExecutor.sol` contains the reconstructed contract, interfaces, and internal libraries. `build.json` specifies solc `0.8.19+commit.7dd6d404`, optimizer enabled with 999999 runs, viaIR disabled, and Paris EVM semantics. Source names are relative to this directory.

The supplied, SHA-256-verified check exits **0**: runtime **10,177 bytes**, creation **10,555 bytes**, no constructor arguments. The checker excludes the source-dependent metadata hash; this is not a claim that the original source text or metadata was recovered.

Recovered public routing signatures:

| Selector | Signature |
| --- | --- |
| `0x34b9b05f` | `buyUniswapV3(address,address,uint256,uint256)` |
| `0xc9da3165` | `buyUniswapV2(address,address,uint256,uint256)` |
| `0x599a083b` | `sellUniswapV2(address,address,uint256,uint256,uint256)` |
| `0xb270dfff` | `sellUniswapV3(address,address,uint256,uint256,uint256)` |

Buy arguments are token, pair, minimum output, deadline. Sell arguments are token, pair, minimum output, deadline, input amount. The remaining selectors are the owner getter, recovery functions, and Uniswap/Pancake V3 callbacks.

The constructor's chain-dependent wrapped-token and factory addresses and the callback pool initialization hashes were recovered from the supplied bytecode. Inline assembly is confined to the recognizable BytesLib packed-value readers. No deployed bytecode is embedded in the Solidity.

Validation covers bytecode equivalence under the supplied check, not a separate security audit. No deployment or verification submission was performed. Nothing was fabricated, and no implementation work remains for this target under the supplied bytecode criterion.
