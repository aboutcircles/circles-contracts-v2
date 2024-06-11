# IMintPolicy
[Git Source](https://github.com/aboutcircles/circles-contracts-v2/blob/9fbbffb44eda7934ea8adf9354e5f09f6b15b8b2/src/groups/IMintPolicy.sol)


## Functions
### beforeMintPolicy


```solidity
function beforeMintPolicy(
    address minter,
    address group,
    uint256[] calldata collateral,
    uint256[] calldata amounts,
    bytes calldata data
) external returns (bool);
```

### beforeRedeemPolicy


```solidity
function beforeRedeemPolicy(address operator, address redeemer, address group, uint256 value, bytes calldata data)
    external
    returns (
        uint256[] memory redemptionIds,
        uint256[] memory redemptionValues,
        uint256[] memory burnIds,
        uint256[] memory burnValues
    );
```

### beforeBurnPolicy


```solidity
function beforeBurnPolicy(address burner, address group, uint256 value, bytes calldata data) external returns (bool);
```

