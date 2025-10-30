#!/bin/bash

# Alternative test script - builds and broadcasts transaction manually

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    exit 1
fi

BSC_MAILBOX="0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D"
KASPLEX_TEST_RECIPIENT="0xcA9caDDf76CCa01c6D369f8228a6B95A9F5fE801"
KASPLEX_DOMAIN_ID="167012"

echo "🧪 Testing Hyperlane Bridge (Alternative Method)"
echo "=================================================="
echo ""

MESSAGE="0x$(echo -n "Hello from BSC!" | xxd -p)"
RECIPIENT_BYTES32=$(cast --to-bytes32 $KASPLEX_TEST_RECIPIENT)

echo "Building transaction..."
echo "Recipient: $KASPLEX_TEST_RECIPIENT"
echo "Message: Hello from BSC!"
echo ""

# Use cast with --async flag to not wait for confirmation
echo "Sending transaction (async)..."
TX_HASH=$(cast send $BSC_MAILBOX \
  "dispatch(uint32,bytes32,bytes)" \
  $KASPLEX_DOMAIN_ID \
  $RECIPIENT_BYTES32 \
  $MESSAGE \
  --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545 \
  --private-key $HYP_KEY \
  --value 1 \
  --legacy \
  --async 2>&1 | grep -oP '0x[a-fA-F0-9]{64}' | head -1)

if [ -n "$TX_HASH" ]; then
  echo "✅ Transaction sent!"
  echo "TX Hash: $TX_HASH"
  echo ""
  echo "🔍 View on BscScan:"
  echo "https://testnet.bscscan.com/tx/$TX_HASH"
  echo ""
  echo "Waiting 30 seconds for confirmation..."
  sleep 30
  
  echo "Checking receipt..."
  cast receipt $TX_HASH --rpc-url https://data-seed-prebsc-1-s1.binance.org:8545
else
  echo "❌ Failed to send transaction"
fi
