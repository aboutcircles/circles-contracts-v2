# Circles Protocol

Circles is a decentralized protocol for creating and distributing fair and social money through personal currencies. Built on the Gnosis Chain, it utilizes smart contracts to manage the creation, distribution, and transfer of personal currencies using the ERC1155 multi-token standard.

## Key Concepts

- **Personal Currencies**: Each individual can mint their own currency at a rate of one Circle per hour.
- **Trust Networks**: Currencies become valuable and transferable through trust relationships between participants.
- **Demurrage**: A 7% annual cost applied to held currencies, encouraging circulation and maintaining equity.

## Features

- Retroactive minting for up to 14 days
- Path-based transactions through trust connections
- Flexible economic interactions between individuals, organizations, and groups
- Equilibrium mechanism balancing issuance and demurrage

## Documentation

For more details on Circles and details of the implementation please refer to [https://aboutcircles.github.io/circles-contracts-v2/](https://aboutcircles.github.io/circles-contracts-v2/)

## Getting Started

🐲 **Beta Status**: This repository is in beta and actively developed in the open. Initial reviews have been completed, we welcome community engagement for wider testing and integration. As AGPL-licensed software, it's provided as-is. We encourage thorough review and testing before any production use.


### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

1. Clone the repository:
    ```bash
    git clone https://github.com/aboutcircles/circles-contracts-v2
    cd circles-contracts-v2
    ```
2. Install dependencies:
    ```bash
    forge install
    ```
### Building

1. Compile the contracts:
    ```bash
    forge build
    ```

### Testing

1. Run the test suite:
    ```bash
    forge test
    ```
2. For a gas report:
    ```bash
    forge test --gas-report
    ```

### Deployment

#### To deploy to the Chiado testnet:

1. Copy `.env.example` to `.env` and set your (Chiado) private key and (Blockscout) API keys.
2. Run the deployment script:
    ```bash
    ./script/deployments/chiadoDeploy.sh
    ```

#### To deploy to Gnosis Chain mainnet:

1. **Checkout out the release candidate `rc-v1.0.0-beta`**
    ```
    git checkout rc-v1.0.0-beta
    ```
2. Copy `.env.example` to `.env` and set your private key; in particular for deployment the script only requires a private key for a deployer address on Gnosis Chain (with minimal funding, deployment costs are far less than 1 XDAI):
    ```
    PRIVATE_KEY_GNOSIS='YOUR_PRIVATE_KEY'
    ```
3. Run the mainnet deployment script:
    ```
    cd script/deployments
    ./gnosisChainDeploy.sh
    ```
    Forge SHOULD auto-configure the build parameters from the foundry.toml file,
    but for clarity on a deterministic build, we require the following build parameters:
    - solc compiler version: v0.8.24+commit.e11b9ed9
    - optimization enabled: Yes
    - Optimizer runs: 200
    - EVM version: cancun
    - License: GNU AGPLv3

    Note that the production deployment script waits 20 seconds between each deployment,
    so feel free to go stretch your legs.

4. The deploy script will create a folder locally on your machine:
    ```
    <root>/script/deployments/gnosischain-rc-1.0.0-beta-bb1ed9a-<day>-<time>/
    ```
    with two important files (and extra helper files):
    - `gnosischain-artefacts-<identifier>.txt` with verification data for each deployed contract
    - and `gnosischain-<identifier>.log` with a better human-readable summary of the deployment

The deployment script should have deployed 9 contracts:   
- Hub,
- Migration,
- NameRegistry,
- ERC20Lift,
- StandardTreasury,
- BaseGroupMintPolicy,
- MastercopyDemurrageERC20,
- MastercopyInflationaryERC20 and 
- MastercopyStandardVault

### Optionally, verifying your contracts

Note, as we are looking for redundant deterministic deployments, it is likely for `rc-v1.0.0-beta` that your deployment will already be recognised by the block explorers.

However, in case that is not the case, below are instructions to help you get started

#### Gnosis Blockscout

You will need to set a `BLOCKSCOUT_API_KEY` set in the `.env` file. Go to Blockscout.com to configure your account and get an API key.

An easy way to verify the contracts on `gnosis.blockscout.com` is to run the same deployment 
on Chiado testnet (see instructions above). You will need to add a private key with testnet xdai funding on Chiado to the `.env` file.
The Chiado deployment script will attempt to directly verify as it is deploying the contracts to Chiado through blockscout. This can intermittently fail, so we don't use these options for the mainnet deployment script. However, on Chiado, should this fail you can run it a second time. Once a contract is verified on Chaido it will also be recognised on Blockscout Gnosis Chain.

### Gnosisscan

WIP: there is a `verifyDeployment.sh` script which aims to verify through the gnosisscan.io API, however it has a bug where Gnosisscan does not receive the correct EVM version `cancun` and compilation on their side will fail for Hub.sol.

Manually verifying on gnosisscan.io can be done, by going to your deployed address and following the instructions there.
The required parameters are listed above in the deployment section. However to obtain a single "flattened source code file" (recommended), you can use forge as follows, eg. for Hub.sol from the project root:

```
forge flatten ./src/hub/Hub.sol -o flattened_hub.sol
```

### Sourcify

(later), might also help with gnosisscan.io if they cooperate.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [AGPL-3.0 License](LICENSE).

## Disclaimer

This project is currently under active development and should be considered in beta stage. While the contracts for Circles v2 have undergone both internal and external reviews (reports available in the `/reviews` directory), users should be aware of the following:

- **Caution for Production Use**: This software is in beta stage. Use in production environments should be approached with caution and only after thorough review, testing, and appropriate risk assessment.
- **As-Is Basis**: The software is provided "as-is" without any warranties, express or implied.
- **No Liability**: The developers and contributors of this project shall not be held liable for any damages or losses arising from the use of this software.
- **License**: This project is released under the GNU Affero General Public License v3.0 (AGPL-3.0). Users must comply with the terms of this license when using, modifying, or distributing the software.
- **Security**: While efforts have been made to ensure the security of the contracts, users should conduct their own security audits before any significant use.
- **Updates**: This software may undergo significant changes. Users are advised to regularly check for updates and review the changelog.

By using this software, you acknowledge that you have read this disclaimer, understand its contents, and agree to its terms.

## Contact

For questions or support regarding this project, please contact:

- About Circles <support@aboutcircles.com>
- Ben <benjamin.bollen@gnosis.io>

We appreciate your interest, feedback and contributions!