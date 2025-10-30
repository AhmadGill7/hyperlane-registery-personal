# Kasplex Testnet Deployment Plan

## Current Status: Ready for Deployment

### ✅ Verified Information
- **Chain ID**: 167012 (verified via RPC)
- **RPC URL**: https://rpc.kasplextest.xyz (working)
- **Metadata**: Complete and accurate
- **Repository**: Set up correctly

## Step-by-Step Deployment Guide

### Prerequisites Checklist

Before starting, ensure you have:

- [ ] Node.js and npm/yarn installed
- [ ] Private key with Kasplex testnet tokens for gas (minimum ~1 KAS recommended)
- [ ] Hyperlane CLI installed globally (`npm install -g @hyperlane-xyz/cli`)
- [ ] This repository configured as your registry
- [ ] Access to a server/VM for running validator and relayer (optional but recommended)

### Phase 1: Install Hyperlane CLI

```bash
# Install the Hyperlane CLI globally
npm install -g @hyperlane-xyz/cli

# Verify installation
hyperlane --version
```

### Phase 2: Deploy Core Contracts to Kasplex Testnet

This is the most critical step. You need to deploy all core Hyperlane contracts to Kasplex.

#### Step 2.1: Set up your environment

```bash
# Navigate to your registry directory
cd d:/hyperlane-registery-personal

# Set your private key (DO NOT commit this!)
export HYP_KEY="your_private_key_here"
```

#### Step 2.2: Deploy core contracts

```bash
# Deploy using the Hyperlane CLI
hyperlane core deploy \
  --chain kasplextestnet \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY \
  --yes
```

**What this deploys:**
- Mailbox (main messaging contract)
- ProxyAdmin (upgrades management)
- ValidatorAnnounce (validator registry)
- Interchain Gas Paymaster (gas payment handling)
- Various ISM (Interchain Security Module) factories
- Hook contracts (for routing and fees)
- Storage Gas Oracle (gas estimation)
- Test contracts

**Expected Output:**
The CLI will output all deployed contract addresses. Save these!

#### Step 2.3: Update addresses.yaml

After deployment completes, you'll see output like:

```
✅ Core contracts deployed!

Deployment addresses:
  mailbox: 0x1234...
  proxyAdmin: 0x5678...
  validatorAnnounce: 0x9abc...
  ...
```

Create `chains/kasplextestnet/addresses.yaml` with these addresses:

```yaml
aggregationHook: "0x..."
domainRoutingIsm: "0x..."
domainRoutingIsmFactory: "0x..."
fallbackRoutingHook: "0x..."
interchainGasPaymaster: "0x..."
interchainSecurityModule: "0x..."
mailbox: "0x..."
merkleTreeHook: "0x..."
pausableHook: "0x..."
pausableIsm: "0x..."
protocolFee: "0x..."
proxyAdmin: "0x..."
staticAggregationHookFactory: "0x..."
staticAggregationIsm: "0x..."
staticAggregationIsmFactory: "0x..."
staticMerkleRootMultisigIsmFactory: "0x..."
staticMerkleRootWeightedMultisigIsmFactory: "0x..."
staticMessageIdMultisigIsmFactory: "0x..."
staticMessageIdWeightedMultisigIsmFactory: "0x..."
storageGasOracle: "0x..."
testRecipient: "0x..."
testTokenRecipient: "0x..."
timelockController: "0x..."
validatorAnnounce: "0x..."
```

### Phase 3: Set Up Validators

Validators attest to messages on the source chain. You need validators for both directions:
- BSC Testnet → Kasplex Testnet
- Kasplex Testnet → BSC Testnet

#### Option A: Run Your Own Validator (Recommended for Learning)

**Step 3.1: Clone Hyperlane Monorepo**

```bash
# In a separate directory (not your registry)
cd ~
git clone https://github.com/hyperlane-xyz/hyperlane-monorepo.git
cd hyperlane-monorepo

# Install dependencies
yarn install

# Build the project
yarn build
```

**Step 3.2: Create Validator Configuration**

Create a config file `validator-config-bsctestnet.json` for BSC Testnet:

```json
{
  "originChainName": "bsctestnet",
  "validator": {
    "type": "hexKey",
    "key": "0xYOUR_VALIDATOR_PRIVATE_KEY"
  },
  "checkpointSyncer": {
    "type": "localStorage",
    "path": "./validator-signatures-bsc"
  },
  "chains": {
    "bsctestnet": {
      "rpcUrls": [
        {
          "http": "https://bsc-testnet.publicnode.com"
        }
      ]
    }
  }
}
```

Create another config `validator-config-kasplextestnet.json` for Kasplex:

```json
{
  "originChainName": "kasplextestnet",
  "validator": {
    "type": "hexKey",
    "key": "0xYOUR_VALIDATOR_PRIVATE_KEY"
  },
  "checkpointSyncer": {
    "type": "localStorage",
    "path": "./validator-signatures-kasplex"
  },
  "chains": {
    "kasplextestnet": {
      "rpcUrls": [
        {
          "http": "https://rpc.kasplextest.xyz"
        }
      ]
    }
  }
}
```

**Step 3.3: Run the Validators**

```bash
# Run BSC Testnet validator (in one terminal)
cd ~/hyperlane-monorepo
yarn workspace @hyperlane-xyz/validator run validator \
  --configFile ./validator-config-bsctestnet.json

# Run Kasplex Testnet validator (in another terminal)
cd ~/hyperlane-monorepo
yarn workspace @hyperlane-xyz/validator run validator \
  --configFile ./validator-config-kasplextestnet.json
```

**Step 3.4: Announce Your Validators**

After validators are running, you need to announce them on-chain:

```bash
# Announce validator on BSC Testnet
hyperlane validator announce \
  --chain bsctestnet \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY

# Announce validator on Kasplex Testnet
hyperlane validator announce \
  --chain kasplextestnet \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY
```

#### Option B: Use a Validator Service

Contact Hyperlane community or validator service providers. For testnets, sometimes Hyperlane runs validators.

### Phase 4: Set Up Relayer

The relayer watches for messages and delivers them cross-chain.

#### Step 4.1: Create Relayer Configuration

Create `relayer-config.json`:

```json
{
  "relayChains": ["bsctestnet", "kasplextestnet"],
  "chains": {
    "bsctestnet": {
      "rpcUrls": [
        {
          "http": "https://bsc-testnet.publicnode.com"
        }
      ]
    },
    "kasplextestnet": {
      "rpcUrls": [
        {
          "http": "https://rpc.kasplextest.xyz"
        }
      ]
    }
  },
  "gasPaymentEnforcement": [
    {
      "type": "none"
    }
  ],
  "allowLocalCheckpointSyncers": true,
  "db": "./relayer-db"
}
```

#### Step 4.2: Run the Relayer

```bash
# Make sure you're in the hyperlane-monorepo directory
cd ~/hyperlane-monorepo

# Set relayer private key (needs gas on both chains!)
export HYP_BASE_RELAYCHAINS_BSCTESTNET_SIGNER_KEY="0xYOUR_RELAYER_PRIVATE_KEY"
export HYP_BASE_RELAYCHAINS_KASPLEXTESTNET_SIGNER_KEY="0xYOUR_RELAYER_PRIVATE_KEY"

# Run the relayer
yarn workspace @hyperlane-xyz/relayer run relayer \
  --configFile ./relayer-config.json
```

**Important**: The relayer needs native tokens on BOTH chains:
- BNB on BSC Testnet
- KAS on Kasplex Testnet

### Phase 5: Configure ISM (Interchain Security Module)

The ISM validates incoming messages. You need to configure it to accept your validators.

#### Step 5.1: Create ISM Configuration

Create `ism-config.yaml`:

```yaml
# For BSC Testnet to accept messages from Kasplex
bsctestnet:
  type: merkleRootMultisig
  threshold: 1
  validators:
    - "0xYOUR_VALIDATOR_ADDRESS"  # The address of your validator

# For Kasplex to accept messages from BSC Testnet  
kasplextestnet:
  type: merkleRootMultisig
  threshold: 1
  validators:
    - "0xYOUR_VALIDATOR_ADDRESS"  # The address of your validator
```

#### Step 5.2: Deploy ISM

```bash
hyperlane ism deploy \
  --config ./ism-config.yaml \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY \
  --yes
```

### Phase 6: Test the Bridge

#### Step 6.1: Send a Test Message

```bash
hyperlane send message \
  --origin bsctestnet \
  --destination kasplextestnet \
  --body "Hello Kasplex from BSC!" \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY
```

#### Step 6.2: Monitor the Message

1. Check the Hyperlane Explorer: https://explorer.hyperlane.xyz
2. Watch your validator logs - you should see it signing the message
3. Watch your relayer logs - you should see it delivering the message
4. Check the destination chain for the delivered message

### Phase 7: Deploy Warp Route (Token Bridge)

Once core infrastructure is working, you can deploy a warp route for token bridging.

#### Step 7.1: Initialize Warp Route

```bash
hyperlane warp init \
  --registry file://d:/hyperlane-registery-personal \
  --chains bsctestnet,kasplextestnet
```

This will create a warp route configuration file.

#### Step 7.2: Deploy Warp Route

```bash
hyperlane warp deploy \
  --config ./warp-route-config.yaml \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY \
  --yes
```

## Troubleshooting

### Issue: "Chain not found in registry"

**Solution**: Make sure you're using the registry flag:
```bash
--registry file://d:/hyperlane-registery-personal
```

### Issue: "Insufficient funds for gas"

**Solution**: Ensure your deployer address has enough KAS on Kasplex testnet. Get testnet tokens from Kasplex faucet.

### Issue: "Validator not signing"

**Possible causes**:
- Validator not running
- Validator not announced on-chain
- Wrong validator address in ISM config

**Solution**: 
- Check validator is running: `ps aux | grep validator`
- Verify announcement: Check ValidatorAnnounce contract
- Ensure validator address matches ISM config

### Issue: "Relayer not delivering messages"

**Possible causes**:
- Relayer out of gas on destination chain
- Relayer not watching the right chains
- Message not signed by validator yet

**Solution**:
- Fund relayer on both chains
- Check relayer config has correct chain names
- Wait for validator to sign (check validator logs)

### Issue: "Message rejected by ISM"

**Possible causes**:
- ISM not configured to accept your validator
- Wrong validator signing
- Threshold not met

**Solution**:
- Verify ISM configuration on destination chain
- Ensure validator address matches ISM config
- Check threshold settings (should be 1 for single validator)

## Verification Checklist

Before declaring success, verify:

- [ ] Kasplex testnet RPC is accessible
- [ ] Core contracts deployed to Kasplex (check addresses.yaml exists)
- [ ] `chains/kasplextestnet/addresses.yaml` created with real addresses
- [ ] Validator running for BSC Testnet
- [ ] Validator running for Kasplex Testnet
- [ ] Validators announced on both chains
- [ ] Relayer running and watching both chains
- [ ] Relayer funded on both chains
- [ ] ISM configured on BSC Testnet to accept Kasplex messages
- [ ] ISM configured on Kasplex to accept BSC Testnet messages
- [ ] Test message sent successfully
- [ ] Test message delivered successfully
- [ ] Message visible on Hyperlane Explorer

## Next Steps After Deployment

1. **Add a logo**: Create `chains/kasplextestnet/logo.svg`
2. **Document your deployment**: Update this file with actual addresses
3. **Commit to your repo**: Push the changes to GitHub
4. **Deploy warp routes**: Set up token bridges as needed
5. **Monitor infrastructure**: Keep validator and relayer running

## Important Notes

### Security Considerations

- **Never commit private keys** to the repository
- Use environment variables for sensitive data
- For production, use AWS KMS or similar for key management
- Run validators and relayers on separate servers for better security

### Cost Considerations

- **Deployment**: Requires gas on Kasplex (one-time cost)
- **Validator**: Minimal cost (just announces)
- **Relayer**: Ongoing gas costs on BOTH chains for message delivery
- For production, ensure adequate funding for the relayer

### Maintenance

- **Validators**: Should run continuously, monitor for downtime
- **Relayer**: Should run continuously, monitor for failures
- **Updates**: Keep Hyperlane CLI and monorepo updated
- **Monitoring**: Use Hyperlane Explorer to monitor message flow

## Resources

- **Hyperlane Docs**: https://docs.hyperlane.xyz
- **Hyperlane CLI**: https://docs.hyperlane.xyz/docs/reference/cli
- **Deploy Core**: https://docs.hyperlane.xyz/docs/deploy/deploy-hyperlane
- **Run Validators**: https://docs.hyperlane.xyz/docs/operate/validators/run-validators
- **Run Relayer**: https://docs.hyperlane.xyz/docs/operate/relayer/run-relayer
- **Hyperlane Explorer**: https://explorer.hyperlane.xyz
- **Hyperlane Discord**: https://discord.gg/hyperlane

## Contact & Support

- **Hyperlane Discord**: Best place for real-time help
- **GitHub Issues**: For CLI/monorepo bugs
- **Documentation**: For detailed guides and references

---

## Quick Start Commands Summary

```bash
# 1. Install CLI
npm install -g @hyperlane-xyz/cli

# 2. Deploy core contracts
export HYP_KEY="your_private_key"
cd d:/hyperlane-registery-personal
hyperlane core deploy \
  --chain kasplextestnet \
  --registry file://. \
  --key $HYP_KEY \
  --yes

# 3. Update addresses.yaml with deployment output

# 4. Set up validator
cd ~/hyperlane-monorepo
yarn install && yarn build
# Create validator-config files
# Run validators with yarn workspace commands

# 5. Announce validators
hyperlane validator announce --chain kasplextestnet --registry file://d:/hyperlane-registery-personal --key $HYP_KEY

# 6. Set up relayer
# Create relayer-config.json
# Run with yarn workspace @hyperlane-xyz/relayer run relayer

# 7. Test
hyperlane send message --origin bsctestnet --destination kasplextestnet --body "Test"
```

Good luck with your deployment! 🚀
