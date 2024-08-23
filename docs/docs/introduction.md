# Introduction to Circles

## Brief Overview

Circles is a digital protocol designed to create and distribute fair and social money through personal currencies. It harnesses the power of decentralized technology to implement a system of interconnected, individual economic units that collectively form a larger, more equitable economic network.

The Circles protocol is built on the Gnosis Chain blockchain, utilizing smart contracts to manage the creation, distribution, and transfer of personal currencies. At its core, Circles employs an ERC1155 multi-token standard, enabling efficient handling of multiple token types (different personal and group Circles -- more on groups later) within a single contract.

## Purpose and Goals of Circles

The primary purpose of Circles is to create a more inclusive and sustainable economic system through the equitable issuance of money to all participants. In pursuing this vision, Circles aims to:

1. Introduce community currencies that reduce economic inequality by ensuring a baseline level of economic participation for all.
2. Foster community connections and strengthen local economies through trust-based currency networks.
3. Promote sustainable economic growth by implementing a demurrage system that discourages hoarding and encourages circulation.
4. Provide a flexible framework for various economic experiments and community-driven initiatives.
5. Empower individuals and communities to have greater control over their economic interactions and monetary systems.

## Key Concepts

### Personal Currencies

In the Circles ecosystem, each individual can mint their own personal currency. This unique feature of the protocol empowers every participant to become an issuer of their own personal Circles. The Hub contract manages both the registration of individuals (referred to as "humans" in the contract) and the issuance of their personal currencies.

Key points about personal currencies:

- Each registered human can mint a deterministic amount of their personal currency at a consistent rate of one Circle per hour.
- Minting is retroactive, allowing claims for up to 14 days of past elapsed time.
- The mintable amount is calculated based on the number of complete hours passed since the last issuance of Circles.
- Circles undergo daily demurrage at a rate equivalent to 7% per year. Issuance for past days accounts for this demurrage, ensuring fair distribution over time. (Further details on demurrage are discussed in a later section)
- Personal currencies are represented as unique tokens within the ERC1155 multi-token system, with each token ID derived from the address of the human's avatar.
- The `personalMint()` function in the Hub contract manages the minting process.

This system ensures a fair, time-based issuance of personal currencies while implementing mechanisms to encourage active participation in the Circles economy.

### Trust Networks

Trust is a fundamental concept in the Circles protocol. It allows personal currencies to become valuable and transferable within the network. The trust system is implemented in the Hub contract through the following mechanisms:

- People can establish trust relationships with other entities (people, organizations, or groups) using the `trust()` function.
- Trust relationships can be set with expiration times, allowing for dynamic trust networks. Alternatively, trust can be established indefinitely by setting the expiration to the maximum possible future time.
- The trust network is leveraged to enable transitive transfers of Circles along paths of trust. The `isPermittedFlow()` function verifies if a transitive transfer is permissible based on the trust relationships between the involved parties and the specific currency being transferred.
- Trust relationships can be established not only between individuals but also between people, organizations, and groups, creating a diverse and interconnected economic ecosystem.

Trust networks enable:

- Path-based transactions, where currencies can be exchanged through chains of trust connections.
- Community-building, as users create economic connections with individuals and entities they trust.
- A decentralized approach to currency valuation and acceptance, based on social and organizational relationships rather than centralized authority.
- Flexible economic interactions between various types of actors within the Circles ecosystem.

### Demurrage

Demurrage is an economic concept where the value of a currency decreases over time. In Circles, this is implemented to encourage circulation of the currency and discourage hoarding. Demurrage further ensures that all times in the future one hour can be issued as one Circle.

By default all balances and transfer amounts as arguments in functions in the Hub contract are understood as demurraged amounts for the present day. However, to interact with other smart contracts it is often important to be able to interact with a static (ie. not rebalancing) token representation. Therefore Circles also offers a static, inflationary representation of all balances and transfer functions - both at the ERC1155 representation and in the ERC20 representation.

The Circles contract includes a demurrage system with the following characteristics:

- Balances are stored as "discounted balances" that automatically decrease in value over time.
- The `calculateIssuance()` function in the Circles contract accounts for demurrage when determining how much new currency to mint for a person.
- Demurrage applies to both personal currencies and group currencies.

This system ensures that:

- The currency remains active and circulating within the community.
- Long-term storage of wealth is discouraged, promoting a more dynamic economy.
- The basic income aspect of the system remains relevant, as users are incentivized to regularly engage with their personal currency.

By combining these key concepts - personal currencies, trust networks, and demurrage - Circles creates a unique economic system that aims to provide a basic income while fostering community connections and encouraging active participation in the local economy.