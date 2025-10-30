#!/bin/bash

# Check message delivery status

echo "🔍 Checking Bridge Status"
echo "================================"
echo ""

BSC_MAILBOX="0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D"
KASPLEX_MAILBOX="0xC505a8B225D46eB5252D96549C074e70855Fe4F3"

echo "📊 BSC Testnet Status:"
echo "Latest message nonce:"
cast call $BSC_MAILBOX "nonce()" --rpc-url https://bsc-testnet.publicnode.com
echo ""

echo "Latest dispatched message ID:"
cast call $BSC_MAILBOX "latestDispatchedId()" --rpc-url https://bsc-testnet.publicnode.com
echo ""

echo "📊 Kasplex Testnet Status:"
echo "Delivered count:"
cast call $KASPLEX_MAILBOX "nonce()" --rpc-url https://rpc.kasplextest.xyz
echo ""

echo "💡 Tips:"
echo "- If BSC nonce increases, a message was sent"
echo "- If Kasplex nonce increases, a message was delivered"
echo "- Check validator signature directories:"
echo "  ls -la hyperlane-validator-signatures-bsctestnet/"
echo "  ls -la hyperlane-validator-signatures-kasplextestnet/"
