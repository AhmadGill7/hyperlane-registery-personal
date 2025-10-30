#!/bin/bash

# Manually announce validator on Kasplex Testnet
# This bypasses the validator agent's automatic announcement

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    exit 1
fi

VALIDATOR_ANNOUNCE="0xc16287c8880c9Ab8b542846d321ec2DC90EF6993"
VALIDATOR_ADDRESS="0x4f0b4c4c23E31f3e5bCCEfFb649AfdE964B7dF50"
STORAGE_LOCATION="file:///app/hyperlane-validator-signatures-kasplextestnet"
MAILBOX="0xC505a8B225D46eB5252D96549C074e70855Fe4F3"
DOMAIN_ID="167012"

echo "🔐 Manually announcing validator..."
echo "📍 Validator: $VALIDATOR_ADDRESS"
echo "📁 Storage: $STORAGE_LOCATION"
echo ""

# Generate the announcement signature using EIP-712
# The signature proves that the validator controls the private key
echo "Generating announcement signature..."

# Create the announcement message hash
# This needs to match what the ValidatorAnnounce contract expects
MESSAGE_HASH=$(cast keccak "$(cast abi-encode 'announce(address,address,uint32,string)' $VALIDATOR_ADDRESS $MAILBOX $DOMAIN_ID "$STORAGE_LOCATION")")

echo "Message hash: $MESSAGE_HASH"

# Sign the message
SIGNATURE=$(cast wallet sign --no-hash $MESSAGE_HASH --private-key $HYP_KEY)

echo "Signature: $SIGNATURE"
echo ""

# Try to call the announce function with the generated signature
# Kasplex testnet has a 30M gas limit per block and ~2000 Gwei base fee
echo "Sending announcement transaction with manual gas limit (30M) and gas price (2500 Gwei)..."
cast send $VALIDATOR_ANNOUNCE \
  "announce(address,string,bytes)" \
  $VALIDATOR_ADDRESS \
  "$STORAGE_LOCATION" \
  "$SIGNATURE" \
  --rpc-url https://rpc.kasplextest.xyz \
  --private-key $HYP_KEY \
  --gas-limit 30000000 \
  --gas-price 2500000000000

echo ""
echo "Checking if announcement was successful..."
cast call $VALIDATOR_ANNOUNCE \
  "getAnnouncedStorageLocations(address[])" \
  "[$VALIDATOR_ADDRESS]" \
  --rpc-url https://rpc.kasplextest.xyz
