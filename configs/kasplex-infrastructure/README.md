# Hyperlane Infrastructure Configuration Templates

This directory contains configuration templates for setting up Hyperlane infrastructure for the Kasplex Testnet bridge.

## Files

- `validator-bsctestnet.json` - Validator config for BSC Testnet
- `validator-kasplextestnet.json` - Validator config for Kasplex Testnet
- `relayer-config.json` - Relayer config for both chains
- `ism-config.yaml` - ISM config for message validation

## Usage

1. Copy these templates to your hyperlane-monorepo directory
2. Fill in your actual values (private keys, addresses, etc.)
3. Never commit files with real private keys!

## Security Warning

⚠️ **NEVER COMMIT PRIVATE KEYS TO GIT!**

These are templates only. When you fill in real values:
- Use environment variables for private keys
- Add `*-config.json` to `.gitignore`
- Use secure key management for production

## Setup Instructions

See `KASPLEX_DEPLOYMENT_PLAN.md` for complete setup instructions.
