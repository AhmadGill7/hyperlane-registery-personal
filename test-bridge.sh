#!/bin/bash

# Test the Hyperlane bridge between BSC Testnet and Kasplex Testnet
# This script sends a test message from BSC to Kasplex

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    exit 1
fi

SENDER_ADDRESS=$(cast wallet address --private-key $HYP_KEY)

echo "🧪 Testing Hyperlane Bridge"
echo "================================"
echo "From: BSC Testnet"
echo "To: Kasplex Testnet"
echo "Sender: $SENDER_ADDRESS"
echo ""

# Contract addresses
BSC_MAILBOX="0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D"
BSC_TEST_RECIPIENT="0x36FdA966CfffF8a9Cdc814f546db0e6378bFef35"
KASPLEX_TEST_RECIPIENT="0xcA9caDDf76CCa01c6D369f8228a6B95A9F5fE801"
KASPLEX_DOMAIN_ID="167012"

echo "📤 Step 1: Sending test message from BSC Testnet..."
echo "Target: Kasplex Testnet (domain $KASPLEX_DOMAIN_ID)"
echo ""

# Encode the message - simple "Hello from BSC!"
MESSAGE="0x$(echo -n "Hello from BSC Testnet to Kasplex!" | xxd -p)"
echo "Message: Hello from BSC Testnet to Kasplex!"
echo "Encoded: $MESSAGE"
echo ""

# Send the message using the Mailbox contract
# dispatch(uint32 destinationDomain, bytes32 recipientAddress, bytes messageBody)
echo "Calling Mailbox.dispatch()..."

RECIPIENT_BYTES32=$(cast --to-bytes32 $KASPLEX_TEST_RECIPIENT)

echo "Sending transaction..."
cast send $BSC_MAILBOX \
  "dispatch(uint32,bytes32,bytes)" \
  $KASPLEX_DOMAIN_ID \
  $RECIPIENT_BYTES32 \
  $MESSAGE \
  --rpc-url https://bsc-testnet.publicnode.com \
  --private-key $HYP_KEY \
  --value 1 \
  --legacy \
  --confirmations 2

echo ""
echo "✅ Message sent!"
echo ""
echo "⏳ Now watch the validator and relayer logs to see it:"
echo "1. BSC Validator: Should sign a checkpoint containing this message"
echo "2. Relayer: Should detect, fetch signature, and deliver to Kasplex"
echo ""
echo "Check the latest message ID:"
cast call $BSC_MAILBOX "latestDispatchedId()" --rpc-url https://bsc-testnet.publicnode.com
