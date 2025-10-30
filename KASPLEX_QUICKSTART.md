# Kasplex Testnet Bridge Setup - Quick Start Guide

This guide will help you set up a complete Hyperlane bridge between BSC Testnet and Kasplex Testnet.

## 📋 Current Status

- ✅ **BSC Testnet**: Fully configured with Hyperlane contracts
- ✅ **Kasplex Testnet Metadata**: Configured and verified
- ⏳ **Kasplex Testnet Contracts**: Need to be deployed
- ⏳ **Validators**: Need to be set up and run
- ⏳ **Relayer**: Need to be configured and run

## 🎯 What You Need

### Prerequisites

1. **Node.js and npm** (v16 or higher)
2. **Private key with funds**:
   - BNB on BSC Testnet ([Get from faucet](https://testnet.bnbchain.org/faucet-smart))
   - KAS on Kasplex Testnet (Get from Kasplex faucet)
3. **A server or local machine** to run validator and relayer (can be the same machine for testing)

### Estimated Costs

- **Contract Deployment**: ~0.1-0.5 KAS on Kasplex (one-time)
- **Validator**: Minimal (just announcement transactions)
- **Relayer**: Ongoing gas costs on both chains for message delivery

## 🚀 Quick Start (5 Steps)

### Step 1: Deploy Core Contracts (10 minutes)

The easiest way to deploy:

```bash
# Navigate to your repository
cd d:/hyperlane-registery-personal

# Set your private key (NEVER commit this!)
export HYP_KEY="your_private_key_here"

# Run the deployment script
bash deploy-kasplex.sh
```

Or manually:

```bash
# Install Hyperlane CLI
npm install -g @hyperlane-xyz/cli

# Deploy
hyperlane core deploy \
  --chain kasplextestnet \
  --registry file://. \
  --key $HYP_KEY \
  --yes
```

**Expected time**: 5-10 minutes
**Output**: Contract addresses will be saved to `chains/kasplextestnet/addresses.yaml`

### Step 2: Set Up Validators (20 minutes)

Validators sign messages to prove they were sent.

```bash
# Clone Hyperlane monorepo (in a separate directory)
cd ~
git clone https://github.com/hyperlane-xyz/hyperlane-monorepo.git
cd hyperlane-monorepo

# Install and build
yarn install
yarn build

# Copy validator configs
cp d:/hyperlane-registery-personal/configs/kasplex-infrastructure/validator-*.json .

# Edit the configs and add your validator private key
# (Use a different key than your deployer key for security)
nano validator-bsctestnet.json  # Add your validator key
nano validator-kasplextestnet.json  # Add your validator key

# Run validators (in separate terminals)
# Terminal 1:
yarn workspace @hyperlane-xyz/validator run validator \
  --configFile ./validator-bsctestnet.json

# Terminal 2:
yarn workspace @hyperlane-xyz/validator run validator \
  --configFile ./validator-kasplextestnet.json
```

**Expected time**: 15-20 minutes
**Keep these running!** Validators need to run continuously.

### Step 3: Announce Validators (2 minutes)

Tell the chains about your validators:

```bash
# Get your validator address
cast wallet address --private-key <your-validator-private-key>

# Announce on BSC Testnet
hyperlane validator announce \
  --chain bsctestnet \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY

# Announce on Kasplex Testnet
hyperlane validator announce \
  --chain kasplextestnet \
  --registry file://d:/hyperlane-registery-personal \
  --key $HYP_KEY
```

### Step 4: Set Up Relayer (15 minutes)

The relayer delivers messages between chains.

```bash
# Still in hyperlane-monorepo directory
cd ~/hyperlane-monorepo

# Copy relayer config
cp d:/hyperlane-registery-personal/configs/kasplex-infrastructure/relayer-config.json .

# Update the Kasplex mailbox address in relayer-config.json
# (Use the mailbox address from chains/kasplextestnet/addresses.yaml)
nano relayer-config.json

# Set relayer private key (needs funds on BOTH chains!)
export HYP_BASE_RELAYCHAINS_BSCTESTNET_SIGNER_KEY="0xYOUR_RELAYER_PRIVATE_KEY"
export HYP_BASE_RELAYCHAINS_KASPLEXTESTNET_SIGNER_KEY="0xYOUR_RELAYER_PRIVATE_KEY"

# Run relayer (keep this running!)
yarn workspace @hyperlane-xyz/relayer run relayer \
  --configFile ./relayer-config.json
```

**Important**: Fund your relayer address with:
- BNB on BSC Testnet
- KAS on Kasplex Testnet

### Step 5: Configure ISM and Test (10 minutes)

Configure the Interchain Security Module to accept your validators:

```bash
cd d:/hyperlane-registery-personal

# Edit ISM config with your validator address
nano configs/kasplex-infrastructure/ism-config.yaml

# Deploy ISM
hyperlane ism deploy \
  --config configs/kasplex-infrastructure/ism-config.yaml \
  --registry file://. \
  --key $HYP_KEY \
  --yes

# Send a test message!
hyperlane send message \
  --origin bsctestnet \
  --destination kasplextestnet \
  --body "Hello from BSC!" \
  --registry file://. \
  --key $HYP_KEY
```

Monitor your message at: [Hyperlane Explorer](https://explorer.hyperlane.xyz)

## 📊 Architecture Overview

```
BSC Testnet                          Kasplex Testnet
┌─────────────────┐                  ┌─────────────────┐
│   Mailbox       │                  │   Mailbox       │
│   (sends msg)   │                  │   (receives)    │
└────────┬────────┘                  └────────▲────────┘
         │                                    │
         │  1. Message sent                   │  4. Message delivered
         │                                    │
         ▼                                    │
┌─────────────────┐                  ┌─────────────────┐
│   Validator     │ 2. Signs         │    Relayer      │
│   (watches BSC) │─────────────────▶│  (watches both) │
└─────────────────┘    attestation   └─────────────────┘
                                              │
                                              │ 3. Fetches signature
                                              │    & delivers message
                                              ▼
```

1. **User** sends message on BSC Testnet
2. **Validator** watches BSC, signs the message
3. **Relayer** picks up the message and validator signature
4. **Relayer** delivers to Kasplex Testnet
5. **ISM** on Kasplex verifies the signature
6. **Mailbox** on Kasplex processes the message

## 📁 Repository Structure

```
hyperlane-registery-personal/
├── chains/
│   ├── bsctestnet/
│   │   ├── metadata.yaml       # BSC Testnet config
│   │   └── addresses.yaml      # Deployed contracts
│   └── kasplextestnet/
│       ├── metadata.yaml       # Kasplex config ✅
│       └── addresses.yaml      # Will be created after deployment
├── configs/
│   └── kasplex-infrastructure/
│       ├── validator-bsctestnet.json
│       ├── validator-kasplextestnet.json
│       ├── relayer-config.json
│       └── ism-config.yaml
├── deploy-kasplex.sh           # Automated deployment script
├── KASPLEX_DEPLOYMENT_PLAN.md  # Detailed deployment guide
├── KASPLEX_SETUP_GUIDE.md      # Complete setup instructions
└── KASPLEX_STATUS.md           # Current status overview
```

## 🔍 Verification

After setup, verify everything is working:

### Check Contract Deployment

```bash
# Check if mailbox exists on Kasplex
cast code <MAILBOX_ADDRESS> --rpc-url https://rpc.kasplextest.xyz

# Should return bytecode, not "0x"
```

### Check Validators

- Validators should show "Validator running" in their logs
- No error messages about RPC connections
- Should see "Signed checkpoint" messages periodically

### Check Relayer

- Relayer should show "Relayer running" in logs
- Should display both chains as "ready"
- When a message is sent, should see "Delivering message" logs

### Check Message Delivery

Send a test message and check:

1. **Hyperlane Explorer**: https://explorer.hyperlane.xyz
   - Search for your message
   - Should show "Delivered" status

2. **Validator logs**: Should show signature creation
3. **Relayer logs**: Should show message delivery

## 🐛 Troubleshooting

### "Chain not found in registry"

Use the full file path: `--registry file://d:/hyperlane-registery-personal`

### "Insufficient funds for gas"

Fund your addresses:
- **Deployer**: Needs KAS on Kasplex
- **Relayer**: Needs BNB on BSC + KAS on Kasplex
- **Validator**: Minimal gas for announcement

### "Validator not signing"

- Check validator is running (no errors in logs)
- Verify validator announced on-chain
- Check RPC connection is working

### "Relayer not delivering"

- Fund relayer on both chains
- Verify mailbox addresses in relayer config
- Check validator has signed the message first
- Ensure ISM is configured to accept your validator

### "Message rejected by ISM"

- Verify ISM config has your validator address
- Check validator address matches (derive from private key)
- Ensure threshold is set to 1 for single validator

## 📚 Detailed Documentation

- **[KASPLEX_DEPLOYMENT_PLAN.md](./KASPLEX_DEPLOYMENT_PLAN.md)**: Complete deployment guide with all commands
- **[KASPLEX_SETUP_GUIDE.md](./KASPLEX_SETUP_GUIDE.md)**: Detailed architecture explanation
- **[KASPLEX_STATUS.md](./KASPLEX_STATUS.md)**: Current status and what's missing

## 🔗 Useful Links

- **Hyperlane Documentation**: https://docs.hyperlane.xyz
- **Hyperlane CLI Docs**: https://docs.hyperlane.xyz/docs/reference/cli
- **Hyperlane Explorer**: https://explorer.hyperlane.xyz
- **Hyperlane Discord**: https://discord.gg/hyperlane
- **BSC Testnet Faucet**: https://testnet.bnbchain.org/faucet-smart

## 🔐 Security Notes

1. **Never commit private keys** to Git
2. Use **environment variables** for sensitive data
3. Use **different keys** for deployer, validator, and relayer
4. For production, use **AWS KMS** or similar for key management
5. **Monitor your infrastructure** continuously
6. Keep **backups** of validator signatures

## 💡 Tips

- **Use screen or tmux** to keep validators and relayer running
- **Monitor logs** to ensure everything is working
- **Start with small test messages** before bridging tokens
- **Keep your private keys secure** - never share them
- **Join Hyperlane Discord** for community support

## 🎉 Next Steps After Bridge is Working

1. **Deploy Warp Routes**: Set up token bridges
2. **Add monitoring**: Set up alerting for validator/relayer downtime
3. **Optimize costs**: Adjust gas settings for relayer
4. **Add more validators**: Increase security with multiple validators
5. **Document your deployment**: Share your experience!

## 📝 Contributing

This is your personal fork of the Hyperlane registry. After successful deployment:

1. Document any issues you encountered
2. Update configs with working values (remove private keys!)
3. Consider contributing chain configs back to official Hyperlane registry

## 🆘 Need Help?

1. **Check logs first**: Validators and relayer logs often show the issue
2. **Review documentation**: KASPLEX_DEPLOYMENT_PLAN.md has detailed troubleshooting
3. **Hyperlane Discord**: Best place for real-time community help
4. **GitHub Issues**: For CLI bugs or problems

---

**Ready to start?** Run `bash deploy-kasplex.sh` to begin! 🚀
