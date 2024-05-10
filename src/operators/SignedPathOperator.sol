// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../hub/IHub.sol";
import "../hub/TypeDefinitions.sol";
import "./BaseOperator.sol";

contract SignedPathOperator is BaseOperator, TypeDefinitions {
    // Constructor

    constructor(IHubV2 _hub) BaseOperator(_hub) {}

    // External functions

    function operateSignedFlowMatrix(
        address[] calldata _flowVertices,
        FlowEdge[] calldata _flow,
        Stream[] calldata _streams,
        bytes calldata _packedCoordinates
    ) external {}
}
