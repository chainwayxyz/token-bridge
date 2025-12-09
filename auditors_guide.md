- This repository is for achieving a token bridge between two EVM chains using LayerZero. USDC, USDT and WBTC are supported at the moment.

- USDC bridge aims to fully conform to the [bridged USDC standard](https://github.com/circlefin/stablecoin-evm/blob/master/doc/bridged_USDC_standard.md) set by Circle.

- The code is relatively simple, thus the primary focus for internal and external auditors is to ensure full match against the specification of the bridged USDC standard and equivalence with USDT0 for USDT side. For WBTC, WBTCOFT code is verbatim used except the version of imported LayerZero contracts. Regardless, especially the scripts under `/script` except the ones for testing should be thoroughly inspected for security issues. A full understanding of the contracts under `/src` can be obtained without much effort. The contracts under `/for_circle_takeover` are different versions of the USDC bridge contracts for the both ends of the bridge to be used for upgrading the bridge according to the bridged USDC standard. These add the functionality of pausing the bridge, and burning the accumulated USDC for the source chain end of the bridge.

- In all deployment scripts, necessary privileged roles are first assigned to the deployer, then transferred to respective addresses so that the scripts can be run smoothly. Please ensure that the deployer address does not have any privileged roles after the deployment is complete.

- Any on-chain actions described in the bridged USDC standard should have a corresponding script in the `/script` directory. So if you encounter such an action without a script, no matter how trivial it seems, please notify the author(s).

- Annotations are provided for the bridged USDC standard that point to relevant code sections. These annotations can be found in the form of comments to the commit that adds a copy of the standard to the repository. First of these annotations can be accessed [here](https://github.com/chainwayxyz/stablecoin-bridge/commit/f4ef250b402cfccbd3254fdd3362fdd291d78196#r160416214). These annotations are to be exhaustive, but if you find any part of the standard that is not annotated with a code section but it should, please notify the author(s).

- This code tries to achieve a similar objective as [USDT0](https://usdt0.to) as both uses LayerZero to bridge stablecoins. However, the LayerZero integration is almost exactly the same as USDT0, thus the auditors are advised to also review the USDT0 code and compare it with this code. See the [deployments of USDT0 here](https://docs.usdt0.to/technical-documentation/developer). 

    - Use the implementation of [`OAdapterUpgradeable`](https://etherscan.io/address/0xcd979b10a55fcdac23ec785ce3066c6ef8a479a4#code) on Ethereum mainnet as a reference for this codebase's `SourceOFTAdapter` contract.

    - Use the implementation of [`OUpgradeable`](https://unichain.blockscout.com/address/0x13C41AF9e2AdaDB47A55961f6D3B68B41ae36eF9?tab=contract) on Unichain as a reference for this codebase's `DestinationOUSDT` and `DestinationOUSDC` contracts.

    - `DestinationOUSDT` is equivalent to `OUpgradeable` above.

    - `DestinationOUSDC` aims to be similar as much as possible to `DestinationOUSDT` with minimal changes to adapt to USDC's requirements regarding minting and burning.

- For WBTC, the code is mostly a verbatim copy of the WBTCOFT code. The only change is the version of LayerZero contracts being imported as the instances listed below are using an older version of LayerZero contracts. But the changes are minimal and do not affect the logic.
    - Use the implementation of [`WBTCOFT`](https://snowtrace.io/token/0x0555E30da8f98308EdB960aa94C0Db47230d2B9c/contract/code?type=erc20&chainid=43114) on Avalanche as a reference for this codebase's `WBTCOFT` contract.
    - Use the implementation of [`WBTCOFTAdapter`](https://etherscan.io/address/0x0555e30da8f98308edb960aa94c0db47230d2b9c#code) on Ethereum mainnet as a reference for this codebase's `WBTCOFTAdapter` contract.
