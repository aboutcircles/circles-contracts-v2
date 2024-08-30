# Path-based Transactions and Flow Matrices

In the Circles ecosystem, path-based transactions enable the transfer of Circles tokens between people who don't directly trust each other. This system uses flow matrices to represent and validate these multi-hop transactions.

## Concept Overview

Path-based transactions allow Circles to be transferred along a path of trust relationships. Instead of requiring direct trust between the sender and receiver, the system finds a path through the trust network where each step involves a trusted relationship.

## Flow Matrices

Flow matrices are the mathematical representation of these path-based transactions. They describe the movement of Circles tokens through the network for a given transaction (or a batch of transactions).

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
    - two or more streams: The flow matrix represents a batch of intents of multiple senders to send Circles to receivers as a single path settled (while still performing the acceptance checks for each stream's receiver).

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

Let's assume Alice wants to send 3 CRC to David, and 5 CRC to Eva. Bob wants to send 4 CRC to David as well. Let's assume they have the following trust graph among them.

![Docs directory image](/images/advanced-flow-matrix-trust-graph.png "Trust graph")

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

#### Net Flow and consistency check

The net flow is not sent as input to the contracts, rather it is included in the diagram to illustrate the consistency check that the contract performs.
For an explicit path of flow edges to be a valid solution to the set of intents expressed in the streams, it must hold that
for every vertex the sum over all flow edges (modulo Circles Id) must equal the sum over all streams (ie. summing the columns).

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

1. **Unpacking Coordinates**: 
   The packed coordinates are unpacked into an array of `uint16` values.

2. **Verification**:
   - The flow matrix is verified for correctness using `_verifyFlowMatrix`.
   - This checks that all vertices are valid avatars and that trust relationships are respected.

3. **Effecting Transfers**:
   - The actual transfers are processed using `_effectPathTransfers`.
   - This function handles both regular transfers and group mints when applicable.

4. **Acceptance Checks**:
   - The `_callAcceptanceChecks` function performs necessary checks for each stream in the transaction.

5. **Flow Matching**:
   - The netted flows from the streams and the matrix are compared to ensure they match.

## Key Functions

### _verifyFlowMatrix

This function performs crucial checks:
- Ensures all vertices are registered avatars.
- Verifies that receivers trust the Circles being sent.
- Calculates the netted flow for each vertex.

### _effectPathTransfers

This function:
- Processes each flow edge, either as a transfer or a group mint.
- Keeps track of stream definitions and ensures their correctness.

### _callAcceptanceChecks

This function:
- Calls acceptance checks for each stream.
- Emits `StreamCompleted` events for successful transfers.

## Trust and Permissions

The system uses two key functions to manage trust and permissions:

1. `isTrusted(address _truster, address _trustee)`: Checks if the truster trusts the trustee.
2. `isPermittedFlow(address _to, address _circlesAvatar)`: Ensures both that the receiver trusts the Circles being sent and that the Circles avatar trusts the receiver.

## Challenges and Considerations

1. **Complexity**: Path-based transactions involve multiple checks and operations, making them computationally intensive.
2. **Gas Costs**: The complexity of these transactions can lead to higher gas costs, which needs to be balanced against the benefits of the system.
3. **Trust Dynamics**: The system relies on up-to-date trust relationships, which can change over time.

## Conclusion

Path-based transactions and flow matrices form the backbone of Circles' unique approach to creating a trust-based economy. By enabling multi-hop transfers through trust networks, Circles can facilitate transactions between individuals who don't directly trust each other, expanding the utility and reach of the system.