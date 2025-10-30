# Kasplex Testnet Bridge Status - Quick Reference

## Current Status

### ✅ Working: Sepolia ↔ BSC Testnet
- Both chains have complete metadata
- Both chains have deployed Hyperlane core contracts
- Validators and relayers are operational
- Messages can flow in both directions

### ❌ Not Working: BSC Testnet ↔ Kasplex Testnet
**Reason**: Kasplex Testnet is missing the complete Hyperlane infrastructure

## What's Missing for Kasplex Testnet

### 1. Chain Configuration Files
- ✅ `metadata.yaml` - CREATED (needs actual values)
- ❌ `addresses.yaml` - NOT YET DEPLOYED
- ❌ `logo.svg` - NEEDS TO BE ADDED

### 2. Core Contract Deployment
Status: **NOT DEPLOYED**

Kasplex Testnet needs these contracts deployed:
- Mailbox (the heart of Hyperlane messaging)
- ProxyAdmin (for upgrades)
- ValidatorAnnounce (validator registry)
- Interchain Gas Paymaster (gas payments)
- ISM (Interchain Security Module) contracts
- Hook contracts (for routing and fees)
- Storage Gas Oracle

### 3. Validator Infrastructure
Status: **NOT CONFIGURED**

Needs:
- At least 1 validator to sign messages from BSC Testnet → Kasplex Testnet
- At least 1 validator to sign messages from Kasplex Testnet → BSC Testnet
- Validators announced on both chains

### 4. Relayer Infrastructure
Status: **NOT RUNNING**

Needs:
- Relayer configured to watch BSC Testnet and deliver to Kasplex Testnet
- Relayer configured to watch Kasplex Testnet and deliver to BSC Testnet
- Relayer funded with gas on both chains

## Comparison: Working Route vs. Non-Working Route

### Sepolia (Working)
```yaml
# metadata.yaml ✅
chainId: 11155111
domainId: 11155111
rpcUrls: [Working RPCs]
# ... complete config

# addresses.yaml ✅
mailbox: "0xfFAEF09B3cd11D9b20d1a19bECca54EEC2884766"
validatorAnnounce: "0xE6105C59480a1B7DD3E4f28153aFdbE12F4CfCD9"
# ... all contracts deployed
```

### BSC Testnet (Working)
```yaml
# metadata.yaml ✅
chainId: 97
domainId: 97
rpcUrls: [Working RPCs]
# ... complete config

# addresses.yaml ✅
mailbox: "0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D"
validatorAnnounce: "0xf09701B0a93210113D175461b6135a96773B5465"
# ... all contracts deployed
```

### Kasplex Testnet (NOT Working)
```yaml
# metadata.yaml ⚠️ TEMPLATE ONLY
chainId: 999999  # <-- PLACEHOLDER, needs real value
domainId: 999999  # <-- PLACEHOLDER, needs real value
rpcUrls: ["https://rpc-testnet.kasplex.io"]  # <-- needs real RPC
# ... config has placeholders

# addresses.yaml ❌ DOESN'T EXIST
# No contracts deployed yet
```

## Why Your Route Isn't Working

When you try to create a route from BSC Testnet → Kasplex Testnet:

1. **Message Sending** ✅ Works on BSC Testnet
   - BSC Testnet has a mailbox
   - You can call `mailbox.dispatch()` to send a message

2. **Validator Signing** ❌ FAILS
   - No validator is watching Kasplex Testnet
   - Even if watching, Kasplex doesn't have a ValidatorAnnounce contract

3. **Message Delivery** ❌ FAILS
   - Kasplex Testnet has no Mailbox contract to receive messages
   - No relayer knows to deliver to Kasplex
   - Even if a relayer tried, there's no mailbox.process() to call

## Action Plan (In Order)

### Step 1: Get Real Kasplex Information
You need to find out:
```bash
# From Kasplex documentation or team:
- What is the actual chain ID?
- What are the public RPC URLs?
- What is the block explorer URL?
- What is the native token (name, symbol, decimals)?
- What is the average block time?
- What is the reorg period (blocks before finality)?
```

### Step 2: Update metadata.yaml
Replace all the placeholder values in:
`chains/kasplextestnet/metadata.yaml`

### Step 3: Add a Logo
Get or create a logo and save as:
`chains/kasplextestnet/logo.svg`

### Step 4: Deploy Core Contracts
```bash
# Using Hyperlane CLI
hyperlane deploy core \
  --registry . \
  --chain kasplextestnet \
  --key <YOUR_PRIVATE_KEY>
```

This is the BIG step - it deploys ~20+ contracts to Kasplex.

### Step 5: Save Deployment Addresses
After Step 4, create:
`chains/kasplextestnet/addresses.yaml`

With all the deployed contract addresses.

### Step 6: Configure & Run Validator
Set up a validator that:
- Watches BSC Testnet mailbox
- Watches Kasplex Testnet mailbox
- Signs attestations for both

### Step 7: Configure & Run Relayer
Set up a relayer that:
- Watches for messages on BSC Testnet
- Delivers to Kasplex Testnet
- Watches for messages on Kasplex Testnet
- Delivers to BSC Testnet

### Step 8: Test
Send a test message and verify it's delivered!

## Common Misconceptions

❌ "The registry configuration is enough to make it work"
→ No, you also need actual deployed contracts

❌ "If I add the chain to warpRouteConfigs.yaml, the route will work"
→ No, the underlying Hyperlane contracts must be deployed first

❌ "The relayer and validator are the same thing"
→ No, they're different:
  - Validator: Signs attestations (proves message was sent)
  - Relayer: Delivers messages (transports them to destination)

✅ "I need to deploy contracts, run a validator, and run a relayer"
→ YES! This is correct.

## Helpful Commands

### Check if contracts are deployed:
```bash
# Check if mailbox exists on Kasplex
cast code <MAILBOX_ADDRESS> --rpc-url https://rpc-testnet.kasplex.io

# If it returns "0x", the contract doesn't exist
# If it returns bytecode, the contract exists
```

### Verify your metadata:
```bash
# In the registry directory
npm run validate
```

### Test RPC connection:
```bash
# Test if you can connect to Kasplex RPC
cast block latest --rpc-url https://rpc-testnet.kasplex.io
```

## Need Help?

1. **Kasplex Details**: Contact the Kasplex team for accurate chain information
2. **Hyperlane Deployment**: Follow the guide in `KASPLEX_SETUP_GUIDE.md`
3. **Hyperlane Support**: Join Discord at https://discord.gg/hyperlane
4. **This Repo**: Check other testnets like `sepolia` or `bsctestnet` as examples

## TL;DR

**Problem**: Kasplex Testnet has no Hyperlane infrastructure deployed

**Solution**: Deploy core contracts + run validator + run relayer

**Next Step**: Update `metadata.yaml` with real Kasplex values, then deploy contracts using Hyperlane CLI
