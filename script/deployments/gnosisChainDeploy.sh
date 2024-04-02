#!/bin/bash

# Exit immediately if a command exits with a non-zero status,
# specifically useful for the deploy_and_store_details function
set -e

# Function to deploy contract and store deployment details
deploy_and_store_details() {
  local contract_name=$1
  local precalculated_address=$2
  local source_path=$3
  local nonce_to_use=$4
  local deployment_output
  local deployed_address

  echo "" >&2
  echo "Deploying ${contract_name}..." >&2

  # Formulate the command
  forge_command="forge create \
--rpc-url ${RPC_URL} \
--private-key ${PRIVATE_KEY} \
--optimizer-runs 200 \
--chain-id 100 \
--priority-gas-price 2200000000 \
--nonce ${nonce_to_use} \
${source_path} \
${@:5}"

  # Print the command for debugging
  echo "Executing command: $forge_command" >&2

  # if DRY_RUN is not true, execute the command
  if [[ "$DRY_RUN" == "true" ]]; then
    echo "Dry run mode enabled. Skipping deployment steps." >&2
  else
    # Execute the command
    deployment_output=$(eval "${forge_command}")

    deployed_address=$(echo "$deployment_output" | grep "Deployed to:" | awk '{print $3}')
    echo "${contract_name} deployed at ${deployed_address}" >&2

    # Verify that the deployed address matches the precalculated address
    if [ "$deployed_address" = "$precalculated_address" ]; then
      echo "Verification Successful: Deployed address matches the precalculated address for ${contract_name}." >&2
    else
      echo "Verification Failed: Deployed address does not match the precalculated address for ${contract_name}." >&2
      echo "Precalculated Address: $precalculated_address" >&2
      echo "Deployed Address: $deployed_address" >&2
      # exit the script if the addresses don't match
      exit 1
    fi

    # sleep for 20 seconds to allow the api to not rush, and display sleep countdown
    for i in {20..1}; do
      echo -ne "Sleeping for $i seconds... \r" >&2
      sleep 1
    done
  fi

  # Define the filename for constructor arguments based on the contract name
  arguments_file="constructorArgs_${contract_name}.txt"
  arguments_path="${OUT_DIR}/${arguments_file}"
  # Save constructor arguments to the file, skip "--constructor-args"
  echo "${@:6}" > "${arguments_path}"

  # Store deployment details in a file
  echo "{\"contractName\":\"${contract_name}\",\"deployedAddress\":\"${deployed_address}\",\"sourcePath\":\"$3\",\"constructor-args\":\"${@:6}\",\"argumentsFile\":\"${arguments_file}\"}" >> "${deployment_details_file}"

  # return the deployed address
  echo "$deployed_address"
}

# Function to generate a compact and short identifier
generate_identifier() {
    # Fetch the current Git commit hash and take the first 7 characters
    local git_commit_short=$(git rev-parse HEAD | cut -c1-7)

    # Get the current date and time in a compact format (YYMMDD-HMS)
    local deployment_date=$1

    # Fetch version from package.json
    local version=$(node -p "require('./package.json').version")

    # Define the summary file name with version, short git commit, and compact date
    echo "${version}-${git_commit_short}-${deployment_date}"
}

# Set the environment variables, also for use in node script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source "$DIR/../../.env"

# declare Gnosis Chain constants
V1_HUB_ADDRESS='0x29b9a7fBb8995b2423a71cC17cf9810798F6C543'
# gnosis chain v1 deployment time is 1602786330 unix time, 
# but we want to offset this to midnight to start day zero 
# on midnight 15 October 2020
INFLATION_DAY_ZERO=1602720000
# put a long bootstrap time for testing bootstrap to one year
BOOTSTRAP_ONE_YEAR=31540000
# fallback URI 
URI='https://fallback.aboutcircles.com/v1/circles/{id}.json'

# re-export the variables for use here and in the general calculation JS script
export PRIVATE_KEY=$PRIVATE_KEY_GNOSIS
export RPC_URL=$RPC_URL_GNOSIS
VERIFIER_URL=$BLOCKSCOUT_URL_GNOSIS
VERIFIER_API_KEY=$BLOCKSCOUT_API_KEY
VERIFIER=$BLOCKSCOUT_VERIFIER

# Get the current date and time in a compact format (YYMMDD-HMS) outside the functions
deployment_date=$(date "+%y%m%d-%H%M%S")
deployment_date_long=$(date "+%Y-%m-%d %H:%M:%S")
identifier=$(generate_identifier $deployment_date)

# Run the Node.js script to predict contract addresses
# Assuming predictAddresses.js is in the current directory
read DEPLOYER_ADDRESS NONCE_USED HUB_ADDRESS_01 MIGRATION_ADDRESS_02 NAMEREGISTRY_ADDRESS_03 \
ERC20LIFT_ADDRESS_04 STANDARD_TREASURY_ADDRESS_05 BASE_GROUPMINTPOLICY_ADDRESS_06 \
MASTERCOPY_DEMURRAGE_ERC20_ADDRESS_07 MASTERCOPY_INFLATIONARY_ERC20_ADDRESS_08 \
MASTERCOPY_STANDARD_VAULT_09 \
<<< $(node predictDeploymentAddresses.js)

# Check if DRY_RUN is set to "true" and adjust the directory name accordingly
if [[ "$DRY_RUN" == "true" ]]; then
  OUT_DIR="$DIR/DRYRUN-gnosischain-${identifier}-DRY_RUN"
else
  OUT_DIR="$DIR/gnosischain-$identifier"
fi
# Create a directory for the deployment and go there after calling node script
mkdir -p "$OUT_DIR"

# Use DEPLOYER_ADDRESS and NONCE_USED as needed
echo "Deployer Address: $DEPLOYER_ADDRESS, Nonce Used: $NONCE_USED"

# Log the predicted deployment addresses
echo "Predicted deployment addresses:"
echo "==============================="
echo "Hub: ${HUB_ADDRESS_01}"
echo "Migration: ${MIGRATION_ADDRESS_02}"
echo "NameRegistry: ${NAMEREGISTRY_ADDRESS_03}"
echo "ERC20Lift: ${ERC20LIFT_ADDRESS_04}"
echo "StandardTreasury: ${STANDARD_TREASURY_ADDRESS_05}"
echo "BaseGroupMintPolicy: ${BASE_GROUPMINTPOLICY_ADDRESS_06}"
echo "MastercopyDemurrageERC20: ${MASTERCOPY_DEMURRAGE_ERC20_ADDRESS_07}"
echo "MastercopyInflationaryERC20: ${MASTERCOPY_INFLATIONARY_ERC20_ADDRESS_08}"
echo "MastercopyStandardVault: ${MASTERCOPY_STANDARD_VAULT_09}"

# Deploy the contracts

export deployment_details_file="${OUT_DIR}/gnosischain-artefacts-${identifier}.txt"
echo "Deployment details will be stored in $deployment_details_file"

echo ""
echo "Starting deployment..."
echo "======================"

HUB=$(deploy_and_store_details "Hub" $HUB_ADDRESS_01 \
  src/hub/Hub.sol:Hub $((NONCE_USED)) \
  --constructor-args $V1_HUB_ADDRESS \
  $NAMEREGISTRY_ADDRESS_03 $MIGRATION_ADDRESS_02 $ERC20LIFT_ADDRESS_04 \
  $STANDARD_TREASURY_ADDRESS_05 $INFLATION_DAY_ZERO \
  $BOOTSTRAP_ONE_YEAR $URI)

NONCE_USED=$((NONCE_USED + 1))

MIGRATION=$(deploy_and_store_details "Migration" $MIGRATION_ADDRESS_02 \
  src/migration/Migration.sol:Migration $((NONCE_USED)) \
  --constructor-args $V1_HUB_ADDRESS $HUB_ADDRESS_01)

NONCE_USED=$((NONCE_USED + 1))

NAME_REGISTRY=$(deploy_and_store_details "NameRegistry" $NAMEREGISTRY_ADDRESS_03 \
  src/names/NameRegistry.sol:NameRegistry $((NONCE_USED)) \
  --constructor-args $HUB_ADDRESS_01)

NONCE_USED=$((NONCE_USED + 1))

ERC20LIFT=$(deploy_and_store_details "ERC20Lift" $ERC20LIFT_ADDRESS_04 \
  src/lift/ERC20Lift.sol:ERC20Lift $((NONCE_USED)) \
  --constructor-args $HUB_ADDRESS_01 \
  $NAMEREGISTRY_ADDRESS_03 $MASTERCOPY_DEMURRAGE_ERC20_ADDRESS_07 \
  $MASTERCOPY_INFLATIONARY_ERC20_ADDRESS_08)

NONCE_USED=$((NONCE_USED + 1))

STANDARD_TREASURY=$(deploy_and_store_details "StandardTreasury" $STANDARD_TREASURY_ADDRESS_05 \
  src/treasury/StandardTreasury.sol:StandardTreasury $((NONCE_USED)) \
  --constructor-args $HUB_ADDRESS_01 $MASTERCOPY_STANDARD_VAULT_09)

NONCE_USED=$((NONCE_USED + 1))

BASE_MINTPOLICY=$(deploy_and_store_details "BaseGroupMintPolicy" $BASE_GROUPMINTPOLICY_ADDRESS_06 \
  src/groups/BaseMintPolicy.sol:MintPolicy $((NONCE_USED)))

NONCE_USED=$((NONCE_USED + 1))

MC_ERC20_DEMURRAGE=$(deploy_and_store_details "MastercopyDemurrageERC20" $MASTERCOPY_DEMURRAGE_ERC20_ADDRESS_07 \
  src/lift/DemurrageCircles.sol:DemurrageCircles $((NONCE_USED)))

NONCE_USED=$((NONCE_USED + 1))

MC_ERC20_INFLATION=$(deploy_and_store_details "MastercopyInflationaryERC20" $MASTERCOPY_INFLATIONARY_ERC20_ADDRESS_08 \
  src/lift/InflationaryCircles.sol:InflationaryCircles $((NONCE_USED)))

NONCE_USED=$((NONCE_USED + 1))

MC_STANDARD_VAULT=$(deploy_and_store_details "MastercopyStandardVault" $MASTERCOPY_STANDARD_VAULT_09 \
  src/treasury/StandardVault.sol:StandardVault $((NONCE_USED)))

# log to file

# Use the function to generate the file name
summary_file="${OUT_DIR}/gnosischain-${identifier}.log"

# Now you can use $summary_file for logging
{
    echo "Gnosis Chain deployment"
    echo "================="
    echo "Deployment Date: $deployment_date_long"
    echo "Version: $(node -p "require('./package.json').version")"
    echo "Git Commit: $(git rev-parse HEAD)"
    echo "Deployer Address: $DEPLOYER_ADDRESS, Initial nonce: $NONCE_USED"
    echo "Compiler Version: v0.8.23+commit.f704f362" # todo: figure out where to extract this from
    echo ""
    echo "Deployed Contracts:"
    echo "Hub: ${HUB}"
    echo "Migration: ${MIGRATION}"
    echo "NameRegistry: ${NAME_REGISTRY}"
    echo "ERC20Lift: ${ERC20LIFT}"
    echo "StandardTreasury: ${STANDARD_TREASURY}"
    echo "BaseGroupMintPolicy: ${BASE_MINTPOLICY}"
    echo "MastercopyDemurrageERC20: ${MC_ERC20_DEMURRAGE}"
    echo "MastercopyInflationaryERC20: ${MC_ERC20_INFLATION}"
    echo "MastercopyStandardVault: ${MC_STANDARD_VAULT}"
} >> "$summary_file"
