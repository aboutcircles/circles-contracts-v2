# **Circles Audit Competition on Hats.finance** 


## Introduction to Hats.finance


Hats.finance builds autonomous security infrastructure for integration with major DeFi protocols to secure users' assets. 
It aims to be the decentralized choice for Web3 security, offering proactive security mechanisms like decentralized audit competitions and bug bounties. 
The protocol facilitates audit competitions to quickly secure smart contracts by having auditors compete, thereby reducing auditing costs and accelerating submissions. 
This aligns with their mission of fostering a robust, secure, and scalable Web3 ecosystem through decentralized security solutions​.

## About Hats Audit Competition


Hats Audit Competitions offer a unique and decentralized approach to enhancing the security of web3 projects. Leveraging the large collective expertise of hundreds of skilled auditors, these competitions foster a proactive bug hunting environment to fortify projects before their launch. Unlike traditional security assessments, Hats Audit Competitions operate on a time-based and results-driven model, ensuring that only successful auditors are rewarded for their contributions. This pay-for-results ethos not only allocates budgets more efficiently by paying exclusively for identified vulnerabilities but also retains funds if no issues are discovered. With a streamlined evaluation process, Hats prioritizes quality over quantity by rewarding the first submitter of a vulnerability, thus eliminating duplicate efforts and attracting top talent in web3 auditing. The process embodies Hats Finance's commitment to reducing fees, maintaining project control, and promoting high-quality security assessments, setting a new standard for decentralized security in the web3 space​​.

## Circles Overview

Circles is a decentralised web of trust-based social currency system issued on Gnosis Chain.

## Competition Details


- Type: A public audit competition hosted by Circles
- Duration: 2 weeks
- Maximum Reward: $65,065
- Submissions: 122
- Total Payout: $23,026.5 distributed among 13 participants.

## Scope of Audit

## Project intro

Circles is a decentralized protocol for creating and distributing fair and social money through personal and group currencies. Built on the Gnosis Chain, it utilizes smart contracts to manage the creation, distribution, and transfer of personal currencies using the ERC1155 multi-token standard.


## Audit competition scope

`src/` directory of commit `rc-v0.3.6-alpha` in https://github.com/aboutcircles/circles-contracts-v2

```
# File Structure

├── names
│   ├── Base58Converter.sol
│   ├── INameRegistry.sol
│   └── NameRegistry.sol
├── proxy
│   ├── MasterCopyNonUpgradable.sol
│   ├── Proxy.sol
│   └── ProxyFactory.sol
├── operators
│   ├── BaseOperator.sol
│   └── SignedPathOperator.sol
├── circles
│   ├── BatchedDemurrage.sol
│   ├── Circles.sol
│   ├── Demurrage.sol
│   ├── DiscountedBalances.sol
│   ├── ERC1155.sol
│   ├── IDemurrage.sol
│   ├── ICircles.sol
│   └── InflationaryOperator.sol
├── groups
│   ├── BaseMintPolicy.sol
│   ├── Definitions.sol
│   └── IMintPolicy.sol
├── errors
│   └── Errors.sol
├── treasury
│   ├── IStandardVault.sol
│   ├── StandardTreasury.sol
│   └── StandardVault.sol
├── migration
│   ├── IHub.sol
│   ├── IToken.sol
│   └── Migration.sol
├── hub
│   ├── Hub.sol
│   ├── IHub.sol
│   └── TypeDefinitions.sol
└── lift
    ├── DemurrageCircles.sol
    ├── EIP712.sol
    ├── ERC20DiscountedBalances.sol
    ├── ERC20InflationaryBalances.sol
    ├── ERC20Lift.sol
    ├── ERC20Permit.sol
    ├── IERC20Lift.sol
    └── InflationaryCircles.sol

```

## Medium severity issues


- **Reentrancy Vulnerability in personalMint() Allows Unlimited Token Claims**

  A vulnerability has been identified in the `personalMint()` function, which allows a registered user to repeatedly mint tokens for themselves through a reentrancy attack. This is due to the ability to reenter the `personalMint()` method via the `.onERC1155Received()` callback, allowing attackers to claim and mint tokens multiple times without restrictions. The core issue is the timing of the `mintTimes[_human].lastMintTime` update, leading to inaccurate issuance calculations upon reentry. This problem arises as the function does not prevent contracts from calling `registerHuman()` or `personalMint()`, thus enabling reentrancy. To address this, it is recommended to add a reentrancy guard, update `lastMintTime` before actual minting, and potentially restrict these functions to externally owned accounts (EOAs) only. This discovery is crucial for enhancing system security by preventing unlimited token issuance.


  **Link**: [Issue #8](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/8)


- **Vulnerability in Stop Function Allows Resetting of Mint Status**

  The discussion centers around a flaw in the `stop` function, which is supposed to permanently prevent future mints by setting `lastMintTime` to `INDEFINITE_FUTURE`. However, it’s discovered that this can be reversed by calling `calculateIssuanceWithCheck`, which inadvertently resets `lastMintTime`, allowing mint operations to continue. This behavior isn't aligned with the protocol's intent for the `stop` function to be irreversible. Despite the issue allowing this "unstopping" of mints, it was assessed as low-priority since it doesn't pose a significant security risk in the current operational context. There's debate over whether this should be considered a medium-severity issue due to economic implications, but ultimately it's seen as a design oversight rather than a critical security flaw.


  **Link**: [Issue #1](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/1)

## Low severity issues


- **operateFlowMatrix allows potential disruptions through net-zero token flows**

  The operateFlowMatrix function allows manipulation of token balances with minimal approval, posing security risks. Attackers can disrupt or increase gas costs for token transfers with malicious reshufflings. Recommendations include tightening approval checks and exploring alternative security measures. Extended examples illustrate potential attacks, emphasizing the need for careful protocol design to prevent disruptions.


  **Link**: [Issue #122](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/122)


- **Remove Hourly Check in _calculateIssuance to Improve Reward Claiming Efficiency**

  The `_calculateIssuance` function in a contract includes a check that blocks users from claiming rewards if less than an hour has passed since their last mint. This prevents users from receiving timely rewards. Removing this check could improve user experience without issues, as the function returns zero if no tokens are gained.


  **Link**: [Issue #114](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/114)


- **Potential ShortName Collision Due to Lack of Zero-Value Check**

  A short name is generated using a keccak256 hash, restricted to about 70 bytes. If a calculated short name is 0, it breaks protocol invariants, causing potential confusion, as users may register duplicate short names. The solution is to add checks ensuring the short name is not 0. While the risk is low, implementing this check enhances code reliability.


  **Link**: [Issue #113](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/113)


- **Incorrect StreamID Error in `operateFlowMatrix()` Function Due to Zero Indexing**

  In the `operateFlowMatrix()` function, there's a discrepancy between the error message and the actual stream index. The `streamid` parameter wrongly reflects the array index starting from 0, whereas it should start from 1. Adjusting the error message to include `i + 1` would correct this mismatch. While the code might remain unchanged, documentation updates could clarify this indexing for developers.


  **Link**: [Issue #106](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/106)


- **Potential for Fake Token Mint Emissions in StandardTreasury Contract**

  The current setup allows anyone to send tokens to the treasury, potentially causing misleading mint events that could confuse event listeners. Suggested mitigations include moving the event to group mint or verifying the tokens' trustworthiness. Consideration is being given to renaming the event to "CollateralLocked" to avoid misinterpretation.


  **Link**: [Issue #85](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/85)


- **Migration function allows zero-amount transactions, enabling unauthorized balance migration**

  The current `migrate` function implementation lacks validation to ensure the amount migrated is greater than zero. This loophole permits unauthorized zero-amount migrations, which could allow users to migrate others without holding tokens. The suggested fix is to add a check ensuring that the migration amount is greater than zero.


  **Link**: [Issue #50](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/50)


- **Issue with Token Acceptance in Contract's Group Transfer Flow**

  The `_effectPathTransfers` function in the contract improperly forces a group, acting as a middle vertex in a token transfer flow, to accept tokens, even if not designated as a net receiver. This misalignment could cause failures if the group cannot hold tokens, disrupting intended transfer processes. It’s suggested the contract be adjusted to verify token acceptance only when necessary.


  **Link**: [Issue #46](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/46)


- **Incorrect Error Revert Implementation in `_matchNettedFlows()` Function Causing Confusion**

  In the `_matchNettedFlows()` function of `Hub.sol`, an error is incorrectly implemented, leading to swapped values for `matrixNettedFlow` and `streamNettedFlow` in the `CirclesHubNettedFlowMismatch` revert statement. Although the functionality is unaffected, it may cause confusion during debugging. Correcting the error ensures better consistency and clarity.


  **Link**: [Issue #41](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/41)


- **_incorrect hour calculation in _calculateIssuance function leads to inaccurate token issuance_**

  The `_calculateIssuance` function inaccurately calculates remaining hours when the current time exactly matches the hour. This miscalculation, due to an extra hour always being added, could lead to errors in token issuance and minting. Updating the logic to account for zeros in the remainder would resolve the issue efficiently.


  **Link**: [Issue #39](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/39)


- **EnsureERC20 Function Lacks Proper Organization Check Allowing Unauthorized Access**

  The `wrap` function in the contract ensures only humans and groups can wrap tokens, excluding organizations. However, the `ensureERC20` function lacks this differentiation and only checks if the avatar is registered. To prevent bypassing restrictions, an additional check distinguishing organizations should be implemented in `ensureERC20`.


  **Link**: [Issue #25](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/25)


- **Mismatch between documented and actual welcome bonus for new avatars in Circles**

  The documentation states that new avatars invited to Circles receive a welcome bonus of 50 Circles, but the actual bonus awarded is 48 Circles. This inconsistency between the documentation and the code could lead to confusion. The issue has been acknowledged and will be addressed in the upcoming update to ensure accurate documentation.


  **Link**: [Issue #22](https://github.com/hats-finance/Circles-0x6ca9ca24d78af44582951825bef9eadcb210e5cf/issues/22)



## Conclusion

The Hats.finance audit competition for Circles, a decentralized social currency protocol on the Gnosis Chain, identified several vulnerabilities within the protocol's smart contracts. The competition, lasting two weeks, attracted 122 submissions and disbursed a total of $23,026.5 in rewards among 13 participants. Key issues identified included a reentrancy vulnerability that allowed users unlimited token minting through the `personalMint()` function, and a flaw in the `stop` function enabling the inadvertent continuation of mint operations. Both issues were deemed of medium severity. A range of low-severity issues was also noted, such as potential disruptions in token flows through minimal approvals, zero-amount migrations allowing unauthorized balance transfers, and inconsistencies in the welcome bonus documentation. Recommendations include implementing reentrancy guards, tightening approval checks, and updating documentation for clarity. These findings underscore the importance of thorough audits in enhancing decentralized protocol security and highlight Hats.finance's innovative approach to crowd-sourcing security efforts in the Web3 space.

## Disclaimer


This report does not assert that the audited contracts are completely secure. Continuous review and comprehensive testing are advised before deploying critical smart contracts.


The Circles audit competition illustrates the collaborative effort in identifying and rectifying potential vulnerabilities, enhancing the overall security and functionality of the platform.


Hats.finance does not provide any guarantee or warranty regarding the security of this project. Smart contract software should be used at the sole risk and responsibility of users.

