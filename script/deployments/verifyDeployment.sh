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

# Get optimizer runs from forge config
OPTIMIZER_RUNS=$(forge config --json | jq -r '.optimizer_runs')

# Find the log file
LOG_FILE=$(find "$DEPLOYMENT_DIR" -name "gnosischain-*.log" | head -n 1)

# Compiler version set in foundry.toml
COMPILER_VERSION="v0.8.24+commit.e11b9ed9"

echo "Using Compiler Version: $COMPILER_VERSION"
echo "Using Optimizer Runs: $OPTIMIZER_RUNS"

# Function to ABI-encode constructor arguments
abi_encode_constructor_args() {
    local contract_name=$1
    local constructor_args_file=$2
    local abi_file="${PROJECT_ROOT}/out/${contract_name}.sol/${contract_name}.json"
    
    # Extract constructor types from ABI
    local constructor_types=$(jq -r '.abi[] | select(.type == "constructor") | .inputs | map(.type) | join(",")' "$abi_file")
    
    if [ -z "$constructor_types" ]; then
        echo "No constructor found or empty constructor" >&2
        return
    fi
    
    echo "Constructor types: $constructor_types" >&2
    
    # Read constructor arguments (single line, space-separated)
    local constructor_args=$(cat "$constructor_args_file")
    echo "Constructor arguments: $constructor_args" >&2
    
    # ABI-encode the arguments
    local encoded_args=$(cast abi-encode "constructor(${constructor_types})" $constructor_args)
    
    if [ $? -ne 0 ]; then
        echo "Error encoding constructor arguments" >&2
        return 1
    fi
    
    echo "${encoded_args:2}"  # Remove '0x' prefix
}


# Function to verify a contract
verify_contract() {
    local contract_name=$1
    local deployed_address=$2
    local source_path=$3
    local constructor_args_file=$4

    echo "Verifying ${contract_name}..."

    # ABI-encode constructor arguments
    local encoded_args=$(abi_encode_constructor_args "$contract_name" "$constructor_args_file")
    
    if [ $? -ne 0 ]; then
        echo "Failed to encode constructor arguments. Skipping verification for ${contract_name}."
        return 1
    fi

    echo "ABI-encoded constructor arguments: $encoded_args"

    # Attempt verification
    if forge verify-contract \
        --chain-id 100 \
        --compiler-version ${COMPILER_VERSION} \
        --optimizer-runs ${OPTIMIZER_RUNS} \
        --flatten \
        --force \
        --evm-version "cancun" \
        --verifier ${GNOSISSCAN_VERIFIER} \
        --verifier-url ${GNOSISSCAN_URL} \
        --etherscan-api-key ${GNOSISSCAN_API_KEY} \
        --constructor-args ${encoded_args} \
        --watch \
        ${deployed_address} \
        ${source_path}; then
        
        echo "${contract_name} verification submitted successfully."
    else
        echo "Verification failed for ${contract_name}. Please check the contract source and try manual verification."
    fi
    echo "-----------------------------------"
}

# Find the artifacts file
ARTIFACTS_FILE=$(find "$DEPLOYMENT_DIR" -name "gnosischain-artefacts-*.txt" | head -n 1)

# Check if the artifacts file exists
if [ ! -f "$ARTIFACTS_FILE" ]; then
    echo "Error: Artifacts file not found in ${DEPLOYMENT_DIR}"
    exit 1
fi

echo "Using artifacts file: $ARTIFACTS_FILE"

# Verify each contract
while IFS= read -r line; do
    contract_name=$(echo $line | jq -r '.contractName')
    deployed_address=$(echo $line | jq -r '.deployedAddress')
    source_path="$PROJECT_ROOT/$(echo $line | jq -r '.sourcePath')"
    constructor_args_file="${DEPLOYMENT_DIR}/$(echo $line | jq -r '.argumentsFile')"
    
    verify_contract "$contract_name" "$deployed_address" "$source_path" "$constructor_args_file"
done < "$ARTIFACTS_FILE"

echo "All contracts verification submitted."