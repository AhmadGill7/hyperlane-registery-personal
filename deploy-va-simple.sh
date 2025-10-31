#!/bin/bash

# Simple ValidatorAnnounce Deployment Script
set -e

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY not set"
    exit 1
fi

MAILBOX="0xC505a8B225D46eB5252D96549C074e70855Fe4F3"
RPC_URL="https://rpc.kasplextest.xyz"

echo "🚀 Deploying ValidatorAnnounce contract..."
echo "Mailbox: $MAILBOX"
echo "RPC: $RPC_URL"
echo ""

# Use forge with explicit broadcast flag
forge create ValidatorAnnounce.sol:ValidatorAnnounce \
    --rpc-url "$RPC_URL" \
    --private-key "$HYP_KEY" \
    --constructor-args "$MAILBOX" \
    --legacy \
    --broadcast \
    2>&1 | tee deploy-output.txt

echo ""
echo "✅ Deployment output saved to deploy-output.txt"
