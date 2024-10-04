// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

// Explainer on error codes: 3 leading bits for the error type, 5 bits for the error code.
// +------------+-------------------+-------------+
// | Error Type | Hex Code Range    | Occurances  |
// +------------+-------------------+-------------+
// |     0      | 0x00 to 0x1F      |     32      |
// |     1      | 0x20 to 0x3F      |     32      |
// |     2      | 0x40 to 0x5F      |     32      |
// |     3      | 0x60 to 0x7F      |     32      |
// |     4      | 0x80 to 0x9F      |     32      |
// |     5      | 0xA0 to 0xBF      |     32      |
// |     6      | 0xC0 to 0xDF      |     32      |
// |     7      | 0xE0 to 0xFF      |     32      |
// +------------+-------------------+-------------+
//
// for convenience a reference table for the 32 occurances hex conversions;
// so you can "add" the error type easily
// +------------+------------+------------+------------+------------+------------+------------+------------+
// | Occurrence | Hex Code   | Occurrence | Hex Code   | Occurrence | Hex Code   | Occurrence | Hex Code   |
// +------------+------------+------------+------------+------------+------------+------------+------------+
// |     0      |   0x00     |     1      |   0x01     |     2      |   0x02     |     3      |   0x03     |
// |     4      |   0x04     |     5      |   0x05     |     6      |   0x06     |     7      |   0x07     |
// |     8      |   0x08     |     9      |   0x09     |    10      |   0x0A     |    11      |   0x0B     |
// |    12      |   0x0C     |    13      |   0x0D     |    14      |   0x0E     |    15      |   0x0F     |
// |    16      |   0x10     |    17      |   0x11     |    18      |   0x12     |    19      |   0x13     |
// |    20      |   0x14     |    21      |   0x15     |    22      |   0x16     |    23      |   0x17     |
// |    24      |   0x18     |    25      |   0x19     |    26      |   0x1A     |    27      |   0x1B     |
// |    28      |   0x1C     |    29      |   0x1D     |    30      |   0x1E     |    31      |   0x1F     |
// +------------+------------+------------+------------+------------+------------+------------+------------+

interface ICirclesCompactErrors {
    /**
     * @dev CirclesErrorNoArgs is a generic error that does not require any arguments.
     * error type:
     * 0: 0x00 -> 0x1F CirclesAddressCannotBeZero
     * 1: 0x20 -> 0x3F CirclesArrayMustNotBeEmpty
     * 2: 0x40 -> 0x5F CirclesAmountMustNotBeZero
     * 3: 0x60 -> 0x7F CirclesHubFlowVerticesMustBeSorted
     * 4: 0x80 -> 0x9F CirclesLogicAssertion
     */
    error CirclesErrorNoArgs(uint8);

    /**
     * @dev CirclesErrorOneAddressArg is a generic error that requires one address argument.
     * error type:
     * 0: 0x00 -> 0x1F CirclesHubMustBeHuman(avatar)
     * 1: 0x20 -> 0x3F CirclesAvatarMustBeRegistered(avatar)
     * 2: 0x40 -> 0x5F CirclesHubGroupIsNotRegistered(group)
     * 3: 0x60 -> 0x7F CirclesHubRegisterAvatarV1MustBeStoppedBeforeEndOfInvitationPeriod(avatar)
     * 4: 0x80 -> 0x9F CirclesHubAvatarAlreadyRegistered(avatar)
     * 5: 0xA0 -> 0xBF CirclesHubInvalidTrustReceiver(trustReceiver)
     * 6: 0xC0 -> 0xDF CirclesERC1155MintBlocked(human, ~mintV1Status~)
     * 7: 0xE0 -> 0xFF CirclesInvalidFunctionCaller(caller)
     */
    error CirclesErrorOneAddressArg(address, uint8);

    /**
     * @dev CirclesErrorAddressUintArgs is a generic error that provides an address and a uint256 as arguments.
     * error type:
     * 0: 0x00 -> 0x1F CirclesHubOperatorNotApprovedForSource(source, streamIndex)
     * 1: 0x20 -> 0x3F CirclesHubFlowEdgeIsNotPermitted(receiver, circlesId)
     * 2: 0x40 -> 0x5F CirclesHubGroupMintPolicyRejectedBurn(burner, toTokenId(group))
     * 3: 0x60 -> 0x7F CirclesHubGroupMintPolicyRejectedMint(minter, toTokenId)
     * 4: 0x80 -> 0x9F CirclesDemurrageAmountExceedsMaxUint192(account, circlesId)
     * 5: 0xA0 -> 0xBF CirclesDemurrageDayBeforeLastUpdatedDay(account, lastDayUpdated)
     */
    error CirclesErrorAddressUintArgs(address, uint256, uint8);
}

interface IHubErrors {
    // CirclesErrorOneAddressArg 3
    // error CirclesHubRegisterAvatarV1MustBeStoppedBeforeEndOfInvitationPeriod(address avatar, uint8 code);

    // CirclesErrorOneAddressArg 4
    // error CirclesHubAvatarAlreadyRegistered(address avatar, uint8 code);

    // CirclesErrorOneAddressArg 0
    // error CirclesHubMustBeHuman(address avatar, uint8 code);

    // CirclesErrorOneAddressArg 2
    // error CirclesHubGroupIsNotRegistered(address group, uint8 code);

    // CirclesErrorOneAddressArg 5
    // error CirclesHubInvalidTrustReceiver(address trustReceiver, uint8 code);

    // CirclesErrorAddressUintArgs 3
    // error CirclesHubGroupMintPolicyRejectedMint(
    //     address minter, address group, uint256[] collateral, uint256[] amounts, bytes data, uint8 code
    // );

    // CirclesErrorAddressUintArgs 2
    // error CirclesHubGroupMintPolicyRejectedBurn(address burner, address group, uint256 amount, bytes data, uint8 code);

    // CirclesErrorAddressUintArgs 0
    // error CirclesHubOperatorNotApprovedForSource(address operator, address source, uint16 streamIndex, uint8 code);

    // CirclesErrorAddressUintArgs 1
    // error CirclesHubFlowEdgeIsNotPermitted(address receiver, uint256 circlesId, uint8 code);

    // CirclesErrorNoArgs 3
    // error CirclesHubFlowVerticesMustBeSorted();

    error CirclesHubFlowEdgeStreamMismatch(uint16 flowEdgeId, uint16 streamId, uint8 code);

    error CirclesHubStreamMismatch(uint16 streamId);

    error CirclesHubNettedFlowMismatch(uint16 vertexPosition, int256 matrixNettedFlow, int256 streamNettedFlow);
}

interface ICirclesDemurrageErrors {
    // CirclesErrorOneAddressArg 6
    // error CirclesERC1155MintBlocked(address human, address mintV1Status);

    // CirclesErrorAddressUintArgs 4
    // error CirclesDemurrageAmountExceedsMaxUint192(address account, uint256 circlesId, uint256 amount, uint8 code);

    // CirclesErrorAddressUintArgs 5
    // error CirclesDemurrageDayBeforeLastUpdatedDay(
    //     address account, uint256 circlesId, uint64 day, uint64 lastUpdatedDay, uint8 code
    // );

    error CirclesERC1155CannotReceiveBatch(uint8 code);
}

interface ICirclesErrors {
    // CirclesErrorOneAddressArg 1
    // error CirclesAvatarMustBeRegistered(address avatar, uint8 code);

    // CirclesErrorNoArgs 0
    // error CirclesAddressCannotBeZero(uint8 code);

    // CirclesErrorOneAddressArg
    // error CirclesInvalidFunctionCaller(address caller, address expectedCaller, uint8 code);

    error CirclesInvalidCirclesId(uint256 id, uint8 code);

    error CirclesInvalidString(string str, uint8 code);

    error CirclesInvalidParameter(uint256 parameter, uint8 code);

    error CirclesAmountOverflow(uint256 amount, uint8 code);

    error CirclesArraysLengthMismatch(uint256 lengthArray1, uint256 lengthArray2, uint8 code);

    // CirclesErrorNoArgs 1
    // error CirclesArrayMustNotBeEmpty(uint8 code);

    // CirclesErrorNoArgs 2
    // error CirclesAmountMustNotBeZero(uint8 code);

    error CirclesProxyAlreadyInitialized();

    // CirclesErrorNoArgs 4
    // error CirclesLogicAssertion(uint8 code);

    error CirclesIdMustBeDerivedFromAddress(uint256 providedId, uint8 code);

    error CirclesReentrancyGuard(uint8 code);
}

interface IStandardTreasuryErrors {
    error CirclesStandardTreasuryGroupHasNoVault(address group);

    error CirclesStandardTreasuryRedemptionCollateralMismatch(
        uint256 circlesId, uint256[] redemptionIds, uint256[] redemptionValues, uint256[] burnIds, uint256[] burnValues
    );

    error CirclesStandardTreasuryInvalidMetadataType(bytes32 metadataType, uint8 code);

    error CirclesStandardTreasuryInvalidMetadata(bytes metadata, uint8 code);
}

interface INameRegistryErrors {
    error CirclesNamesInvalidName(address avatar, string name, uint8 code);

    error CirclesNamesShortNameAlreadyAssigned(address avatar, uint72 shortName, uint8 code);

    error CirclesNamesShortNameWithNonceTaken(address avatar, uint256 nonce, uint72 shortName, address takenByAvatar);

    error CirclesNamesAvatarAlreadyHasCustomNameOrSymbol(address avatar, string nameOrSymbol, uint8 code);

    error CirclesNamesOrganizationHasNoSymbol(address organization, uint8 code);

    error CirclesNamesShortNameZero(address avatar, uint256 nonce);
}

interface IMigrationErrors {
    error CirclesMigrationAmountMustBeGreaterThanZero();
}
