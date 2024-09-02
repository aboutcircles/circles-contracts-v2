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

In the Circles ecosystem, each individual can mint their own personal currency. This feature of the protocol empowers every participant to become an issuer of their own personal Circles. The Hub contract manages both the registration of individuals (referred to as "humans" in the contract) and the issuance of their personal currencies.

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
- Circles still function as a normal token, for explicit `ERC1155:safe(Batch)TransferFrom()` or `ERC20:transfer()` no constraints of the transitive transfer of the trust network apply.
- Trust relationships can be established not only between individuals but also between people, organizations, and groups, creating a diverse and interconnected economic ecosystem.

Trust networks enable:

- Path-based transactions, where currencies can be exchanged through chains of trust connections.
- Community-building, as users create economic connections with individuals and entities they trust.
- A decentralized approach to currency valuation and acceptance, based on social and organizational relationships rather than centralized authority.
- Flexible economic interactions between various types of actors within the Circles ecosystem.

### Demurrage

Demurrage in currency systems is an economic concept where a cost is associated with holding a currency over time. In Circles, this mechanism is implemented to encourage circulation of the currency and mitigate extreme inequities. Demurrage ensures that at any future point, one hour can be issued as one Circle, while maintaining a maximum total supply of Circles.

In the Hub contract, all balances and transfer amounts used as function arguments are, by default, understood as demurraged amounts for the present day. However, to facilitate interactions with other smart contracts, Circles also offers a static (non-rebalancing) token representation. This static, inflationary representation of all balances and transfer functions is available both in the ERC1155 and ERC20 representations.

The Circles contract incorporates a demurrage system with the following key characteristics:

- Circles have a 7% p.a. demurrage cost applied to them in the contracts, rebalancing the amounts.
- Demurrage is applied on an equivalent daily basis, ensuring that during a period of a day balances are not continuously adjusted.
- Balances are stored as "discounted balances" that automatically decrease in value over time.
- The `calculateIssuance()` function in the Circles contract factors in demurrage when determining the amount of new currency to mint for an individual.
- Demurrage applies uniformly to both personal currencies and group currencies.

This system ensures that:

- The currency remains active and circulating within the community.
- Circles are issued equitably across individuals and over time.
- A clear unit of account is established, with one Circle representing one hour of an individual's time.
- Circles serves as both a robust store of value and an effective means of exchange.

By integrating these key concepts - personal currencies, trust networks, and demurrage - Circles creates an economic system that aims to provide a fairly issued, socially-rooted monetary framework, foster community connections and promote active participation in the local economy.

## Total Supply and Equilibrium

The Circles protocol implements an economic model where the minting of new Circles and the demurrage mechanism work together to create an equilibrium in the total supply. This balance is crucial for maintaining the long-term stability and fairness of the system.

Key aspects of the total supply mechanism:

1.  Issuance Rate: Each registered human can mint one Circle per hour, which translates to 24 Circles per day or 8760 Circles per year (not accounting for leap years).
2. Demurrage Rate: All Circles undergo a 7% annual demurrage, applied on a daily basis.
3. Equilibrium Point: The issuance and demurrage rates are carefully calibrated so that they balance each other out at a specific point, creating a maximum total supply for each personal currency.
4. Maximum Total Supply Calculation:
    - Let x be the maximum total supply in Circles.
    - Annual issuance: 8760 Circles
    - Annual demurrage: 7% of x
    - At equilibrium: 8760 = 0.07x
    - Solving for x: x = 8760 / 0.07 = 125,142.86 Circles
5. Dynamic Balance: As new Circles are minted, they contribute to the total supply. However, the demurrage mechanism ensures that the total value of existing Circles decreases over time. This creates a dynamic where the total supply approaches but never exceeds the equilibrium point.
6. Practical Implications:
    - For a new participant, after 14 years of continuous minting they would reach 62% of the maximum supply, assuming no spending. To reach 95% of the total supply, 42.79 years of minting is required.
    - In practice, as people might not mint all their Circles, or Circles get burnt in usage the total supply of their personal Circles token will fluctuate below this theoretical maximum.
    - Each person, organization, group or account can earn Circles from others though in an open economy so anyone's balance can well exceed 125k Circles by holding a variety of different Circles in their wallet.
7. System-wide Effects: While each personal currency has its own maximum supply, the trust network and transferability of Circles create a larger, interconnected economy. The total supply in effect can be thought of as a multiple of 125k CRC for every non-sybil human participating in the network.

This equilibrium mechanism is crucial for several reasons:

- It ensures long-term stability in the value of Circles.
- It maintains fairness by preventing early adopters from gaining disproportionate economic power.
- It creates a predictable and sustainable monetary policy for the Circles ecosystem.

The total supply mechanism is implemented through the interaction of the `personalMint()` function and the demurrage calculations in the Circles contract.
By dynamically managing the total supply through this issuance and demurrage equilibrium, Circles creates a fair, stable, and sustainable economic system that aligns with its goals of reducing inequality and fostering community connections.