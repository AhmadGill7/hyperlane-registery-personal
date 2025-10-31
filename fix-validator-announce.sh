#!/bin/bash

# Fix ValidatorAnnounce by deploying a new one with correct mailbox

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    exit 1
fi

CORRECT_MAILBOX="0xC505a8B225D46eB5252D96549C074e70855Fe4F3"
RPC_URL="https://rpc.kasplextest.xyz"

echo "🔧 Deploying new ValidatorAnnounce contract with correct mailbox..."
echo "Mailbox: $CORRECT_MAILBOX"
echo ""

# Deploy ValidatorAnnounce
echo "Deploying ValidatorAnnounce..."

# First, let's verify the Solidity file exists
SOL_FILE="node_modules/@hyperlane-xyz/core/contracts/ValidatorAnnounce.sol"
if [ ! -f "$SOL_FILE" ]; then
    echo "❌ ValidatorAnnounce.sol not found at $SOL_FILE"
    echo "Trying alternative location..."
    
    # Try using remote verification instead
    echo "Deploying using bytecode..."
    
    # Get the bytecode for ValidatorAnnounce
    # We'll use cast to deploy directly with bytecode
    
    # ValidatorAnnounce constructor takes (address _mailbox)
    # We need to encode the constructor args
    CONSTRUCTOR_DATA=$(cast abi-encode "constructor(address)" $CORRECT_MAILBOX)
    
    echo "❌ Please install the Hyperlane contracts first:"
    echo "npm install @hyperlane-xyz/core"
    exit 1
fi

# Deploy using forge
OUTPUT=$(forge create \
  --rpc-url $RPC_URL \
  --private-key $HYP_KEY \
  $SOL_FILE:ValidatorAnnounce \
  --constructor-args $CORRECT_MAILBOX \
  2>&1)

echo "$OUTPUT"

# Extract the deployed address from the output
VALIDATOR_ANNOUNCE=$(echo "$OUTPUT" | grep -i "Deployed to:" | awk '{print $3}')

if [ -z "$VALIDATOR_ANNOUNCE" ]; then
    echo "❌ Failed to deploy ValidatorAnnounce"
    echo "Please deploy manually using:"
    echo "forge create --rpc-url $RPC_URL --private-key \$HYP_KEY ValidatorAnnounce --constructor-args $CORRECT_MAILBOX"
    exit 1
fi

echo "✅ ValidatorAnnounce deployed at: $VALIDATOR_ANNOUNCE"
echo ""

# Verify it's using the correct mailbox
echo "Verifying mailbox address..."
DEPLOYED_MAILBOX=$(cast call $VALIDATOR_ANNOUNCE "mailbox()(address)" --rpc-url $RPC_URL)
echo "Deployed contract's mailbox: $DEPLOYED_MAILBOX"

if [ "$(echo $DEPLOYED_MAILBOX | tr '[:upper:]' '[:lower:]')" == "$(echo $CORRECT_MAILBOX | tr '[:upper:]' '[:lower:]')" ]; then
    echo "✅ Mailbox address is correct!"
else
    echo "❌ Mailbox address mismatch!"
    exit 1
fi

echo ""
echo "📝 Update your kasplextestnet-config.json with:"
echo "\"validatorAnnounce\": \"$VALIDATOR_ANNOUNCE\""
echo ""
echo "Also update chains/kasplextestnet/addresses.yaml with the new address"
