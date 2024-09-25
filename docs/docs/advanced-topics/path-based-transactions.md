# Path-based Transactions and Flow Matrices

In the Circles ecosystem, path-based transactions enable the transfer of Circles tokens between people who don't directly trust each other. This system uses flow matrices to represent and validate these multi-hop transactions.

## Concept Overview

Path-based transactions allow Circles to be transferred along a path of trust relationships. Instead of requiring direct trust between the sender and receiver, the system finds a path through the trust network where each step involves a trusted relationship.

## Flow Matrices

Flow matrices are structured representations for these path-based transactions. They describe the movement of Circles tokens through the network for a given transaction (or a batch of transactions).

### Structure of a Flow Matrix

A flow matrix consists of the following components:

1. **Flow Vertices**: An ordered list of avatar addresses that the transaction path touches. This includes any avatar that sends, receives or whose Circles are used in any of the flow edges. These can be humans, organizations or groups, but must be registered.
2. **Flow Edges**: A path consists of a set of flow edges. This is expressed as an array of `FlowEdges`, each representing a transfer of a specific (personal or group) Circles type and amount between two vertices. These flow edges are applied in the order given and the order of the coordinates must match that of the flow edges. A `FlowEdge` therefore is a structure that specifies:
    - `amount`: The amount of tokens being transferred (uint192) in this edge.
    - `streamSinkId`: To perform the `ERC1155:onERC1155Received()` call, the path needs to identify which edges are terminal flow edges. Therefore this references for all terminal edges a stream identifier (and is 0 for non-terminal edges; >0 for terminal edges).
3. **Coordinates**: Packed data representing triplets of indices within the flow vertices array: for each flow edge the coordinates must provide a triplet `(uint16, uint16, uint16)`, referencing the addresses of `(Circles-to-send, sender, receiver)` read from the flow vertices array. The coordinates are input as `bytes` packed explicitly per 16 bits to avoid zero-padding for 256bit word length.
4. **Streams**: A stream represents the actual intent of a sender to send an amount of Circles to a receiver - without specifying which Circles to send or over which path, simply that the receiver only ever receives Circles they trust. A stream specifies a `sourceCoordinate` as the index of the source (or sender) in the flow vertices array, an array of the `flowEdgeIds` to cross-reference with the flow edges the correct terminal edges of this stream; and `bytes data` that will be sent to the receiver of the stream in the acceptance call. A flow matrix can have:
    - zero streams provided: All edges combined must form a closed path where no sender and no receiver nett-receives or nett-sends an amount of Circles. This can be used to reorganise the balances of Circles across the graph.
    - one stream provided: The flow matrix represents the path of a single intended transfer between a sender and receiver.
    - two or more streams: The flow matrix represents a batch of intents of multiple senders to send Circles to receivers, and they get settled on-chain as single path (while still performing the acceptance checks for each stream's receiver).

### An example of a flow matrix

Let's illustrate a flow matrix and streams with an example. Let's assume we have the following avatars (only humans).
```
Avatars (Flow Vertices):
A: Alice
B: Bob
C: Charlie
D: David
E: Eva
```

Let's assume Alice wants to send 3 CRC to David, and 5 CRC to Eva. Bob wants to send 4 CRC to David as well. Let's assume they have the following trust graph among them (where the arrow means "trusts"):

<img src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA1MDAgMzAwIj4KICA8c3R5bGU+CiAgICAubm9kZSB7IGZpbGw6ICNmZjk3ODY7IHN0cm9rZTogIzM4MzE4Yjsgc3Ryb2tlLXdpZHRoOiAyOyB9CiAgICAubGFiZWwgeyBmaWxsOiAjMzgzMThiOyBmb250LWZhbWlseTogQXJpYWwsIHNhbnMtc2VyaWY7IGZvbnQtc2l6ZTogMTRweDsgfQogICAgLmFycm93IHsgZmlsbDogbm9uZTsgc3Ryb2tlOiAjMzgzMThiOyBzdHJva2Utd2lkdGg6IDI7IH0KICAgIC5hcnJvd2hlYWQgeyBmaWxsOiAjMzgzMThiOyB9CiAgPC9zdHlsZT4KICAKICA8IS0tIE5vZGVzIC0tPgogIDxjaXJjbGUgY2xhc3M9Im5vZGUiIGN4PSIxMDAiIGN5PSIxNTAiIHI9IjMwIiAvPgogIDxjaXJjbGUgY2xhc3M9Im5vZGUiIGN4PSIyMDAiIGN5PSIxNTAiIHI9IjMwIiAvPgogIDxjaXJjbGUgY2xhc3M9Im5vZGUiIGN4PSIzMDAiIGN5PSIxNTAiIHI9IjMwIiAvPgogIDxjaXJjbGUgY2xhc3M9Im5vZGUiIGN4PSI0MDAiIGN5PSIxMDAiIHI9IjMwIiAvPgogIDxjaXJjbGUgY2xhc3M9Im5vZGUiIGN4PSI0MDAiIGN5PSIyMDAiIHI9IjMwIiAvPgogIAogIDwhLS0gTGFiZWxzIC0tPgogIDx0ZXh0IGNsYXNzPSJsYWJlbCIgeD0iMTAwIiB5PSIxNTUiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkE8L3RleHQ+CiAgPHRleHQgY2xhc3M9ImxhYmVsIiB4PSIyMDAiIHk9IjE1NSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+QjwvdGV4dD4KICA8dGV4dCBjbGFzcz0ibGFiZWwiIHg9IjMwMCIgeT0iMTU1IiB0ZXh0LWFuY2hvcj0ibWlkZGxlIj5DPC90ZXh0PgogIDx0ZXh0IGNsYXNzPSJsYWJlbCIgeD0iNDAwIiB5PSIxMDUiIHRleHQtYW5jaG9yPSJtaWRkbGUiPkQ8L3RleHQ+CiAgPHRleHQgY2xhc3M9ImxhYmVsIiB4PSI0MDAiIHk9IjIwNSIgdGV4dC1hbmNob3I9Im1pZGRsZSI+RTwvdGV4dD4KICAKICA8IS0tIEFycm93cyAtLT4KICA8cGF0aCBjbGFzcz0iYXJyb3ciIGQ9Ik0xNzAgMTUwIEwxMzAgMTUwIiBtYXJrZXItZW5kPSJ1cmwoI2Fycm93aGVhZCkiIC8+CiAgPHBhdGggY2xhc3M9ImFycm93IiBkPSJNMjMwIDE1MCBMMjcwIDE1MCIgbWFya2VyLWVuZD0idXJsKCNhcnJvd2hlYWQpIiAvPgogIDxwYXRoIGNsYXNzPSJhcnJvdyIgZD0iTTI3MCAxNTAgTDIzMCAxNTAiIG1hcmtlci1lbmQ9InVybCgjYXJyb3doZWFkKSIgLz4KICA8cGF0aCBjbGFzcz0iYXJyb3ciIGQ9Ik0zMzAgMTUwIEwzNzAgMTEwIiBtYXJrZXItZW5kPSJ1cmwoI2Fycm93aGVhZCkiIC8+CiAgPHBhdGggY2xhc3M9ImFycm93IiBkPSJNMzcwIDExMCBMMzMwIDE1MCIgbWFya2VyLWVuZD0idXJsKCNhcnJvd2hlYWQpIiAvPgogIDxwYXRoIGNsYXNzPSJhcnJvdyIgZD0iTTQwMCAxNzAgTDQwMCAxMzAiIG1hcmtlci1lbmQ9InVybCgjYXJyb3doZWFkKSIgLz4KICAKICA8IS0tIEFycm93aGVhZCBkZWZpbml0aW9uIC0tPgogIDxkZWZzPgogICAgPG1hcmtlciBpZD0iYXJyb3doZWFkIiBtYXJrZXJXaWR0aD0iMTAiIG1hcmtlckhlaWdodD0iNyIgcmVmWD0iOSIgcmVmWT0iMy41IiBvcmllbnQ9ImF1dG8iPgogICAgICA8cG9seWdvbiBjbGFzcz0iYXJyb3doZWFkIiBwb2ludHM9IjAgMCwgMTAgMy41LCAwIDciIC8+CiAgICA8L21hcmtlcj4KICA8L2RlZnM+Cjwvc3ZnPg==" alt="Circles Trust Graph" style="max-width: 500px; width: 100%; height: auto;">

We can assume that everyone already holds some balances of the tokens of the people they trust. A possible path could look like the following:

```sh
+----------+-----+-----+-----+-----+-----+
|          |  A  |  B  |  C  |  D  |  E  |
+----------+-----+-----+-----+-----+-----+
| A-B      | -8A |  8A |     |     |     |
+----------+-----+-----+-----+-----+-----+
| B-D (T2) |     | -4C |     |  4C |     |
+----------+-----+-----+-----+-----+-----+
| B-C      |     | -5B |  5B |     |     |
+----------+-----+-----+-----+-----+-----+
| B-D (T1) |     | -3C |     |  3C |     |
+----------+-----+-----+-----+-----+-----+
| C-E (T3) |     |     | -5D |     |  5D |
+==========+=====+=====+=====+=====+=====+
| Net Flow | -8  | -4  |   0 |  7  |  5  |
+==========+=====+=====+=====+=====+=====+
| Stream 1 | -3  |     |     |  3  |     |
+----------+-----+-----+-----+-----+-----+
| Stream 2 |     | -4  |     |  4  |     |
+----------+-----+-----+-----+-----+-----+
| Stream 3 | -5  |     |     |     |  5  |
+----------+-----+-----+-----+-----+-----+
```

In this diagram, positive values represent incoming tokens and negative values represent outgoing tokens; the letters `(A, B, C, D)` represent the type of Circles tokens being transfered; and streams don't specify token types, only amounts.

#### Flow edges Explanation 

Note: flow edge arrays and flow vertices arrays are indexed from 0. Streams are explicitly indexed from 1, because we reserve 0 for not-referencing a stream. (And Markdown will not enumerate from 0, so subtract 1 here):

1. A-B: Alice sends 8 of her own Circles (A) to Bob.
    - `(amount = 8, streamSinkId = 0)`
    - coordinates `(A, A, B)`
2. B-D: Bob sends 4 of Charlie's Circles (C) to David.
    - `(amount = 4, streamSinkId = 2)`
    - coordinates `(C, B, D)`
3. B-C: Bob sends 5 of his own Circles (B) to Charlie.
    - `(amount = 5, streamSinkId = 0)`
    - coordinates `(B, B, C)`
4. B-D: Bob sends 3 of Charlie's Circles (C) to David.
    - `(amount = 3, streamSinkId = 1)`
    - coordinates `(C, D, D)`
5. C-E: Charlie sends 5 of David's Circles (D) to Eva.
    - `(amount = 5, streamSinkId = 3)`
    - coordinates `(D, C, E)`

#### Stream Explanation

- Stream 1: Alice intends to send 3 Circles from her to David.
    - `sourceCoordinate = 0` (Alice)
    - `flowEdgeIds = [3]` (fourth edge B-D is the single terminal edge for stream 1)
    - `data` (some message Alice sends along to David)
- Stream 2: Bob intends to send 4 Circles to David. 
    - `sourceCoordinate = 1` (Bob)
    - `flowEdgeIds = [1]` (second edge B-D is single terminal edge for stream 2)
    - `data`
- Stream 3: Alice intends to send 5 Circles to Eva.
    - `sourceCoorindate = 0`
    - `flowEdgeIds = [4]` (fifth edge C-E terimates stream 3)
    - `data`

## Net Flow and Consistency Check

The net flow is not sent as input to the contracts, rather it is included in the diagram to illustrate the consistency check that the contract performs.
For an explicit path of flow edges to be a valid solution to the set of intents expressed in the streams, it must hold that
for every vertex the sum over all flow edges (modulo Circles Id) must equal the sum over all streams (ie. summing the columns).

Streams themselves don't specify an amount though - both to compactify the representation but also to not over-determine the representation. Instead it is checked that for each stream:

- all the terminal edges that reference this stream have the same receiver.
- that each stream lists their terminal flow edge ids in ascending order.
- and that the count of terminal edges that reference a stream, matches the length of the `flowEdgeIds` array of that stream.

By cross-referencing, and checking consistency we ensure that we can use the sum of the terminal edges for a stream as the amount intended to send by that stream.

In our example, all streams only had one terminal flow edge, but in general a flow matrix can have multiple terminal flow edges for a single stream.

## Technical Implementation

The `Hub` contract implements path-based transactions through the `operateFlowMatrix` function. Let's break down its key components:

### Function Signature

```solidity
function operateFlowMatrix(
    address[] calldata _flowVertices,
    FlowEdge[] calldata _flow,
    Stream[] calldata _streams,
    bytes calldata _packedCoordinates
) external nonReentrant(0)
```

### Key Steps in Processing
The function performs several crucial steps:

1. **Unpacking Coordinates**: The packed coordinates are unpacked into an array of uint16 values.
2. **Authorization Check**: Ensures all senders (as listed in the streams) have authorized the operator calling this function (with `ERC1155::setApprovalForAll()`).
3. **Flow Matrix Verification**: Checks the correctness of the flow matrix, including trust relationships and avatar registrations.
4. **Path Transfers**: Executes the individual transfers defined by the flow edges.
5. **Acceptance Checks**: Calls acceptance checks for the streams and calculates the netted flows.
6. **Flow Matching**: Ensures the netted flows from streams match the verified flow matrix.

The important internal functions that accomplish these above steps are the following:

- **_verifyFlowMatrix**
    - Ensures all vertices are registered avatars.
    - Verifies that receivers trust the Circles being sent.
    - Calculates the netted flow for each vertex.
- **_effectPathTransfers**
    - Processes each flow edge, either as a transfer or a group mint.
    - Keeps track of stream definitions and ensures their correctness.
- **_callAcceptanceChecks**
    - Calls acceptance checks for each stream.
    - Emits `StreamCompleted` events for successful "effective transfers" for each stream.

## Minting Group Circles along a Path

The Circles ecosystem allows for the minting of group Circles as part of path-based transactions. This feature enables dynamic creation of group tokens within complex transfer paths, enhancing the liquidity and utility of the system.

### How Group Minting Works in Path Transactions

1. **Flow Edge to Group Avatar**: When a flow edge in the path has a receiver that is a registered group avatar, the system treats this as a group minting operation instead of a regular transfer.

2. **Collateral for Minting**: The tokens being sent to the group in this flow edge are used as collateral for minting new group Circles.

3. **Automatic Minting**: The `_groupMint` function is called internally, creating new group Circles based on the collateral provided.

4. **Mint Policies**: Each group has an associated mint policy contract that determines the rules for minting new group Circles. This policy is consulted during the minting process.

### Implementation Details

The `_effectPathTransfers` function in the Hub contract handles the minting of group Circles within a path:

```solidity
if (!isGroup(to)) {
    // Regular transfer for non-group receivers
    _update(
        _flowVertices[_coordinates[index + 1]], // sender
        to,
        ids,
        amounts
    );
} else {
    // Group minting for group receivers
    _groupMint(
        _flowVertices[_coordinates[index + 1]], // sender
        to, // receiver
        to, // group
        ids, // collateral
        amounts, // amounts
        "", // No additional data for path-based group mints
        false // Indicate this is part of a path, not an explicit call
    );
}
```

### Key Aspects of Group Minting in Paths

1. **Implicit Minting**: Group minting occurs automatically when a group is the receiver in a flow edge, without requiring explicit minting instructions.

2. **Collateral Transfer**: The tokens sent to the group are transferred to the group's treasury contract as collateral.

3. **Mint Policy Checks**: The group's mint policy is consulted to ensure the minting operation is valid according to the group's rules.

4. **No Additional Data**: When minting occurs as part of a path, no additional data is passed to the mint policy (unlike in explicit group mint calls when the caller can pass data to the group mint policy).

5. **Trust Relationships**: The system checks that the group trusts the collateral being provided (i.e., the actual tokens being sent, not the sender of the flow edge).

### Implications and Benefits

- **Dynamic Token Creation**: Allows for the creation of new group tokens as part of complex transfer paths.
- **Increased Liquidity**: Facilitates the conversion from personal (or group Circles) into (other) group Circles within a single flow edge. Group Circles are likely to be trusted by more and hence accepted by more, reducing the number of hops in the graph a path needs to traverse to reach far away recipients.
- **Flexible Economic Structures**: Enables more complex economic interactions and structures within the Circles ecosystem.
- **Seamless Integration**: Group minting is seamlessly integrated into the path-based transaction system, requiring no special handling from the transaction initiator.

This feature significantly enhances the capabilities of path-based transactions in Circles, allowing for dynamic and flexible token interactions that can adapt to the needs of the network and its participants.
[Previous content remains unchanged]

## Trust and Consented Flow

### Trust Implies a Flow Edge

The default behavior for Circles is such that if one avatar trusts another avatar, they attest that:

1. **Token Acceptance**: They are willing to accept the trusted avatar's personal Circles tokens as payment.

2. **Implicit Flow Permission**: They allow their balance of the trusted avatar's tokens to be used in path-based transactions, potentially without their direct involvement in each transaction.

3. **Network Facilitation**: They contribute to the overall liquidity and connectivity of the Circles network by creating a potential path for transactions.

4. **Value Recognition**: They recognize some form of value or merit in the trusted avatar's economic activity or contribution to the community.

5. **Transitive Trust**: While not directly trusting the entire network of the trusted avatar, they implicitly allow for multi-hop transactions that may involve avatars further down the trust chain.

6. **Time-Bound Relationship**: Trust relationships have an expiry time, allowing for dynamic changes in the trust network over time.

This default behavior enables the Circles system to create paths for transactions between avatars who may not directly trust each other, facilitating a more interconnected and fluid economy.

### Consented Flow

Consented flow is an advanced feature in the Circles ecosystem that provides additional control over path-based transfers. It's an opt-in mechanism that allows people (and groups or organizations) to have more granular control over how their Circles tokens are used in path-based transactions.

#### Key Aspects of Consented Flow

1. **Opt-In Feature**: Avatars must explicitly enable consented flow by setting an advanced usage flag.
2. **Bidirectional Trust Requirement**: When consented flow is enabled, a valid flow edge requires:
    - The receiver trusts the Circles avatar of the tokens being sent (standard requirement).
    - The sender trusts the receiver.
    - The receiver must also have consented flow enabled.
3. **Recursive Protection**: The requirement for the receiver to also have consented flow enabled ensures that the protection extends through multiple hops in a transaction path, for those flow edges that enter a region of consented flow.
4. **Enhanced Control**: Provides more precise control over how an avatar's tokens can be used in the network, potentially reducing unexpected or undesired token movements.
5. **Impact on Liquidity**: While offering more security, consented flow may make some transactions more challenging to complete, as it requires more tightly-knit web of trust relationships.

#### Behaviour Details

The `isPermittedFlow` function in the Hub contract implements the logic for checking whether a flow edge is permitted (with or without consented flow enabled for the sender):

1. **Basic Trust Check**: 
    - Always checks if the receiver trusts the Circles being sent.
    - If this basic trust doesn't exist, the flow is never permitted.
2. **Consented Flow Check**:
    - If the sender has consented flow enabled (checked via `advancedUsageFlags`), additional checks are performed:
        1. The sender must trust the receiver.
        2. The receiver must also have consented flow enabled.
3. **Return Value**: 
    - Returns `true` if the flow is permitted based on the above checks.
    - Returns `false` otherwise.

#### Implications of Consented Flow

1. **Enhanced Security**: Provides an additional layer of control for avatars concerned about unauthorized use of their tokens.
2. **Potential Complexity**: May increase the complexity of finding valid paths for transactions, especially if a sender with consented flow is trying to send tokens to a receiver outside the consented flow perimeter (ie. a receiver without consented flow enabled). The sender may be required to sandwich their path-transfer between disabling and re-enabling consented flow for themselves, so that their path can start from outside the local consented flow perimeter.
3. **Network Dynamics**: Could influence the overall structure and behavior of the Circles trust network, potentially leading to more tightly-knit, high-trust sub-networks.
4. **Flexibility**: Allows for different trust models within the same network, catering to varying preferences for control and openness.

Consented flow represents an advanced usage of the Circles system, allowing for a more nuanced approach to trust and token flow within the network. It balances the need for additional control with the system's goal of creating a fluid, interconnected economy.

## Conclusion

The Circles ecosystem implements path-based transactions using flow matrices to enable multi-hop transfers of personal and group tokens. This system allows for:

1. Complex transfers between indirectly connected avatars
2. Automatic group token minting within transaction paths
3. Flexible trust models, including opt-in consented flow for enhanced control

These mechanisms collectively form a decentralized currency network capable of supporting diverse economic interactions and trust relationships. The technical infrastructure provides a foundation for a social currency system that can adapt to various community needs and transaction complexities.