# Alternative Deployment Strategy for Kasplex Testnet

## The Problem

The Hyperlane CLI (v19.3.0) is not recognizing `kasplextestnet` from your local registry. This is because:

1. The CLI defaults to using the official Hyperlane GitHub registry
2. Kasplex Testnet is not in the official registry (it's a custom chain)
3. The local registry format might not match what the CLI expects

## Solutions (3 Options)

### Option 1: Use Hyperlane's Official Process (Recommended for Contributing)

If you want to use Hyperlane's tooling properly, you should:

1. **Submit a PR to the official Hyperlane registry** to add Kasplex Testnet
   - Fork: https://github.com/hyperlane-xyz/hyperlane-registry
   - Add your chain metadata
   - Submit PR and wait for approval
   - Once merged, the CLI will recognize it

**Pros**: Official support, works with all Hyperlane tools
**Cons**: Takes time, requires approval from Hyperlane team

### Option 2: Deploy Contracts Manually Using Hardhat/Foundry ⭐ FASTEST

Since the Hyperlane contracts are open source, you can deploy them yourself without the CLI.

**Steps**:

1. Clone the Hyperlane monorepo (you may have done this already)
2. Use Hardhat or Foundry to deploy the contracts directly
3. Manually record the deployed addresses

I can help you with this approach - it's faster and gives you more control.

### Option 3: Try Older Hyperlane CLI Version

Sometimes older versions of the CLI have different registry handling.

```bash
# Uninstall current version
npm uninstall -g @hyperlane-xyz/cli

# Try an older version
npm install -g @hyperlane-xyz/cli@3.x.x
```

## Recommended: Option 2 - Manual Deployment

This is the most practical solution for a custom testnet. Here's what we'll do:

### Step 1: Clone Hyperlane Monorepo

```bash
cd ~
git clone https://github.com/hyperlane-xyz/hyperlane-monorepo.git
cd hyperlane-monorepo
yarn install
```

### Step 2: Deploy Contracts Using Hardhat

The Hyperlane contracts can be deployed using Hardhat scripts.

```bash
cd typescript/infra

# Set your deployer private key
export DEPLOYER_PRIVATE_KEY="your_key_here"

# Deploy to Kasplex using Hardhat
npx hardhat run scripts/deploy-core.ts --network kasplextestnet
```

**But first**, you need to configure Kasplex in Hardhat config.

### Step 3: Configure Hardhat for Kasplex

Edit `hardhat.config.ts` to add Kasplex network:

```typescript
networks: {
  kasplextestnet: {
    url: "https://rpc.kasplextest.xyz",
    chainId: 167012,
    accounts: [process.env.DEPLOYER_PRIVATE_KEY]
  }
}
```

### Step 4: Deploy Contracts

Run the deployment script, which will:
- Deploy Mailbox
- Deploy ProxyAdmin
- Deploy Validator Announce
- Deploy all ISM factories
- Deploy hook contracts
- Deploy gas oracle

### Step 5: Record Addresses

Save all deployed addresses to your `chains/kasplextestnet/addresses.yaml`.

## Alternative: Use a Third-Party Registry Tool

You could also use tools like:
- **LayerZero** (if they support custom deployments)
- **Axelar** (different bridge, but might be easier for custom chains)
- **Wormhole** (another bridge option)

But if you specifically want Hyperlane, manual deployment is the way forward.

## What I Recommend We Do Next

Let me help you with **Option 2 (Manual Deployment)** because:

1. ✅ **Fastest** - No waiting for PR approval
2. ✅ **Full control** - You own the deployment
3. ✅ **Works immediately** - No CLI compatibility issues
4. ✅ **Learning experience** - Understand how Hyperlane works under the hood

I can guide you through deploying the Hyperlane contracts manually using Hardhat or Foundry.

## Or... Try One More Thing with the CLI

Let me try creating a properly formatted registry structure that the CLI might accept. The CLI expects registries to be in a specific format with certain files.

Would you like me to:

**A)** Help you manually deploy Hyperlane contracts using Hardhat/Foundry (faster, more reliable)

**B)** Try to fix the registry format to work with the CLI (might still have issues)

**C)** Help you submit a PR to add Kasplex to the official Hyperlane registry (proper long-term solution)

**I recommend Option A** - let's deploy the contracts manually. It will take about 30 minutes and you'll have full control.

What would you prefer?
