// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "../circles/ICircles.sol";
import "./TypeDefinitions.sol";

interface IHubV2 is IERC1155, ICircles {
    function avatars(address avatar) external view returns (address);
    function isHuman(address avatar) external view returns (bool);
    function isGroup(address avatar) external view returns (bool);
    function isOrganization(address avatar) external view returns (bool);

    function migrate(address owner, address[] calldata avatars, uint256[] calldata amounts) external;
    function mintPolicies(address avatar) external view returns (address);
    function burn(uint256 id, uint256 amount, bytes calldata data) external;

    function operateFlowMatrix(
        address[] calldata _flowVertices,
        TypeDefinitions.FlowEdge[] calldata _flow,
        TypeDefinitions.Stream[] calldata _streams,
        bytes calldata _packedCoordinates
    ) external;
}
