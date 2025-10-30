# Kasplex Testnet Bridge - Setup Checklist

Use this checklist to track your progress as you set up the bridge.

## ✅ Phase 1: Preparation

- [ ] Node.js and npm installed
- [ ] Git installed
- [ ] Repository cloned: `git clone https://github.com/AhmadGill7/hyperlane-registery-personal.git`
- [ ] BSC Testnet tokens acquired (BNB)
- [ ] Kasplex Testnet tokens acquired (KAS)
- [ ] Private keys ready (deployer, validator, relayer)
- [ ] Hyperlane CLI installed: `npm install -g @hyperlane-xyz/cli`

## ✅ Phase 2: Core Contract Deployment

- [ ] Set HYP_KEY environment variable
- [ ] Verified Kasplex RPC is accessible
- [ ] Ran deployment script: `bash deploy-kasplex.sh`
- [ ] Deployment completed successfully
- [ ] `chains/kasplextestnet/addresses.yaml` created
- [ ] All contract addresses verified on block explorer
- [ ] Mailbox address saved: `______________________________________`
- [ ] ProxyAdmin address saved: `______________________________________`
- [ ] ValidatorAnnounce address saved: `______________________________________`

## ✅ Phase 3: Validator Setup

### BSC Testnet Validator

- [ ] Hyperlane monorepo cloned
- [ ] Dependencies installed: `yarn install`
- [ ] Project built: `yarn build`
- [ ] Validator private key generated/secured
- [ ] Validator address derived: `______________________________________`
- [ ] `validator-bsctestnet.json` configured
- [ ] Validator running (no errors in logs)
- [ ] Validator announced on BSC Testnet
- [ ] Announcement transaction confirmed: `______________________________________`

### Kasplex Testnet Validator

- [ ] `validator-kasplextestnet.json` configured
- [ ] Validator running (no errors in logs)
- [ ] Validator announced on Kasplex Testnet
- [ ] Announcement transaction confirmed: `______________________________________`

### Validator Health Checks

- [ ] BSC validator logs show "Signed checkpoint" messages
- [ ] Kasplex validator logs show "Signed checkpoint" messages
- [ ] No RPC connection errors
- [ ] Validator signatures being stored locally

## ✅ Phase 4: Relayer Setup

- [ ] Relayer private key generated/secured
- [ ] Relayer address derived: `______________________________________`
- [ ] Relayer funded with BNB on BSC Testnet
- [ ] Relayer funded with KAS on Kasplex Testnet
- [ ] `relayer-config.json` configured with correct mailbox addresses
- [ ] Relayer environment variables set
- [ ] Relayer running (no errors in logs)
- [ ] Relayer shows both chains as "ready"
- [ ] Relayer metrics accessible (if enabled)

## ✅ Phase 5: ISM Configuration

- [ ] Validator address added to `ism-config.yaml`
- [ ] ISM deployed to BSC Testnet
- [ ] ISM deployed to Kasplex Testnet
- [ ] ISM addresses saved:
  - BSC Testnet ISM: `______________________________________`
  - Kasplex Testnet ISM: `______________________________________`
- [ ] ISM configured to accept validator signatures
- [ ] Threshold set correctly (1 for single validator)

## ✅ Phase 6: Testing

### Test Message 1: BSC → Kasplex

- [ ] Test message sent from BSC to Kasplex
- [ ] Message transaction hash: `______________________________________`
- [ ] Validator signed the message (check validator logs)
- [ ] Relayer picked up the message (check relayer logs)
- [ ] Message delivered to Kasplex (check relayer logs)
- [ ] Message visible on Hyperlane Explorer
- [ ] Message status: "Delivered"

### Test Message 2: Kasplex → BSC

- [ ] Test message sent from Kasplex to BSC
- [ ] Message transaction hash: `______________________________________`
- [ ] Validator signed the message
- [ ] Relayer delivered the message
- [ ] Message visible on Hyperlane Explorer
- [ ] Message status: "Delivered"

### Performance Checks

- [ ] Message delivery time: __________ seconds
- [ ] No failed transactions
- [ ] Gas costs reasonable
- [ ] No errors in validator logs
- [ ] No errors in relayer logs

## ✅ Phase 7: Warp Route Deployment (Optional)

- [ ] Warp route config created
- [ ] Token contracts selected
- [ ] Warp route deployed
- [ ] Token bridge tested (send tokens)
- [ ] Tokens received on destination
- [ ] Warp route config added to repository

## ✅ Phase 8: Finalization

- [ ] All infrastructure running smoothly
- [ ] Logs monitored for 24 hours with no issues
- [ ] Documentation updated with actual values
- [ ] Private keys backed up securely
- [ ] Validator signature backups created
- [ ] Repository committed and pushed to GitHub
- [ ] Logo added: `chains/kasplextestnet/logo.svg`
- [ ] README updated with deployment notes

## 📊 Infrastructure Status

### Current Running Services

| Service | Status | PID/Process | Location |
|---------|--------|-------------|----------|
| BSC Validator | ⏳ | __________ | __________ |
| Kasplex Validator | ⏳ | __________ | __________ |
| Relayer | ⏳ | __________ | __________ |

### Key Addresses

| Component | Address |
|-----------|---------|
| Deployer | __________________________________________ |
| Validator | __________________________________________ |
| Relayer | __________________________________________ |

### Deployed Contracts (Kasplex Testnet)

| Contract | Address |
|----------|---------|
| Mailbox | __________________________________________ |
| ProxyAdmin | __________________________________________ |
| ValidatorAnnounce | __________________________________________ |
| InterchainGasPaymaster | __________________________________________ |
| ISM | __________________________________________ |

## 🔍 Daily Health Checks

Use this section to track daily status:

### Day 1: ____/____/____

- [ ] Validators running
- [ ] Relayer running
- [ ] No error messages
- [ ] Test message sent and delivered
- [ ] Notes: _______________________________________________

### Day 2: ____/____/____

- [ ] Validators running
- [ ] Relayer running
- [ ] No error messages
- [ ] Test message sent and delivered
- [ ] Notes: _______________________________________________

### Day 3: ____/____/____

- [ ] Validators running
- [ ] Relayer running
- [ ] No error messages
- [ ] Test message sent and delivered
- [ ] Notes: _______________________________________________

## 🐛 Issues Encountered

Document any issues you encounter:

### Issue 1:
- **Description**: _____________________________________________
- **When**: _____________________________________________
- **Solution**: _____________________________________________
- **Status**: ⏳ Open / ✅ Resolved

### Issue 2:
- **Description**: _____________________________________________
- **When**: _____________________________________________
- **Solution**: _____________________________________________
- **Status**: ⏳ Open / ✅ Resolved

### Issue 3:
- **Description**: _____________________________________________
- **When**: _____________________________________________
- **Solution**: _____________________________________________
- **Status**: ⏳ Open / ✅ Resolved

## 📝 Notes & Observations

Add any notes about your deployment experience:

_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

## 🎉 Completion

- [ ] All phases completed
- [ ] Bridge fully operational
- [ ] Documentation complete
- [ ] Shared experience with Hyperlane community

**Completion Date**: ____/____/____

**Total Time Spent**: ________ hours

**Lessons Learned**:
_______________________________________________________________
_______________________________________________________________
_______________________________________________________________

---

**Congratulations on setting up your Hyperlane bridge!** 🎊
