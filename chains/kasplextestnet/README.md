# Kasplex Testnet - Hyperlane Setup

## Status: 🔧 In Progress

This chain configuration is currently being set up for Hyperlane interoperability.

## What's Completed

- ✅ Chain folder structure created
- ✅ Template `metadata.yaml` created
- ✅ Template `addresses.yaml` created

## What's Needed

1. **Update metadata.yaml** with actual Kasplex Testnet values:
   - Real chain ID
   - Real RPC URLs
   - Real block explorer URL
   - Actual native token details
   - Actual block timings

2. **Add logo.svg** file

3. **Deploy Hyperlane Core Contracts** using:
   ```bash
   hyperlane deploy core --registry . --chain kasplextestnet
   ```

4. **Update addresses.yaml** with deployed contract addresses

5. **Set up and run a Validator** for this chain

6. **Set up and run a Relayer** for this chain

## Documentation

See the root-level documentation files:
- `KASPLEX_SETUP_GUIDE.md` - Complete setup instructions
- `KASPLEX_STATUS.md` - Current status and action plan

## Contact

If you're setting this up, make sure you have:
- Access to Kasplex Testnet RPC
- Testnet tokens for gas
- Private key with funds for contract deployment
- Server/VM for running validator and relayer (optional but recommended)
