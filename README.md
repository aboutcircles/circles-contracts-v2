# Audit Competition for Circles
This repository is for the audit competition for the Circles.
To participate, submit your findings only by using the on-chain submission process on https://app.hats.finance/vulnerability .
## How to participate
- follow the instructions on https://app.hats.finance/
## Good luck!
We look forward to seeing your findings.
* * *
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

🐲 **Beta Status**: This repository is in beta and actively developed in the open. While initial reviews are on-going, we welcome community engagement for wider testing and integration. As AGPL-licensed software, it's provided as-is. We encourage thorough review and testing before any production use.


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

To deploy to the Chiado testnet:

1. Copy `.env.example` to `.env` and set your private key and API keys.
2. Run the deployment script:
    ```bash
    ./script/deployments/chiadoDeploy.sh
    ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the [AGPL-3.0 License](LICENSE).

## Disclaimer

This project is under active development. The code has not completed externally reviews and should not be used in production environments without proper review and testing.

## Contact

For questions or support regarding this project, please contact:

- About Circles <support@aboutcircles.com>
- Ben <benjamin.bollen@gnosis.io>

We appreciate your interest and feedback!