# Introduction to Circles

## Brief Overview

Circles is a digital protocol designed to create and distribute a a fair and social money through personal currencies. It leverages the power of decentralized technology to implement a system of interconnected, individual economic units that together form a larger, more equitable economic network.

The Circles protocol is built on top of the Gnosis Chain blockchain, utilizing smart contracts to manage the creation, distribution, and transfer of personal currencies. At its core, Circles employs an ERC1155 multi-token standard, allowing for efficient handling of multiple token types (different personal and group Circles -- more on groups later) within a single contract.

## Purpose and Goals of Circles

The primary purpose of Circles is to create a more inclusive and sustainable economic system by providing equitable issuance of money to all participants. By doing so, Circles aims to:

1. Introduce community currencies with lower economic inequality by ensuring a baseline level of economic participation for all.
2. Foster community connections and local economies through trust-based currency networks.
3. Encourage sustainable economic growth by implementing a demurrage system that discourages hoarding and promotes circulation.
4. Provide a flexible framework for various economic experiments and community-driven initiatives.

## Key Concepts

### Personal Currencies

In the Circles ecosystem, each individual can mint their own personal currency. This is a unique feature of the protocol, allowing every participant to become an issuer of their own basic income. The Hub contract manages the registration of individuals (referred to as "humans" in the contract) and the issuance of their personal currencies.

Key points about personal currencies:

- Each registered human can mint a fixed amount of their personal currency regularly (1 Circle per hour).
- Personal currencies are represented as unique tokens within the ERC1155 multi-token system.
- The minting process is managed by the `personalMint()` function in the Hub contract.

### Trust Networks

Trust is a fundamental concept in the Circles protocol. It allows personal currencies to become valuable and transferable within the network. The trust system is implemented in the Hub contract through the following mechanisms:

- Users can establish trust relationships with other users using the `trust()` function.
- Trust relationships have expiration times, allowing for dynamic trust networks.
- The `isPermittedFlow()` function checks if a transfer is allowed based on the trust relationships between the sender, receiver, and the currency being transferred.

Trust networks enable:
- Path-based transactions, where currencies can be exchanged through chains of trust.
- Community-building, as users create economic connections with those they trust.
- A decentralized approach to currency valuation and acceptance.

### Demurrage

Demurrage is an economic concept where the value of a currency decreases over time. In Circles, this is implemented to encourage circulation of the currency and discourage hoarding. The Circles contract includes a demurrage system with the following characteristics:

- Balances are stored as "discounted balances" that automatically decrease in value over time.
- The `_calculateIssuance()` function in the Circles contract accounts for demurrage when determining how much new currency to mint for a user.
- Demurrage applies to both personal currencies and group currencies.

This system ensures that:
- The currency remains active and circulating within the community.
- Long-term storage of wealth is discouraged, promoting a more dynamic economy.
- The basic income aspect of the system remains relevant, as users are incentivized to regularly engage with their personal currency.

By combining these key concepts - personal currencies, trust networks, and demurrage - Circles creates a unique economic system that aims to provide a basic income while fostering community connections and encouraging active participation in the local economy.