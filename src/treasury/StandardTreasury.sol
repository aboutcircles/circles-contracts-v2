// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155Receiver.sol";
import "../errors/Errors.sol";
import "../hub/TypeDefinitions.sol";
import "../hub/IHub.sol";
import "../groups/IMintPolicy.sol";
import "../proxy/ProxyFactory.sol";
import "./IStandardVault.sol";

contract StandardTreasury is
    ERC165,
    ProxyFactory,
    TypeDefinitions,
    IERC1155Receiver,
    ICirclesErrors,
    IStandardTreasuryErrors,
    ICirclesCompactErrors
{
    // Constants

    /**
     * @dev The call prefix for the setup function on the vault contract
     */
    bytes4 public constant STANDARD_VAULT_SETUP_CALLPREFIX = bytes4(keccak256("setup(address)"));

    // State variables

    /**
     * @notice Address of the hub contract
     */
    IHubV2 public hub;

    /**
     * @notice Address of the mastercopy standard vault contract
     */
    address public immutable mastercopyStandardVault;

    /**
     * @notice Mapping of group address to vault address
     * @dev The vault is the contract that holds the group's collateral
     * todo: we could use deterministic vault addresses as to not store them
     * but then we still need to check whether the correct code has been deployed
     * so we might as well deploy and store the addresses?
     */
    mapping(address => IStandardVault) public vaults;

    // Events

    event CreateVault(address indexed group, address indexed vault);
    event CollateralLockedSingle(address indexed group, uint256 indexed id, uint256 value, bytes userData);
    event CollateralLockedBatch(address indexed group, uint256[] ids, uint256[] values, bytes userData);
    event GroupRedeem(address indexed group, uint256 indexed id, uint256 value, bytes data);
    event GroupRedeemCollateralReturn(address indexed group, address indexed to, uint256[] ids, uint256[] values);
    event GroupRedeemCollateralBurn(address indexed group, uint256[] ids, uint256[] values);

    // Modifiers

    /**
     * @notice Ensure the caller is the hub
     */
    modifier onlyHub() {
        if (msg.sender != address(hub)) {
            // Treasury: caller is not the hub
            revert CirclesInvalidFunctionCaller(msg.sender, address(hub), 0);
        }
        _;
    }

    // Constructor

    /**
     * @notice Constructor to create a standard treasury
     * @param _hub Address of the hub contract
     * @param _mastercopyStandardVault Address of the mastercopy standard vault contract
     */
    constructor(IHubV2 _hub, address _mastercopyStandardVault) {
        if (address(_hub) == address(0)) {
            // Hub address cannot be 0
            // revert CirclesAddressCannotBeZero(0);
            revert CirclesErrorNoArgs(0x13);
        }
        if (_mastercopyStandardVault == address(0)) {
            // Mastercopy standard vault address cannot be 0
            // revert CirclesAddressCannotBeZero(1);
            revert CirclesErrorNoArgs(0x14);
        }
        hub = _hub;
        mastercopyStandardVault = _mastercopyStandardVault;
    }

    // Public functions

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(ERC165, IERC165) returns (bool) {
        return interfaceId == type(IERC1155Receiver).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Exclusively use single received for receiving group Circles to redeem them
     * for collateral Circles according to the group mint policy
     */
    function onERC1155Received(address _operator, address _from, uint256 _id, uint256 _value, bytes calldata _data)
        public
        override
        onlyHub
        returns (bytes4)
    {
        (bytes32 metadataType, address group, bytes memory userData) = _decodeMetadataForGroup(_data);
        if (metadataType == METADATATYPE_GROUPMINT) {
            return _lockCollateralGroupCircles(_id, _value, group, userData);
        } else if (metadataType == METADATATYPE_GROUPREDEEM) {
            return _redeemGroupCircles(_operator, _from, _id, _value, userData);
        } else {
            // Treasury: Invalid metadata type for received
            revert CirclesStandardTreasuryInvalidMetadataType(metadataType, 0);
        }
    }

    /**
     * @dev Exclusively use batch received for receiving collateral Circles
     * from the hub contract during group minting
     */
    function onERC1155BatchReceived(
        address, /*_operator*/
        address, /*_from*/
        uint256[] memory _ids,
        uint256[] memory _values,
        bytes calldata _data
    ) public override onlyHub returns (bytes4) {
        (bytes32 metadataType, address group, bytes memory userData) = _decodeMetadataForGroup(_data);
        if (metadataType == METADATATYPE_GROUPMINT) {
            return _lockCollateralBatchGroupCircles(_ids, _values, group, userData);
        } else {
            // Treasury: Invalid metadata type for batch received
            revert CirclesStandardTreasuryInvalidMetadataType(metadataType, 1);
        }
    }

    // Internal functions

    // onReceived : either mint if data decodes or redeem
    // onBatchReceived : only for minting if data matches

    function _lockCollateralBatchGroupCircles(
        uint256[] memory _ids,
        uint256[] memory _values,
        address _group,
        bytes memory _userData
    ) internal returns (bytes4) {
        // ensure the vault exists
        address vault = address(_ensureVault(_group));
        // forward the Circles to the vault
        hub.safeBatchTransferFrom(address(this), vault, _ids, _values, _userData);

        // emit the collateral locked event
        emit CollateralLockedBatch(_group, _ids, _values, _userData);

        return this.onERC1155BatchReceived.selector;
    }

    function _lockCollateralGroupCircles(uint256 _id, uint256 _value, address _group, bytes memory _userData)
        internal
        returns (bytes4)
    {
        // ensure the vault exists
        address vault = address(_ensureVault(_group));
        // forward the Circles to the vault
        hub.safeTransferFrom(address(this), vault, _id, _value, _userData);

        // emit the collateral locked event
        emit CollateralLockedSingle(_group, _id, _value, _userData);

        return this.onERC1155Received.selector;
    }

    function _redeemGroupCircles(address _operator, address _from, uint256 _id, uint256 _value, bytes memory _userData)
        internal
        returns (bytes4)
    {
        address group = _validateCirclesIdToGroup(_id);
        IStandardVault vault = vaults[group];
        if (address(vault) == address(0)) {
            // Treasury: Group has no vault
            revert CirclesStandardTreasuryGroupHasNoVault(group);
        }

        // query the hub for the mint policy
        IMintPolicy policy = IMintPolicy(hub.mintPolicies(group));
        if (address(policy) == address(0)) {
            // Treasury: Invalid group without mint policy
            // revert CirclesLogicAssertion(0);
            revert CirclesErrorNoArgs(0x85);
        }

        // query the mint policy for the redemption values
        uint256[] memory redemptionIds;
        uint256[] memory redemptionValues;
        uint256[] memory burnIds;
        uint256[] memory burnValues;
        (redemptionIds, redemptionValues, burnIds, burnValues) =
            policy.beforeRedeemPolicy(_operator, _from, group, _value, _userData);

        // ensure the redemption values sum up to the correct amount
        uint256 sum = 0;
        for (uint256 i = 0; i < redemptionValues.length; i++) {
            sum += redemptionValues[i];
        }
        for (uint256 i = 0; i < burnValues.length; i++) {
            sum += burnValues[i];
        }
        if (sum != _value) {
            // Treasury: Invalid redemption values from policy
            revert CirclesStandardTreasuryRedemptionCollateralMismatch(
                _id, redemptionIds, redemptionValues, burnIds, burnValues
            );
        }

        // burn the group Circles
        hub.burn(_id, _value, _userData);

        // return collateral Circles to the redeemer of group Circles
        vault.returnCollateral(_from, redemptionIds, redemptionValues, _userData);

        // burn the collateral Circles from the vault
        vault.burnCollateral(burnIds, burnValues, _userData);

        // emit the group redeem event
        emit GroupRedeem(group, _id, _value, _userData);
        emit GroupRedeemCollateralReturn(group, _from, redemptionIds, redemptionValues);
        emit GroupRedeemCollateralBurn(group, burnIds, burnValues);

        // return the ERC1155 selector for acceptance of the (redeemed) group Circles
        return this.onERC1155Received.selector;
    }

    /**
     * @dev Decode the metadata for the group mint and revert if the type does not match group mint
     * @param _data Metadata for the group mint
     */
    function _decodeMetadataForGroup(bytes memory _data) internal pure returns (bytes32, address, bytes memory) {
        Metadata memory metadata = abi.decode(_data, (Metadata));

        if (metadata.metadataType == METADATATYPE_GROUPMINT) {
            GroupMintMetadata memory groupMintMetadata = abi.decode(metadata.metadata, (GroupMintMetadata));
            return (METADATATYPE_GROUPMINT, groupMintMetadata.group, metadata.erc1155UserData);
        } else if (metadata.metadataType == METADATATYPE_GROUPREDEEM) {
            if (metadata.metadata.length != 0) {
                // Treasury: Invalid metadata for group redeem, must be empty
                revert CirclesStandardTreasuryInvalidMetadata(metadata.metadata, 0);
            }
            return (METADATATYPE_GROUPREDEEM, address(0), metadata.erc1155UserData);
        } else {
            // Treasury: Invalid metadata type
            revert CirclesStandardTreasuryInvalidMetadataType(metadata.metadataType, 2);
        }
    }

    /**
     * @dev Validate the Circles id to group address
     * @param _id Circles identifier
     * @return group Address of the group
     */
    function _validateCirclesIdToGroup(uint256 _id) internal pure returns (address) {
        address group = address(uint160(_id));
        if (uint256(uint160(group)) != _id) {
            // Treasury: Invalid group Circles id
            revert CirclesIdMustBeDerivedFromAddress(_id, 0);
        }
        return group;
    }

    /**
     * @dev Ensure the vault exists for the group, and if not deploy it
     * @param _group Address of the group
     * @return vault Address of the vault
     */
    function _ensureVault(address _group) internal returns (IStandardVault) {
        IStandardVault vault = vaults[_group];
        if (address(vault) == address(0)) {
            vault = _deployVault();
            vaults[_group] = vault;

            emit CreateVault(_group, address(vault));
        }
        return vault;
    }

    // todo: this could be done with deterministic deployment, but same comment, not worth it
    /**
     * @dev Deploy the vault
     * @return vault Address of the vault
     */
    function _deployVault() internal returns (IStandardVault) {
        bytes memory vaultSetupData = abi.encodeWithSelector(STANDARD_VAULT_SETUP_CALLPREFIX, hub);
        IStandardVault vault = IStandardVault(address(_createProxy(mastercopyStandardVault, vaultSetupData)));
        return vault;
    }
}
