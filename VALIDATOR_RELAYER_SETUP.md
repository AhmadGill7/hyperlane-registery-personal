# Validator & Relayer Setup Guide

Based on official Hyperlane documentation:
- Validators: https://docs.hyperlane.xyz/docs/operate/validators/run-validators
- Relayer: https://docs.hyperlane.xyz/docs/operate/relayer/run-relayer

## 📋 Overview

You need:
- **2 Validators**: One for BSC Testnet, one for Kasplex Testnet
- **1 Relayer**: Handles both chains (can handle 100+ chains efficiently)

## 🔑 Prerequisites

### 1. Keys Setup

You can use the **same key** for all components or separate keys:

**Option A: Use Same Key (Simpler)**
```bash
export HYP_KEY="your_private_key_here"
```

**Option B: Separate Keys (More Secure)**
- Validator Key (for signing): `VALIDATOR_KEY`
- Relayer Key (for transactions): `RELAYER_KEY`

### 2. Get Validator Address

```bash
# If using HYP_KEY
cast wallet address --private-key $HYP_KEY

# This is your validator address - you'll need it for ISM configuration
```

### 3. Fund Your Addresses

**Validator addresses need:**
- Small amount on BSC Testnet (for announcement tx) - ~0.001 BNB
- Small amount on Kasplex Testnet (for announcement tx) - ~0.1 KAS

**Relayer address needs:**
- More on BSC Testnet (for message delivery) - ~0.1 BNB
- More on Kasplex Testnet (for message delivery) - ~10 KAS

## 🐋 Docker Setup

### 1. Pull the Docker Image

```bash
docker pull --platform linux/amd64 gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0
```

## 🔐 Validator Setup

### Step 1: Configure Validators

Edit the config files with your keys:

**configs/validator-bsctestnet.json**
```json
{
  "chains": {
    "bsctestnet": {
      "customRpcUrls": "https://bsc-testnet.publicnode.com",
      "signer": {
        "type": "hexKey",
        "key": "YOUR_PRIVATE_KEY_HERE"
      }
    }
  },
  "validator": {
    "type": "hexKey",
    "key": "YOUR_VALIDATOR_KEY_HERE"  // Can be same as signer key
  },
  "checkpointSyncer": {
    "type": "localStorage",
    "path": "./hyperlane-validator-signatures-bsctestnet"
  },
  "db": "./hyperlane-db-bsctestnet",
  "originChainName": "bsctestnet"
}
```

**configs/validator-kasplextestnet.json**
```json
{
  "chains": {
    "kasplextestnet": {
      "customRpcUrls": "https://rpc.kasplextest.xyz",
      "signer": {
        "type": "hexKey",
        "key": "YOUR_PRIVATE_KEY_HERE"
      }
    }
  },
  "validator": {
    "type": "hexKey",
    "key": "YOUR_VALIDATOR_KEY_HERE"  // Can be same as above
  },
  "checkpointSyncer": {
    "type": "localStorage",
    "path": "./hyperlane-validator-signatures-kasplextestnet"
  },
  "db": "./hyperlane-db-kasplextestnet",
  "originChainName": "kasplextestnet"
}
```

### Step 2: Run Validators with Docker

**Terminal 1 - BSC Testnet Validator:**
```bash
docker run -it --rm \
  --name validator-bsc \
  -v "$(pwd)/configs/validator-bsctestnet.json:/config.json" \
  -v "$(pwd)/hyperlane-db-bsctestnet:/hyperlane-db-bsctestnet" \
  -v "$(pwd)/hyperlane-validator-signatures-bsctestnet:/hyperlane-validator-signatures-bsctestnet" \
  -p 9090:9090 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /hyperlane-db-bsctestnet \
  --originChainName bsctestnet \
  --validator.type hexKey \
  --validator.key YOUR_VALIDATOR_KEY_HERE \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key YOUR_PRIVATE_KEY_HERE \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /hyperlane-validator-signatures-bsctestnet \
  --metrics-port 9090
```

**Terminal 2 - Kasplex Testnet Validator:**
```bash
docker run -it --rm \
  --name validator-kasplex \
  -v "$(pwd)/configs/validator-kasplextestnet.json:/config.json" \
  -v "$(pwd)/hyperlane-db-kasplextestnet:/hyperlane-db-kasplextestnet" \
  -v "$(pwd)/hyperlane-validator-signatures-kasplextestnet:/hyperlane-validator-signatures-kasplextestnet" \
  -p 9091:9091 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./validator \
  --db /hyperlane-db-kasplextestnet \
  --originChainName kasplextestnet \
  --validator.type hexKey \
  --validator.key YOUR_VALIDATOR_KEY_HERE \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key YOUR_PRIVATE_KEY_HERE \
  --chains.kasplextestnet.customRpcUrls https://rpc.kasplextest.xyz \
  --checkpointSyncer.type localStorage \
  --checkpointSyncer.path /hyperlane-validator-signatures-kasplextestnet \
  --metrics-port 9091
```

### Step 3: Verify Validators are Running

Check logs for:
- ✅ "Validator running"
- ✅ "Announced validator" (automatic if funded)
- ✅ No RPC connection errors

If you see "insufficient funds" error, fund the validator address on that chain.

## 🚀 Relayer Setup

### Step 1: Configure Relayer

Edit **configs/relayer-config.json** with your key:

```json
{
  "chains": {
    "bsctestnet": {
      "customRpcUrls": "https://bsc-testnet.publicnode.com",
      "signer": {
        "type": "hexKey",
        "key": "YOUR_RELAYER_KEY_HERE"
      }
    },
    "kasplextestnet": {
      "customRpcUrls": "https://rpc.kasplextest.xyz",
      "signer": {
        "type": "hexKey",
        "key": "YOUR_RELAYER_KEY_HERE"  // Same key for both chains
      }
    }
  },
  "db": "./hyperlane-db-relayer",
  "relayChains": "bsctestnet,kasplextestnet",
  "allowLocalCheckpointSyncers": true
}
```

### Step 2: Run Relayer with Docker

**Terminal 3 - Relayer:**
```bash
docker run -it --rm \
  --name relayer \
  -v "$(pwd)/configs/relayer-config.json:/config.json" \
  -v "$(pwd)/hyperlane-db-relayer:/hyperlane-db-relayer" \
  -v "$(pwd)/hyperlane-validator-signatures-bsctestnet:/hyperlane-validator-signatures-bsctestnet:ro" \
  -v "$(pwd)/hyperlane-validator-signatures-kasplextestnet:/hyperlane-validator-signatures-kasplextestnet:ro" \
  -p 9092:9092 \
  gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0 \
  ./relayer \
  --db /hyperlane-db-relayer \
  --relayChains bsctestnet,kasplextestnet \
  --chains.bsctestnet.signer.type hexKey \
  --chains.bsctestnet.signer.key YOUR_RELAYER_KEY_HERE \
  --chains.bsctestnet.customRpcUrls https://bsc-testnet.publicnode.com \
  --chains.kasplextestnet.signer.type hexKey \
  --chains.kasplextestnet.signer.key YOUR_RELAYER_KEY_HERE \
  --chains.kasplextestnet.customRpcUrls https://rpc.kasplextest.xyz \
  --allowLocalCheckpointSyncers true \
  --metrics-port 9092
```

### Step 3: Verify Relayer is Running

Check logs for:
- ✅ "Relayer running"
- ✅ Both chains shown as "ready"
- ✅ No "insufficient funds" errors

## 🔍 Verification Checklist

- [ ] Docker image pulled
- [ ] BSC Testnet validator running (Terminal 1)
- [ ] Kasplex Testnet validator running (Terminal 2)
- [ ] Both validators announced (check logs)
- [ ] Relayer running (Terminal 3)
- [ ] Validator addresses funded on both chains
- [ ] Relayer address funded on both chains
- [ ] No errors in any logs

## 🧪 Testing the Bridge

### Step 1: Configure ISM to Accept Your Validator

First, get your validator address:
```bash
cast wallet address --private-key YOUR_VALIDATOR_KEY_HERE
```

Create ISM config (this will be in next step after validators are running).

### Step 2: Send Test Message

```bash
hyperlane send message \
  --origin bsctestnet \
  --destination kasplextestnet \
  --body "Hello from BSC!" \
  --registry https://github.com/AhmadGill7/hyperlane-registery-personal \
  --key $HYP_KEY
```

### Step 3: Monitor Delivery

Watch the logs:
1. **Validator logs**: Should show signature creation
2. **Relayer logs**: Should show "Delivering message"
3. **Check Hyperlane Explorer**: https://explorer.hyperlane.xyz

## 🐛 Troubleshooting

### "Chain not found"
- Ensure you've pushed latest addresses.yaml to GitHub
- Use `--registry https://github.com/AhmadGill7/hyperlane-registery-personal`

### "Validator not announced"
- Fund validator address with small amount (0.001 BNB or 0.1 KAS)
- Validator will auto-announce when it has funds

### "Relayer not delivering"
- Ensure relayer has funds on both chains
- Check validator has signed the message first
- Verify `--allowLocalCheckpointSyncers true` is set

### "Connection refused" or RPC errors
- Verify RPC URLs are accessible
- Try alternative RPCs if one is down

## 📁 File Structure After Setup

```
d:/hyperlane-registery-personal/
├── configs/
│   ├── validator-bsctestnet.json
│   ├── validator-kasplextestnet.json
│   └── relayer-config.json
├── hyperlane-db-bsctestnet/          (created by validator)
├── hyperlane-db-kasplextestnet/      (created by validator)
├── hyperlane-db-relayer/             (created by relayer)
├── hyperlane-validator-signatures-bsctestnet/    (signatures)
└── hyperlane-validator-signatures-kasplextestnet/ (signatures)
```

## 🔒 Security Notes

- **Never commit private keys to git**
- Use environment variables: `export HYP_KEY="..."`
- For production, use AWS KMS instead of hex keys
- Keep validator signatures backed up
- Monitor relayer balance to avoid running out of gas

## ⏭️ Next Steps After Setup

1. ✅ Validators running and announced
2. ✅ Relayer running and funded
3. 🔄 Configure ISM to accept your validator
4. 🧪 Send test messages
5. 🎯 Deploy warp routes (for token bridging)
