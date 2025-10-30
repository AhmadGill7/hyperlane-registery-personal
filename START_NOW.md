# 🎯 START HERE - Run Your Bridge Now!

## ✅ Everything is Ready

All setup is complete! Here's what to do:

## 💰 Step 1: Check Your Funds (IMPORTANT!)

Run this command:

```bash
cd /d/hyperlane-registery-personal
ADDR=$(cast wallet address --private-key $HYP_KEY)
echo "Your Address: $ADDR"
echo ""
echo "BSC Testnet Balance:"
cast balance $ADDR --rpc-url https://bsc-testnet.publicnode.com
echo ""
echo "Kasplex Testnet Balance:"
cast balance $ADDR --rpc-url https://rpc.kasplextest.xyz
```

**You need:**

- BSC Testnet: At least 0.01 BNB
- Kasplex Testnet: At least 1 KAS

If you don't have enough, get testnet tokens first!

## 🚀 Step 2: Open 3 Terminals and Run

### Terminal 1 - BSC Validator

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-validator-bsc.sh
```

### Terminal 2 - Kasplex Validator

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-validator-kasplex.sh
```

### Terminal 3 - Relayer

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"
./run-relayer.sh
```

## ✅ Step 3: Verify They're Running

**Look for these messages:**

✅ Terminal 1: "Validator running" + "Announced validator"
✅ Terminal 2: "Validator running" + "Announced validator"  
✅ Terminal 3: "Relayer running" + both chains "ready"

## 🧪 Step 4: Send Test Message

In a **4th terminal**:

```bash
cd /d/hyperlane-registery-personal
export HYP_KEY="your_private_key_here"

hyperlane send message \
  --origin bsctestnet \
  --destination kasplextestnet \
  --body "Hello Kasplex!" \
  --registry https://github.com/AhmadGill7/hyperlane-registery-personal \
  --key $HYP_KEY
```

## 🎉 Step 5: Watch the Magic

**Terminal 1 (BSC Validator):** Should sign the message
**Terminal 3 (Relayer):** Should deliver the message to Kasplex

Check https://explorer.hyperlane.xyz to see your message!

---

## 📚 Need Help?

See `QUICKSTART_VALIDATORS_RELAYER.md` for detailed troubleshooting.

## 🐛 Quick Troubleshooting

**"Validator not announced"** → Add funds to your address on that chain
**"Chain not found"** → We may need to add registry flag (will help you)
**"Relayer not delivering"** → Check relayer has funds on both chains

---

**Ready? Let's start! Open those 3 terminals! 🚀**
