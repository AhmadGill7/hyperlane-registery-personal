# Manual Deployment Guide for Kasplex Testnet

The automated script may have issues on Windows with Git Bash. Here's how to deploy manually.

## Prerequisites Check

1. **Hyperlane CLI installed**: ✅ You have v19.3.0
2. **Registry built**: Run `npm run build` (you just did this ✅)
3. **Private key ready**: Set `HYP_KEY` environment variable
4. **Funds on Kasplex**: You need KAS tokens for gas

## Step-by-Step Deployment

### Step 1: Set Your Private Key

```bash
# In Git Bash or PowerShell
export HYP_KEY="your_private_key_here"

# Or in Windows CMD
set HYP_KEY=your_private_key_here
```

**Important**: Never commit this key! It's just for this terminal session.

### Step 2: Verify Registry is Built

```bash
cd /d/hyperlane-registery-personal

# Check if dist folder exists
ls dist/chains/kasplextestnet/

# Should show: metadata.yaml, addresses.yaml.template, logo.svg
```

### Step 3: Deploy Core Contracts

Now deploy using the Hyperlane CLI:

```bash
cd /d/hyperlane-registery-personal

hyperlane core deploy \
  --chain kasplextestnet \
  --registry /d/hyperlane-registery-personal \
  --key $HYP_KEY \
  --yes
```

**What this does**:
- Reads chain config from `dist/chains/kasplextestnet/metadata.yaml`
- Deploys all Hyperlane core contracts to Kasplex Testnet
- Uses your private key for deployment
- Automatically confirms deployment (--yes flag)

### Step 4: Save the Deployment Output

The CLI will output something like:

```
✅ Hyperlane core contracts deployed

Deployment summary:
  mailbox: 0x1234567890abcdef...
  proxyAdmin: 0x234567890abcdef1...
  validatorAnnounce: 0x34567890abcdef12...
  ...
```

**Copy all these addresses!** You'll need them for the next steps.

### Step 5: Create addresses.yaml

Create the file: `chains/kasplextestnet/addresses.yaml`

Copy the addresses from the deployment output:

```yaml
mailbox: "0x..."
proxyAdmin: "0x..."
validatorAnnounce: "0x..."
interchainGasPaymaster: "0x..."
# ... paste all addresses here
```

### Step 6: Rebuild Registry

After creating addresses.yaml, rebuild:

```bash
npm run build
```

This makes the new addresses available to the CLI for future commands.

## Troubleshooting

### Error: "No chain metadata set for kasplextestnet"

**Solution**: Make sure you built the registry first:
```bash
npm run build
```

### Error: "ENOENT: no such file or directory, copyfile...logo.svg"

**Solution**: The logo file is missing. It should already be created, but if not:
```bash
# A simple placeholder was created for you already
ls chains/kasplextestnet/logo.svg
```

### Error: "Insufficient funds for gas"

**Solution**: Get Kasplex testnet tokens. Your deployer address is:
```bash
# Get your address from your private key
cast wallet address --private-key $HYP_KEY
```

Then get KAS tokens from Kasplex faucet.

### Error: "Cannot connect to RPC"

**Solution**: Verify RPC is working:
```bash
curl -X POST https://rpc.kasplextest.xyz \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'
```

Should return: `{"jsonrpc":"2.0","id":1,"result":"0x28c64"}`

## Alternative: Using PowerShell

If Git Bash has issues, use PowerShell:

```powershell
# Set working directory
cd D:\hyperlane-registery-personal

# Set private key
$env:HYP_KEY = "your_private_key_here"

# Deploy
hyperlane core deploy `
  --chain kasplextestnet `
  --registry D:\hyperlane-registery-personal `
  --key $env:HYP_KEY `
  --yes
```

## Alternative: Interactive Mode

If automated deployment has issues, use interactive mode:

```bash
cd /d/hyperlane-registery-personal

# Without --yes flag, CLI will ask for confirmation
hyperlane core deploy \
  --chain kasplextestnet \
  --registry /d/hyperlane-registery-personal
```

The CLI will:
1. Ask for your private key
2. Show deployment plan
3. Ask for confirmation
4. Deploy contracts

## After Deployment

Once deployment succeeds:

1. ✅ Copy all contract addresses
2. ✅ Create `chains/kasplextestnet/addresses.yaml` with those addresses
3. ✅ Run `npm run build` again
4. ✅ Commit the addresses.yaml to your repo (but NOT the private key!)

Then proceed to:
- Set up validators (see KASPLEX_QUICKSTART.md Step 2)
- Set up relayer (see KASPLEX_QUICKSTART.md Step 4)
- Configure ISM (see KASPLEX_QUICKSTART.md Step 5)

## Quick Command Reference

```bash
# 1. Build registry
cd /d/hyperlane-registery-personal
npm run build

# 2. Set private key
export HYP_KEY="your_key"

# 3. Deploy
hyperlane core deploy \
  --chain kasplextestnet \
  --registry /d/hyperlane-registery-personal \
  --key $HYP_KEY \
  --yes

# 4. Create addresses.yaml (manually copy addresses)

# 5. Rebuild
npm run build
```

## Need Help?

- Check the terminal output for specific errors
- Verify you have gas on Kasplex Testnet
- Make sure registry is built (`ls dist/chains/kasplextestnet`)
- Try interactive mode without --yes flag
- Join Hyperlane Discord for community help
