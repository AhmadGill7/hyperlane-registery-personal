# Warp Route Configuration - USDT Bridge

## Summary

The relayer has been configured to process **warp route token transfers** (like your USDT bridge).

## Changes Made

### run-relayer.sh

Added two critical parameters:

```bash
--gasPaymentEnforcement '[{"type": "none"}]'
--whitelist '[{"destinationDomain": ["167012", "97"], "senderAddress": "*", "recipientAddress": "*"}]'
```

### What These Do

1. **`--gasPaymentEnforcement '[{"type": "none"}]'`**
   - Disables requirement for interchain gas payments
   - Warp routes handle gas internally, so this allows the relayer to process them
   - Without this, relayer would skip warp messages waiting for gas payment

2. **`--whitelist '[{"destinationDomain": ["167012", "97"], "senderAddress": "*", "recipientAddress": "*"}]'`**
   - Explicitly tells relayer to process messages to domain 167012 (Kasplex) and domain 97 (BSC)
   - Accepts any sender address (including warp route contracts)
   - Accepts any recipient address (including warp route contracts)
   - Without this, relayer might filter out certain messages

## Your USDT Warp Route

### BSC Testnet (Collateral Side)
- **Warp Contract:** `0x33040822048AF695dFC056023443732AD39Feb97`
- **Collateral Token:** `0xb97aDD318e75F98972f95323ce0A035E31784c4E` (USDT)
- **Type:** HypERC20Collateral (locks your USDT)

### Kasplex Testnet (Synthetic Side)
- **Warp Contract:** `0x2DfA8C344Ed0070008651A4bE513D7f035c3d9ED`
- **Type:** HypERC20 (mints synthetic USDT)

## How Warp Route Messages Work

1. **User calls BSC warp contract** → `transferRemote(167012, recipient, amount)`
2. **Warp contract locks USDT** → Transfers from user to collateral contract
3. **Warp contract dispatches message** → Through BSC mailbox to Kasplex
4. **Relayer detects message** → Sees dispatch event on BSC
5. **Relayer submits to Kasplex** → Calls `mailbox.process()` with validator signature
6. **Kasplex mailbox delivers** → Calls Kasplex warp contract
7. **Kasplex warp mints USDT** → User receives synthetic USDT on Kasplex

## Your Previous Transaction

**Transaction Hash:** `0xf1fb003fc8e901d703f00767dfbdbe8b59ea653652927ef7d4efaa0df96ebf40`

**Status:** ✅ Successfully sent on BSC (sequence 12603)

**What Happened:**
1. ✅ USDT transferred from your wallet to warp contract
2. ✅ Message dispatched through BSC mailbox
3. ✅ Validator signed the checkpoint
4. ✅ Relayer detected the message
5. ❌ Relayer did NOT deliver (because it wasn't configured for warp routes)

**After Restart:**
- Relayer will reprocess messages and deliver your USDT to Kasplex
- You should see 100 USDT appear in your Kasplex wallet

## Testing After Restart

### 1. Check if Previous Message Gets Delivered

Wait 2-3 minutes after relayer restarts, then run:

```bash
./check-bridge-status.sh
```

Look for Kasplex "Delivered count" to increase from `0x0` to `0x1`.

### 2. Check Your Kasplex USDT Balance

```bash
cast call 0x2DfA8C344Ed0070008651A4bE513D7f035c3d9ED "balanceOf(address)(uint256)" YOUR_ADDRESS --rpc-url https://rpc.kasplextest.xyz
```

Replace `YOUR_ADDRESS` with `0x1900c5B15268F13BB4e462f54F5EDD6834C47348` (your address from the transaction).

### 3. Send Another Test Transfer

If the first one works, try sending another:

```bash
# Approve USDT spending
cast send 0xb97aDD318e75F98972f95323ce0A035E31784c4E \
  "approve(address,uint256)" \
  0x33040822048AF695dFC056023443732AD39Feb97 \
  1000000000000000000 \
  --rpc-url https://bsc-testnet.publicnode.com \
  --private-key $HYP_KEY \
  --legacy

# Transfer 1 USDT to Kasplex
cast send 0x33040822048AF695dFC056023443732AD39Feb97 \
  "transferRemote(uint32,bytes32,uint256)" \
  167012 \
  "0x0000000000000000000000001900c5B15268F13BB4e462f54F5EDD6834C47348" \
  1000000000000000000 \
  --value 1 \
  --rpc-url https://bsc-testnet.publicnode.com \
  --private-key $HYP_KEY \
  --legacy
```

## How to Restart Relayer

In Terminal 3:

```bash
./run-relayer.sh
```

The relayer will:
- Sync from block 70650000 on BSC (~2 minutes)
- Detect your previous message (sequence 12603)
- Submit it to Kasplex
- Continue relaying new messages

## Monitoring

### Watch Relayer Logs

```bash
docker logs -f relayer
```

Look for:
- `Found log(s) in index range... sequence: Some(12603)` - Message detected
- `Submitting message` or `Message processed` - Delivery in progress

### Check Delivery Status

```bash
cast call 0xC505a8B225D46eB5252D96549C074e70855Fe4F3 \
  "delivered(bytes32)(bool)" \
  0x661da73836640c0aaf1074ea88ee877295b5ee249741089390153ff36625ae84 \
  --rpc-url https://rpc.kasplextest.xyz
```

Should return `true` after delivery.

## Troubleshooting

### If Message Still Doesn't Deliver

1. **Check relayer has enough gas on Kasplex:**
   ```bash
   cast balance 0x4f0b4c4c23E31f3e5bCCEfFb649AfdE964B7dF50 --rpc-url https://rpc.kasplextest.xyz
   ```

2. **Check validator signature exists:**
   ```bash
   ls -la hyperlane-validator-signatures-bsctestnet/12603*
   ```

3. **Check relayer errors:**
   ```bash
   docker logs relayer 2>&1 | grep -i "error\|fail"
   ```

### If Balance Still Zero on Kasplex

The warp route contract might need initialization or the synthetic token might not be minting correctly. Check:

```bash
# Check total supply of synthetic USDT on Kasplex
cast call 0x2DfA8C344Ed0070008651A4bE513D7f035c3d9ED "totalSupply()(uint256)" --rpc-url https://rpc.kasplextest.xyz
```

## Next Steps

1. ✅ Restart relayer: `./run-relayer.sh`
2. ⏳ Wait 2-3 minutes for sync
3. 🔍 Check delivery status
4. 💰 Verify USDT balance on Kasplex
5. 🎉 Send more test transfers!
