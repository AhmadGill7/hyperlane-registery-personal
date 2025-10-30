# 🚀 Quick Start Guide - Run Validators & Relayer

## ✅ Setup Complete!

All necessary files and scripts have been created. You're ready to start your validators and relayer.

## 📋 What You Have

- ✅ Docker image pulled: `gcr.io/abacus-labs-dev/hyperlane-agent:agents-v1.4.0`
- ✅ Directories created for databases and signatures
- ✅ Run scripts created and configured
- ✅ Your address: `0x4f0b4c4c23E31f3e5bCCEfFb649AfdE964B7dF50`

## 💰 Check Your Balances

Before starting, ensure you have funds:

```bash
# Check your balances
ADDR=$(cast wallet address --private-key $HYP_KEY)
echo "BSC Testnet:" && cast balance $ADDR --rpc-url https://bsc-testnet.publicnode.com
echo "Kasplex Testnet:" && cast balance $ADDR --rpc-url https://rpc.kasplextest.xyz
```

**Minimum required:**
- BSC Testnet: ~0.01 BNB (for validator announcement + relayer gas)
- Kasplex Testnet: ~1 KAS (for validator announcement + relayer gas)

## 🎯 How to Start

You need to run **3 separate terminals** simultaneously:

### Terminal 1: BSC Testnet Validator

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-validator-bsc.sh
```

**What to look for:**
- ✅ "Validator running"
- ✅ "Announced validator" (if you have funds)
- ✅ Connecting to BSC Testnet RPC
- ✅ "Signed checkpoint" messages (when messages are sent)

### Terminal 2: Kasplex Testnet Validator

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-validator-kasplex.sh
```

**What to look for:**
- ✅ "Validator running"
- ✅ "Announced validator" (if you have funds)
- ✅ Connecting to Kasplex Testnet RPC
- ✅ "Signed checkpoint" messages (when messages are sent)

### Terminal 3: Relayer

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-relayer.sh
```

**What to look for:**
- ✅ "Relayer running"
- ✅ Both chains showing as "ready"
- ✅ "Delivering message" (when messages are sent)
- ✅ No "insufficient funds" errors

## 🔍 Verification Steps

### 1. Validators Are Running
- Check Terminal 1 and 2 for "Validator running" message
- No RPC connection errors
- If you see "insufficient funds", fund that chain's address

### 2. Validators Announced Themselves
- Look for "Announced validator" in the logs
- If not announced, add small amount of funds and restart

### 3. Relayer Is Running
- Check Terminal 3 for "Relayer running"
- Both chains should show as connected
- Check relayer has funds on both chains

### 4. Check Signature Files
```bash
# After validators run for a bit, check for signature files
ls -la hyperlane-validator-signatures-bsctestnet/
ls -la hyperlane-validator-signatures-kasplextestnet/
```

## 🧪 Testing the Bridge

Once all 3 components are running:

### Step 1: Send a Test Message

```bash
# In a new terminal (Terminal 4)
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"

hyperlane send message \
  --origin bsctestnet \
  --destination kasplextestnet \
  --body "Hello from BSC!" \
  --registry https://github.com/AhmadGill7/hyperlane-registery-personal \
  --key $HYP_KEY
```

### Step 2: Watch the Logs

**In Validator logs (Terminal 1):**
- Should see "Signed checkpoint" for the message

**In Relayer logs (Terminal 3):**
- Should see "Dispatched message"
- Should see "Delivering message"
- Should see "Successfully delivered message"

### Step 3: Verify Delivery

Check Hyperlane Explorer:
```
https://explorer.hyperlane.xyz
```

Search for your message or transaction hash.

## ⚠️ Common Issues

### "Chain not found in registry"
**Solution:** The validators/relayer need the GitHub registry to know about kasplextestnet.

For BSC validator: BSC is in official registry, so it should work
For Kasplex validator: May need to add `--registry` flag (but shouldn't be needed)

If you get this error, we'll need to modify the run scripts.

### "Validator not announced"
**Solution:** Fund the validator address on that chain (0.001 BNB or 0.1 KAS)

### "Relayer insufficient funds"
**Solution:** Fund the relayer address on both chains (0.1 BNB + 10 KAS recommended)

### "Cannot connect to RPC"
**Solution:** 
- Check internet connection
- Try alternative RPC: `https://data-seed-prebsc-1-s1.binance.org:8545` for BSC

### "No messages being relayed"
**Solution:**
1. Check validator has signed the message (Terminal 1)
2. Check validator signatures are being written to disk
3. Ensure relayer has `--allowLocalCheckpointSyncers true`
4. Check relayer has funds on destination chain

## 📊 Monitoring

### Check Metrics (Optional)
- BSC Validator: http://localhost:9090/metrics
- Kasplex Validator: http://localhost:9091/metrics  
- Relayer: http://localhost:9092/metrics

### View Logs
All output is in the terminal windows. You can redirect to files:

```bash
./run-validator-bsc.sh 2>&1 | tee validator-bsc.log
./run-validator-kasplex.sh 2>&1 | tee validator-kasplex.log
./run-relayer.sh 2>&1 | tee relayer.log
```

## 🛑 Stopping Services

Press `Ctrl+C` in each terminal to stop the services gracefully.

The databases and signatures are persisted in:
- `hyperlane-db-bsctestnet/`
- `hyperlane-db-kasplextestnet/`
- `hyperlane-db-relayer/`
- `hyperlane-validator-signatures-bsctestnet/`
- `hyperlane-validator-signatures-kasplextestnet/`

## 📁 File Structure

```
d:/hyperlane-registery-personal/
├── run-validator-bsc.sh          # Start BSC validator
├── run-validator-kasplex.sh      # Start Kasplex validator
├── run-relayer.sh                # Start relayer
├── hyperlane-db-bsctestnet/      # BSC validator database
├── hyperlane-db-kasplextestnet/  # Kasplex validator database
├── hyperlane-db-relayer/         # Relayer database
├── hyperlane-validator-signatures-bsctestnet/    # BSC validator signatures
└── hyperlane-validator-signatures-kasplextestnet/ # Kasplex validator signatures
```

## 🎉 Success Indicators

You'll know everything is working when:
1. ✅ All 3 terminals show "running" messages
2. ✅ Validators show "Announced validator"
3. ✅ You can send a test message
4. ✅ Validator Terminal 1 shows "Signed checkpoint"
5. ✅ Relayer Terminal 3 shows "Delivering message"
6. ✅ Message appears as "Delivered" in Hyperlane Explorer

## ⏭️ Next Steps After Testing

1. **Configure ISM** - Set up proper security with your validator addresses
2. **Deploy Warp Routes** - Enable token bridging
3. **Production Setup** - Use AWS KMS for keys, S3 for signatures
4. **Monitoring** - Set up alerts for low balances, failures

## 📚 Documentation References

- [Run Validators](https://docs.hyperlane.xyz/docs/operate/validators/run-validators)
- [Run Relayer](https://docs.hyperlane.xyz/docs/operate/relayer/run-relayer)
- [Hyperlane Explorer](https://explorer.hyperlane.xyz)

---

**Ready to start? Open 3 terminals and let's go! 🚀**
