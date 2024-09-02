# Circles Architectural Overview

## Introduction

Circles is a decentralized economic system built on the Gnosis Chain, designed to create and distribute fair and social money through personal currencies. This overview provides a high-level understanding of the system's architecture and how its various components interact.

# Circles Architectural Overview

## System Architecture Diagram

![Alt text](./20240321-Circles-contracts.svg)

<a href="https://link.excalidraw.com/readonly/EuVbVxV3LE0AZ3Od5rpP" target="_blank" rel="noopener noreferrer">
  Open Circles Architecture diagram in new tab
</a>

## Core Components

### Hub v2 (Circles)

The central contract in the Circles ecosystem is the Hub v2, which serves as the main entry point for interactions with the system. It manages:

- Registration of humans, organizations, and groups
- Minting of personal currencies
- Trust relationships between entities
- Group creation and management
- Minting collateral into group currencies
- wrapping ERC1155 Circles Ids tokens into ERC20 wrappers

The Hub v2 contract implements the ERC1155 standard, allowing it to handle multiple token types efficiently.

[Code: /src/hub/Hub.sol](https://github.com/aboutcircles/circles-contracts-v2/blob/v0.3.6-docs/src/hub/Hub.sol)

### NameRegistry

The NameRegistry contract manages the names and metadata associated with Circles accounts. It allows users to set custom names, symbols, and metadata for their personal or group currencies.

### Migration Contract

This contract facilitates the migration of tokens and data from Circles v1 to v2. It ensures a smooth transition for existing users and their balances.

### Standard Treasury

The Standard Treasury contract handles the collateral for group currencies. It receives and manages the assets backing group Circles.

### Vault

The Vault contract (placeholder - details to be added) likely serves as a secure storage for certain assets or data within the Circles ecosystem.

## Token Representations

### Circles (ERC1155)

The core representation of Circles currencies uses the ERC1155 standard, allowing for efficient management of multiple token types (personal and group currencies) within a single contract.

### Wrappers

To enhance compatibility with existing DeFi ecosystems, Circles provides ERC20 wrappers:

1. **Demurrage ERC20**: Represents Circles with the demurrage (decay) factor applied.
2. **Inflationary ERC20**: Represents Circles in their inflationary form, without demurrage applied.

### ERC20Lift

The ERC20Lift contract serves as a bridge between the ERC1155 and ERC20 representations, allowing users to wrap and unwrap their Circles tokens as needed.

## Circles v1 Components (Legacy)

### Hub v1

The original Hub contract from Circles v1, which is being phased out but remains relevant for migration purposes.

### Token

The individual ERC20 token contracts for personal currencies in Circles v1.

## External Interactions

### Gnosis Chain

Circles is built on the Gnosis Chain, leveraging its security and efficiency.

### Safe

Integration with Safe (formerly Gnosis Safe) provides secure multi-signature wallet functionality for Circles users.

### EoA (Externally Owned Accounts)

Standard Ethereum accounts that can interact with the Circles system.

## Advanced Features and Extensions

### Intent Solver Competition

(Placeholder) A mechanism for optimizing transactions and transfers within the Circles network.

### Pre-/Post-hooks on Intents

(Placeholder) Additional logic that can be executed before or after certain operations in the system.

### Flow Matrix and ERC1155

A system for managing and executing complex transfers and exchanges of Circles currencies between multiple parties.

### Single TransferThrough for v1 Pathfinder

A mechanism to facilitate transfers using trust pathways, likely a carryover or adaptation from the v1 system.

### Account Abstraction

(Placeholder) Advanced account management features that may simplify user interactions with the system.

### Custom Treasuries

In addition to the Standard Treasury, the system allows for custom treasury implementations to cater to specific group needs.

### Community dApps

The architecture supports the development of community-driven decentralized applications, such as a potential CowSwap v2 integration.

## Conclusion

The Circles v2 architecture represents a significant evolution from its predecessor, offering a more flexible and scalable system for personal and group currencies. By leveraging advanced smart contract standards like ERC1155 and providing multiple token representations, Circles aims to create a robust ecosystem for social money that can integrate seamlessly with the broader DeFi landscape.

This architecture balances the need for a cohesive, centralized hub with the flexibility required for diverse use cases and future extensions. As the system continues to evolve, this modular design will allow for the integration of new features and improvements while maintaining backward compatibility and supporting the migration from v1.
