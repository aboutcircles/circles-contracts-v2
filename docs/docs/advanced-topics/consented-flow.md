# Consented Flow and isPermittedFlow

## Consented Flow

Consented flow is an advanced feature in the Circles ecosystem that provides additional control over token transfers. It's an opt-in mechanism that allows people to have more granular control over how their Circles tokens are used in path-based transactions.

### Key Aspects:

1. **Opt-in Feature**: By default, avatars don't have consented flow enabled. It can be activated by setting a specific flag in the `advancedUsageFlags` mapping.

2. **Bilateral Trust**: When enabled, it requires bilateral trust for a transfer to be permitted. This means both the sender and receiver must trust each other.

3. **Recursive Protection**: To maintain the integrity of the consented flow system, receivers must also have consented flow enabled for the transfer to be permitted.

## isPermittedFlow Function

The `isPermittedFlow` function is a crucial component in enforcing trust relationships and consented flow rules. It determines whether a transfer between two avatars is allowed.

### Function Signature:
```solidity
function isPermittedFlow(address _from, address _to, address _circlesAvatar) public view returns (bool)
```

### Parameters:
- `_from`: The sender's address
- `_to`: The receiver's address
- `_circlesAvatar`: The address of the Circles avatar whose tokens are being transferred

### Behavior:

1. **Basic Trust Check**: 
   - Always checks if the receiver trusts the Circles being sent (`_to` trusts `_circlesAvatar`).
   - If this basic trust doesn't exist, the flow is not permitted.

2. **Consented Flow Check**:
   - If the sender has consented flow enabled (checked via `advancedUsageFlags`), additional checks are performed:
     a. The sender must trust the receiver (`_from` trusts `_to`).
     b. The receiver must have consented flow enabled.

3. **Return Value**: 
   - Returns `true` if the flow is permitted based on the above checks.
   - Returns `false` otherwise.

### Implications:

- **Enhanced Control**: Allows people to have more control over how their tokens are used in complex transactions.
- **Increased Trust Requirements**: When enabled, it requires mutual trust between transaction participants.
- **Potential Complexity**: While offering more control, it may increase the complexity of finding valid transaction paths.

## Use in the Circles Ecosystem

The `isPermittedFlow` function is used in various parts of the Circles contract, particularly in path-based transactions and group mints. It ensures that all transfers, whether direct or as part of a complex path, adhere to the trust relationships and consented flow rules set by the participants.

By providing this additional layer of control, Circles allows for a more nuanced and trust-centric economy, where people can have fine-grained control over their participation in the network's flow of value.