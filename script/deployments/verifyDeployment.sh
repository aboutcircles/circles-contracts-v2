#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Check if deployment directory is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <deployment_directory>"
    exit 1
fi

# Get the script's directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Set the project root directory (two levels up from the script)
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." &> /dev/null && pwd )"

# Set the deployment directory from the command line argument
DEPLOYMENT_DIR="$1"

# Ensure DEPLOYMENT_DIR is an absolute path
if [[ "$DEPLOYMENT_DIR" != /* ]]; then
    DEPLOYMENT_DIR="$SCRIPT_DIR/$DEPLOYMENT_DIR"
fi

# Set the environment variables
source "$PROJECT_ROOT/.env"

# Function to verify a contract
verify_contract() {
    local contract_name=$1
    local deployed_address=$2
    local source_path=$3
    local constructor_args_file=$4

    echo "Verifying ${contract_name}..."
    
    forge verify-contract \
        --chain-id 100 \
        --verifier ${GNOSISSCAN_VERIFIER} \
        --verifier-url ${GNOSISSCAN_URL} \
        --etherscan-api-key ${GNOSISSCAN_API_KEY} \
        --constructor-args-path "${constructor_args_file}" \
        --watch \
        ${deployed_address} \
        ${source_path}
    
    echo "${contract_name} verification submitted."
    echo "-----------------------------------"
}

# Extract the identifier from the deployment directory name
IDENTIFIER=$(basename "$DEPLOYMENT_DIR")

# Read deployment details from the artifacts file
ARTIFACTS_FILE="${DEPLOYMENT_DIR}/gnosischain-artefacts-${IDENTIFIER}.txt"

# Check if the artifacts file exists
if [ ! -f "$ARTIFACTS_FILE" ]; then
    echo "Error: Artifacts file not found at ${ARTIFACTS_FILE}"
    exit 1
fi

# Verify each contract
while IFS= read -r line; do
    contract_name=$(echo $line | jq -r '.contractName')
    deployed_address=$(echo $line | jq -r '.deployedAddress')
    source_path="$PROJECT_ROOT/$(echo $line | jq -r '.sourcePath')"
    constructor_args_file="${DEPLOYMENT_DIR}/$(echo $line | jq -r '.argumentsFile')"
    
    verify_contract "$contract_name" "$deployed_address" "$source_path" "$constructor_args_file"
done < "$ARTIFACTS_FILE"

echo "All contracts verification submitted."