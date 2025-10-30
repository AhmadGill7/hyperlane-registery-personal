#!/bin/bash

# Restart Bridge Components
# This script cleanly restarts all bridge components with fresh sync

echo "🛑 Stopping all running containers..."
docker stop validator-bsc validator-kasplex relayer 2>/dev/null || true

echo ""
echo "🗑️  Cleaning relayer database to force fresh sync..."
rm -rf hyperlane-db-relayer/*

echo ""
echo "✅ Cleanup complete!"
echo ""
echo "📋 Next steps:"
echo "1. Terminal 1: Run ./run-validator-bsc.sh"
echo "2. Terminal 2: Run ./run-validator-kasplex.sh" 
echo "3. Terminal 3: Run ./run-relayer.sh"
echo ""
echo "Changes made:"
echo "  ✓ Relayer now starts from recent blocks only (BSC: 70650000, Kasplex: 9400000)"
echo "  ✓ Relayer uses multiple BSC RPC endpoints for reliability"
echo "  ✓ Kasplex validator announcement attempts reduced to every 5 minutes"
echo ""
