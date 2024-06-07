#!/bin/bash

# Run solidity-docgen
npx solidity-docgen --output docs/source/solidity --solc-module solc

# Ensure the output directory exists
mkdir -p docs/source/solidity
