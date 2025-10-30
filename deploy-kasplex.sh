#!/bin/bash

# Kasplex Testnet Deployment Script for Hyperlane
# This script helps you deploy Hyperlane core contracts to Kasplex Testnet

set -e  # Exit on error

echo "🚀 Kasplex Testnet Hyperlane Deployment Script"
echo "=============================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Hyperlane CLI is installed
if ! command -v hyperlane &> /dev/null; then
    echo -e "${RED}❌ Hyperlane CLI not found!${NC}"
    echo "Installing Hyperlane CLI globally..."
    npm install -g @hyperlane-xyz/cli
    echo -e "${GREEN}✅ Hyperlane CLI installed${NC}"
fi

echo "Hyperlane CLI version:"
hyperlane --version
echo ""

# Get the registry path
REGISTRY_PATH="$(pwd)"
echo "Using registry: $REGISTRY_PATH"
echo ""

# Check if private key is set
if [ -z "$HYP_KEY" ]; then
    echo -e "${YELLOW}⚠️  HYP_KEY environment variable not set${NC}"
    echo "Please set your private key:"
    echo "  export HYP_KEY=\"your_private_key_here\""
    echo ""
    read -p "Do you want to enter it now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -sp "Enter your private key: " HYP_KEY
        export HYP_KEY
        echo ""
        echo -e "${GREEN}✅ Private key set${NC}"
    else
        echo -e "${RED}❌ Cannot proceed without private key${NC}"
        exit 1
    fi
fi

# Verify Kasplex RPC is accessible
echo "Checking Kasplex Testnet RPC..."
RPC_RESPONSE=$(curl -s -X POST https://rpc.kasplextest.xyz \
    -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}')

# Extract chain ID using grep and sed (works without jq)
CHAIN_ID=$(echo "$RPC_RESPONSE" | grep -o '"result":"[^"]*"' | sed 's/"result":"//' | sed 's/"//')

if [ -z "$CHAIN_ID" ] || [ "$CHAIN_ID" == "null" ]; then
    echo -e "${RED}❌ Cannot connect to Kasplex RPC${NC}"
    echo "Response: $RPC_RESPONSE"
    exit 1
fi

CHAIN_ID_DEC=$((CHAIN_ID))
echo -e "${GREEN}✅ Connected to Kasplex Testnet (Chain ID: $CHAIN_ID_DEC)${NC}"
echo ""

# Verify chain ID matches metadata
if [ "$CHAIN_ID_DEC" != "167012" ]; then
    echo -e "${YELLOW}⚠️  Warning: Chain ID mismatch!${NC}"
    echo "RPC reports: $CHAIN_ID_DEC"
    echo "Metadata has: 167012"
    echo ""
fi

# Check if addresses.yaml already exists
if [ -f "$REGISTRY_PATH/chains/kasplextestnet/addresses.yaml" ]; then
    echo -e "${YELLOW}⚠️  addresses.yaml already exists for Kasplex Testnet${NC}"
    echo "This might mean contracts are already deployed."
    echo ""
    read -p "Do you want to redeploy? This will create new contracts. (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Deployment cancelled."
        exit 0
    fi
    # Backup existing file
    cp "$REGISTRY_PATH/chains/kasplextestnet/addresses.yaml" \
       "$REGISTRY_PATH/chains/kasplextestnet/addresses.yaml.backup.$(date +%s)"
    echo -e "${GREEN}✅ Backed up existing addresses.yaml${NC}"
fi

# Deploy core contracts
echo ""
echo "================================================"
echo "🚀 Deploying Hyperlane Core Contracts"
echo "================================================"
echo ""
echo "Chain: kasplextestnet"
echo "Registry: $REGISTRY_PATH"
echo ""
echo "This will deploy:"
echo "  - Mailbox"
echo "  - ProxyAdmin"
echo "  - ValidatorAnnounce"
echo "  - Interchain Gas Paymaster"
echo "  - ISM Factories"
echo "  - Hook Contracts"
echo "  - Storage Gas Oracle"
echo "  - And more..."
echo ""

read -p "Ready to deploy? This will cost gas on Kasplex Testnet. (y/n) " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Deployment cancelled."
    exit 0
fi

echo ""
echo "Starting deployment..."
echo ""

# Run the deployment
hyperlane core deploy \
    --chain kasplextestnet \
    --registry "$REGISTRY_PATH" \
    --key "$HYP_KEY" \
    --yes

echo ""
echo "================================================"
echo "✅ Deployment Complete!"
echo "================================================"
echo ""

# Check if addresses.yaml was created
if [ -f "$REGISTRY_PATH/chains/kasplextestnet/addresses.yaml" ]; then
    echo -e "${GREEN}✅ addresses.yaml created successfully${NC}"
    echo ""
    echo "Deployed contracts:"
    cat "$REGISTRY_PATH/chains/kasplextestnet/addresses.yaml"
    echo ""
else
    echo -e "${YELLOW}⚠️  addresses.yaml not found${NC}"
    echo "You may need to manually create it with the deployment output above."
    echo ""
fi

echo "================================================"
echo "📋 Next Steps"
echo "================================================"
echo ""
echo "1. ✅ Core contracts deployed"
echo ""
echo "2. ⏳ Set up validators:"
echo "   - Clone hyperlane-monorepo"
echo "   - Create validator config files"
echo "   - Run validators for both chains"
echo "   - Announce validators on-chain"
echo ""
echo "3. ⏳ Set up relayer:"
echo "   - Create relayer config"
echo "   - Fund relayer address on both chains"
echo "   - Run relayer"
echo ""
echo "4. ⏳ Configure ISM:"
echo "   - Create ISM config with your validator addresses"
echo "   - Deploy ISM to both chains"
echo ""
echo "5. ⏳ Test the bridge:"
echo "   - Send a test message"
echo "   - Monitor on Hyperlane Explorer"
echo ""
echo "For detailed instructions, see:"
echo "  - KASPLEX_DEPLOYMENT_PLAN.md"
echo "  - KASPLEX_SETUP_GUIDE.md"
echo ""
echo "Happy bridging! 🌉"
