# Kasplex Testnet Setup Guide for Hyperlane Bridge

This guide will help you set up the complete architecture for bridging from BSC Testnet to Kasplex Testnet.

## Architecture Overview

For a Hyperlane bridge to work, you need these components on **BOTH** chains:

### 1. Core Contracts (Deployed on Kasplex Testnet)
- **Mailbox**: The main contract for sending and receiving messages
- **ProxyAdmin**: Admin contract for upgrades
- **Validator Announce**: Contract where validators announce their signing addresses
- **ISM (Interchain Security Module)**: Validates incoming messages
- **Hooks**: For gas payments and routing
- **Storage Gas Oracle**: For gas price estimation

### 2. Relayer
- Watches the source chain (BSC Testnet) for messages
- Delivers messages to the destination chain (Kasplex Testnet)
- Can be run by anyone (permissionless)

### 3. Validator(s)
- Attests to messages on the source chain
- Signs message metadata that proves a message was sent
- Minimum 1 validator required, 2+ recommended for security

## Step-by-Step Setup Process

### Phase 1: Prepare Chain Metadata

1. **Get Kasplex Testnet Details**
   ```bash
   # You need to know:
   - Chain ID
   - RPC URL(s)
   - Block explorer URL
   - Native token details (name, symbol, decimals)
   - Block time and reorg period
   ```

2. **Update metadata.yaml**
   - Edit: `chains/kasplextestnet/metadata.yaml`
   - Fill in the actual values (currently has placeholders)
   - Key fields:
     * chainId
     * domainId (usually same as chainId)
     * rpcUrls
     * blockExplorers
     * nativeToken info
     * blocks.estimateBlockTime
     * blocks.reorgPeriod

3. **Add a logo**
   - Create or download a logo for Kasplex
   - Save as: `chains/kasplextestnet/logo.svg`

### Phase 2: Deploy Hyperlane Core Contracts to Kasplex

You need to deploy the core Hyperlane contracts to Kasplex Testnet using the Hyperlane CLI.

#### Prerequisites
```bash
# Install Hyperlane CLI
npm install -g @hyperlane-xyz/cli

# Or use npx
npx @hyperlane-xyz/cli --help
```

#### Deployment Steps

1. **Deploy Core Contracts**
   ```bash
   # Navigate to your registry directory
   cd d:/hyperlane-registry

   # Deploy core contracts to Kasplex testnet
   hyperlane deploy core \
     --registry . \
     --chain kasplextestnet \
     --key <YOUR_PRIVATE_KEY>
   ```

   This will deploy:
   - Mailbox
   - ProxyAdmin
   - ValidatorAnnounce
   - ISM Factory contracts
   - Hook contracts
   - Storage Gas Oracle
   - And more...

2. **Save the Addresses**
   - After deployment, the CLI will output all contract addresses
   - Create: `chains/kasplextestnet/addresses.yaml`
   - Copy the addresses from the deployment output

   Example format:
   ```yaml
   mailbox: "0x..."
   proxyAdmin: "0x..."
   validatorAnnounce: "0x..."
   interchainGasPaymaster: "0x..."
   # ... etc
   ```

### Phase 3: Set Up Validators

Validators attest to messages. You need at least 1 validator.

#### Option A: Run Your Own Validator

1. **Set up a server** (cloud VM or local)

2. **Install the validator software**
   ```bash
   # Clone Hyperlane monorepo
   git clone https://github.com/hyperlane-xyz/hyperlane-monorepo.git
   cd hyperlane-monorepo

   # Install dependencies
   yarn install

   # Build
   yarn build
   ```

3. **Create validator configuration**
   Create a config file `validator-config.json`:
   ```json
   {
     "originChainName": "bsctestnet",
     "validator": {
       "id": "0xYourValidatorAddress",
       "type": "aws",
       "region": "us-east-1"
     },
     "checkpointSyncer": {
       "type": "localStorage",
       "path": "./validator-signatures"
     },
     "chains": {
       "bsctestnet": {
         "rpcUrls": ["https://bsc-testnet.publicnode.com"]
       }
     }
   }
   ```

4. **Run the validator**
   ```bash
   yarn workspace @hyperlane-xyz/validator run validator \
     --configFile ./validator-config.json
   ```

5. **Announce your validator**
   ```bash
   hyperlane validator announce \
     --chain bsctestnet \
     --validator 0xYourValidatorAddress \
     --mailbox 0xMailboxAddressOnBSCTestnet
   ```

#### Option B: Use an Existing Validator Service
- Contact validator providers
- Or use a community-run validator (if available)

### Phase 4: Set Up Relayer

The relayer watches for messages and delivers them.

#### Option A: Run Your Own Relayer

1. **Install relayer**
   ```bash
   # In hyperlane-monorepo
   cd typescript/infra
   ```

2. **Create relayer configuration**
   Create `relayer-config.json`:
   ```json
   {
     "relayChains": ["bsctestnet", "kasplextestnet"],
     "chains": {
       "bsctestnet": {
         "rpcUrls": ["https://bsc-testnet.publicnode.com"],
         "mailbox": "0xF9F6F5646F478d5ab4e20B0F910C92F1CCC9Cc6D"
       },
       "kasplextestnet": {
         "rpcUrls": ["https://rpc-testnet.kasplex.io"],
         "mailbox": "0xYourKasplexMailboxAddress"
       }
     },
     "gasPaymentEnforcement": {
       "policy": "none"
     }
   }
   ```

3. **Run the relayer**
   ```bash
   yarn workspace @hyperlane-xyz/relayer run relayer \
     --configFile ./relayer-config.json
   ```

#### Option B: Use Hyperlane's Relayer Service
- For testnets, Hyperlane sometimes runs relayers
- Check the Hyperlane Discord/docs

### Phase 5: Configure Warp Route (Token Bridge)

Once core contracts are deployed, you can create a warp route for token bridging.

1. **Create warp route config**
   ```bash
   # Example: Bridge a token from BSC Testnet to Kasplex Testnet
   hyperlane warp init \
     --registry . \
     --chains bsctestnet,kasplextestnet
   ```

2. **Deploy warp route**
   ```bash
   hyperlane warp deploy \
     --registry . \
     --config ./warp-route-config.yaml
   ```

3. **Update registry**
   - Add the warp route config to `deployments/warp_routes/warpRouteConfigs.yaml`

### Phase 6: Test Your Bridge

1. **Send a test message**
   ```bash
   hyperlane send message \
     --origin bsctestnet \
     --destination kasplextestnet \
     --message "Hello Kasplex!"
   ```

2. **Monitor the message**
   - Check the Hyperlane Explorer: https://explorer.hyperlane.xyz
   - Watch relayer logs
   - Check validator signatures

## Common Issues & Solutions

### Issue: "Route not working"
**Possible causes:**
- Core contracts not deployed on one or both chains
- Validator not running or not announced
- Relayer not running or misconfigured
- ISM not configured to accept your validators
- Gas payment not sufficient

**Solutions:**
- Verify all contract addresses exist in `addresses.yaml`
- Check validator is running: `curl http://validator-url/health`
- Check relayer logs for errors
- Verify ISM configuration matches your validator addresses
- Ensure gas payment hook is configured

### Issue: "Validator not signing"
**Solutions:**
- Ensure validator has announced on the ValidatorAnnounce contract
- Check validator has access to the RPC
- Verify validator private key is correct
- Check validator logs

### Issue: "Relayer not delivering"
**Solutions:**
- Check relayer has funds on destination chain for gas
- Verify relayer config has correct mailbox addresses
- Check relayer has access to both RPCs
- Verify message was sent and validator signed it

## Verification Checklist

Before declaring success, verify:

- [ ] `chains/kasplextestnet/metadata.yaml` has correct info
- [ ] `chains/kasplextestnet/addresses.yaml` exists with deployed addresses
- [ ] `chains/kasplextestnet/logo.svg` exists
- [ ] Core contracts deployed on Kasplex Testnet
- [ ] At least 1 validator running and announced
- [ ] Relayer running and watching both chains
- [ ] ISM on Kasplex configured to accept your validator(s)
- [ ] ISM on BSC Testnet configured to accept your validator(s)
- [ ] Test message successfully sent and received
- [ ] Warp route deployed (if doing token bridging)

## Resources

- **Hyperlane Docs**: https://docs.hyperlane.xyz
- **Hyperlane CLI**: https://docs.hyperlane.xyz/docs/reference/cli
- **Deploy Core**: https://docs.hyperlane.xyz/docs/deploy/deploy-hyperlane
- **Deploy Warp Route**: https://docs.hyperlane.xyz/docs/deploy/deploy-warp-route
- **Run Validators**: https://docs.hyperlane.xyz/docs/operate/validators/run-validators
- **Run Relayer**: https://docs.hyperlane.xyz/docs/operate/relayer/run-relayer
- **Hyperlane Explorer**: https://explorer.hyperlane.xyz

## Next Steps

1. **Fill in the actual Kasplex Testnet details** in `metadata.yaml`
2. **Add a logo** for Kasplex
3. **Deploy core contracts** using the CLI
4. **Update addresses.yaml** with deployment results
5. **Set up and run a validator**
6. **Set up and run a relayer**
7. **Test the bridge** with a sample message
8. **Deploy warp route** for token bridging

## Questions?

If you're stuck:
1. Check the Hyperlane Discord: https://discord.gg/hyperlane
2. Review the documentation
3. Look at existing chain configurations in this repo (sepolia, bsctestnet, etc.)
4. Check the Hyperlane Explorer for similar chains
