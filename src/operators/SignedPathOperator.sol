// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.24;

import "../hub/IHub.sol";
import "../hub/TypeDefinitions.sol";
import "./BaseOperator.sol";

contract SignedPathOperator is BaseOperator, TypeDefinitions {
    // Errors

    error CirclesOperatorInvalidStreamSource(
        uint256 streamIndex, uint256 singleSourceCoordinate, uint256 streamSourceCoordinate
    );

    // Constructor

    constructor(IHubV2 _hub) BaseOperator(_hub) {}

    // External functions

    function operateSignedFlowMatrix(
        address[] calldata _flowVertices,
        FlowEdge[] calldata _flow,
        Stream[] calldata _streams,
        bytes calldata _packedCoordinates,
        uint256 _sourceCoordinate
    ) external {
        // Extract the alleged source vertex from the flow vertices
        address source = _flowVertices[_sourceCoordinate];
        // Ensure the source is the caller
        if (msg.sender != source) {
            // revert CirclesInvalidFunctionCaller(msg.sender, source, 0);
            revert CirclesErrorOneAddressArg(msg.sender, 0xEA);
        }

        // check that for every stream the source of the stream matches the alleged single source
        for (uint256 i = 0; i < _streams.length; i++) {
            if (_streams[i].sourceCoordinate != _sourceCoordinate) {
                revert CirclesOperatorInvalidStreamSource(i, _sourceCoordinate, _streams[i].sourceCoordinate);
            }
        }

        // Call the hub to operate the flow matrix
        hub.operateFlowMatrix(_flowVertices, _flow, _streams, _packedCoordinates);
    }
}
