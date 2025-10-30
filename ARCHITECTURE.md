# Hyperlane Bridge Architecture Diagram

## High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        Your Hyperlane Bridge                            │
│                    BSC Testnet ↔ Kasplex Testnet                       │
└─────────────────────────────────────────────────────────────────────────┘

┌──────────────────────┐                           ┌──────────────────────┐
│   BSC Testnet        │                           │  Kasplex Testnet     │
│   (Chain ID: 97)     │                           │  (Chain ID: 167012)  │
│                      │                           │                      │
│  ┌────────────────┐  │                           │  ┌────────────────┐  │
│  │   Mailbox      │  │◄─────── Messages ────────►│  │   Mailbox      │  │
│  │  0xF9F6F564... │  │                           │  │  (deployed)    │  │
│  └────────────────┘  │                           │  └────────────────┘  │
│                      │                           │                      │
│  ┌────────────────┐  │                           │  ┌────────────────┐  │
│  │ ValidatorAnnounce│                           │  │ ValidatorAnnounce│ │
│  │  0xf09701B0... │  │                           │  │  (deployed)    │  │
│  └────────────────┘  │                           │  └────────────────┘  │
│                      │                           │                      │
│  ┌────────────────┐  │                           │  ┌────────────────┐  │
│  │      ISM       │  │                           │  │      ISM       │  │
│  │  (validates    │  │                           │  │  (validates    │  │
│  │   incoming)    │  │                           │  │   incoming)    │  │
│  └────────────────┘  │                           │  └────────────────┘  │
└──────────────────────┘                           └──────────────────────┘
           ▲                                                   ▲
           │                                                   │
           │                                                   │
           │                                                   │
           ▼                                                   ▼
┌──────────────────────┐                           ┌──────────────────────┐
│  BSC Validator       │                           │ Kasplex Validator    │
│                      │                           │                      │
│  Watches: BSC        │                           │  Watches: Kasplex    │
│  Signs: Messages     │                           │  Signs: Messages     │
│  Output: Signatures  │                           │  Output: Signatures  │
└──────────────────────┘                           └──────────────────────┘
           │                                                   │
           │                  ┌──────────────────────┐        │
           └─────────────────►│      Relayer         │◄───────┘
                              │                      │
                              │  Watches: Both chains│
                              │  Fetches: Signatures │
                              │  Delivers: Messages  │
                              │  Needs: Gas on both  │
                              └──────────────────────┘
```

## Message Flow: BSC → Kasplex

```
Step 1: User sends message on BSC Testnet
┌─────────────────────────────────────────┐
│ User calls: mailbox.dispatch()          │
│ Chain: BSC Testnet                      │
│ Gas: Paid by user                       │
└─────────────────────────────────────────┘
                  │
                  ▼
Step 2: BSC Validator detects and signs
┌─────────────────────────────────────────┐
│ Validator watches BSC mailbox           │
│ Sees new message                        │
│ Creates merkle proof                    │
│ Signs with validator key                │
│ Stores signature locally                │
└─────────────────────────────────────────┘
                  │
                  ▼
Step 3: Relayer picks up message
┌─────────────────────────────────────────┐
│ Relayer watches BSC mailbox             │
│ Detects new message                     │
│ Fetches validator signature             │
│ Prepares delivery transaction           │
└─────────────────────────────────────────┘
                  │
                  ▼
Step 4: Relayer delivers to Kasplex
┌─────────────────────────────────────────┐
│ Relayer calls: mailbox.process()        │
│ Chain: Kasplex Testnet                  │
│ Includes: Message + Signature           │
│ Gas: Paid by relayer                    │
└─────────────────────────────────────────┘
                  │
                  ▼
Step 5: ISM validates on Kasplex
┌─────────────────────────────────────────┐
│ ISM checks validator signature          │
│ Verifies validator is in allowed list   │
│ Checks threshold is met (1/1)           │
│ Approves message                        │
└─────────────────────────────────────────┘
                  │
                  ▼
Step 6: Message delivered!
┌─────────────────────────────────────────┐
│ Mailbox processes message               │
│ Calls recipient contract (if any)       │
│ Emits ProcessedMessage event            │
│ ✅ Message delivered successfully       │
└─────────────────────────────────────────┘
```

## Component Responsibilities

```
┌─────────────────────────────────────────────────────────────────┐
│                          Deployer                               │
│  Role: One-time deployment of contracts                        │
│  Needs: Gas on Kasplex for deployment                          │
│  After: Can be shut down (not needed continuously)             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                         Validator                               │
│  Role: Attest to messages on source chain                      │
│  Runs: Continuously (24/7)                                     │
│  Watches: One chain (need 1 per chain)                         │
│  Signs: Message metadata                                       │
│  Costs: Minimal (just announcement)                            │
│  Location: Your server or cloud VM                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                          Relayer                                │
│  Role: Deliver messages between chains                         │
│  Runs: Continuously (24/7)                                     │
│  Watches: All configured chains                                │
│  Delivers: Messages + validator signatures                     │
│  Costs: Ongoing gas on BOTH chains                             │
│  Location: Your server or cloud VM                             │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                            ISM                                  │
│  Role: Validate incoming messages                              │
│  Type: Smart contract on each chain                            │
│  Config: List of accepted validators + threshold               │
│  Checks: Signature validity and threshold                      │
│  Deployed: Once during setup                                   │
└─────────────────────────────────────────────────────────────────┘
```

## Your Setup Plan

```
Phase 1: Deploy Contracts
┌──────────────────────────────────────┐
│ Run: deploy-kasplex.sh               │
│ Deploys: All core contracts         │
│ Creates: addresses.yaml              │
│ Time: ~10 minutes                    │
│ Cost: ~0.1-0.5 KAS                   │
└──────────────────────────────────────┘
                │
                ▼
Phase 2: Set Up Validators
┌──────────────────────────────────────┐
│ 1. Clone hyperlane-monorepo          │
│ 2. Configure validators              │
│ 3. Run validator for BSC             │
│ 4. Run validator for Kasplex         │
│ 5. Announce both validators          │
│ Time: ~20 minutes                    │
└──────────────────────────────────────┘
                │
                ▼
Phase 3: Set Up Relayer
┌──────────────────────────────────────┐
│ 1. Configure relayer                 │
│ 2. Fund relayer on both chains       │
│ 3. Run relayer                       │
│ Time: ~15 minutes                    │
└──────────────────────────────────────┘
                │
                ▼
Phase 4: Configure ISM
┌──────────────────────────────────────┐
│ 1. Create ISM config                 │
│ 2. Add validator addresses           │
│ 3. Deploy ISM to both chains         │
│ Time: ~5 minutes                     │
└──────────────────────────────────────┘
                │
                ▼
Phase 5: Test!
┌──────────────────────────────────────┐
│ 1. Send test message BSC→Kasplex     │
│ 2. Monitor on Explorer               │
│ 3. Send test message Kasplex→BSC     │
│ 4. Verify both directions work       │
│ Time: ~5 minutes                     │
└──────────────────────────────────────┘
                │
                ▼
           ✅ DONE!
```

## File Locations

```
Your Repository Structure:
d:/hyperlane-registery-personal/
│
├── chains/
│   ├── bsctestnet/
│   │   ├── metadata.yaml ✅ (complete)
│   │   └── addresses.yaml ✅ (deployed)
│   │
│   └── kasplextestnet/
│       ├── metadata.yaml ✅ (complete)
│       └── addresses.yaml ⏳ (create after deploy)
│
├── configs/
│   └── kasplex-infrastructure/
│       ├── validator-bsctestnet.json
│       ├── validator-kasplextestnet.json
│       ├── relayer-config.json
│       └── ism-config.yaml
│
├── deploy-kasplex.sh ← Run this to deploy!
├── START_HERE.md ← You are here
├── KASPLEX_QUICKSTART.md ← Read this next
├── KASPLEX_DEPLOYMENT_PLAN.md
└── KASPLEX_CHECKLIST.md

Hyperlane Monorepo (separate location):
~/hyperlane-monorepo/
│
├── validator-bsctestnet.json (copy from your repo)
├── validator-kasplextestnet.json (copy from your repo)
├── relayer-config.json (copy from your repo)
│
└── Run validators and relayer from here
```

## Network Diagram

```
                    Internet
                       │
        ┌──────────────┼──────────────┐
        │              │              │
        ▼              ▼              ▼
   BSC Testnet   Kasplex Testnet  Your Server
   RPC Endpoint  RPC Endpoint     (or local machine)
        │              │              │
        │              │              │
        └──────────────┴──────────────┘
                       │
                ┌──────┴──────┐
                │             │
                ▼             ▼
           Validator       Relayer
           (watches)      (delivers)
                │             │
                └─────┬───────┘
                      │
                  Signatures
                      │
                      ▼
               Local Storage
```

## Security Model

```
┌────────────────────────────────────────────────────────────┐
│                    Trust Assumptions                        │
├────────────────────────────────────────────────────────────┤
│                                                             │
│  Messages are valid IF:                                    │
│  ✓ Signed by threshold of validators (1/1 in your case)   │
│  ✓ Validators watch source chain correctly                │
│  ✓ Validators sign honest attestations                    │
│                                                             │
│  You trust:                                                │
│  • Your validator (you run it)                            │
│  • The source chain (BSC/Kasplex)                         │
│  • Hyperlane contracts (audited)                          │
│                                                             │
│  You DON'T need to trust:                                 │
│  • Relayer (can't forge messages)                         │
│  • Other users                                            │
│  • Block explorers                                         │
│                                                             │
└────────────────────────────────────────────────────────────┘
```

## Cost Breakdown

```
┌─────────────────────────────────────────────────────────────┐
│                      Cost Analysis                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  One-time Costs:                                            │
│  • Deploy contracts on Kasplex: ~0.1-0.5 KAS               │
│  • Announce validators (2x): ~0.01 KAS + ~0.01 BNB         │
│  • Deploy ISM (2x): ~0.05 KAS + ~0.05 BNB                  │
│  ────────────────────────────────────────────               │
│  Total one-time: ~0.2-0.6 KAS + 0.06 BNB                   │
│                                                              │
│  Ongoing Costs:                                             │
│  • Validator: Near-zero (just runs)                        │
│  • Relayer: Variable (per message delivered)               │
│    - BSC→Kasplex: ~0.001-0.01 KAS per message              │
│    - Kasplex→BSC: ~0.001-0.01 BNB per message              │
│                                                              │
│  Server Costs (if using cloud):                            │
│  • Small VM: $5-20/month                                    │
│  • Or run locally: $0                                       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Visual Checklist

```
Setup Progress:

□ Phase 1: Deploy Contracts
  └─□ Run deploy-kasplex.sh
    └─□ Verify addresses.yaml created

□ Phase 2: Validators
  ├─□ Clone hyperlane-monorepo
  ├─□ Configure validator for BSC
  ├─□ Configure validator for Kasplex
  ├─□ Run BSC validator
  ├─□ Run Kasplex validator
  ├─□ Announce BSC validator
  └─□ Announce Kasplex validator

□ Phase 3: Relayer
  ├─□ Configure relayer
  ├─□ Fund relayer (BSC)
  ├─□ Fund relayer (Kasplex)
  └─□ Run relayer

□ Phase 4: ISM
  ├─□ Create ISM config
  └─□ Deploy ISM

□ Phase 5: Test
  ├─□ Send test: BSC → Kasplex
  ├─□ Verify delivery
  ├─□ Send test: Kasplex → BSC
  └─□ Verify delivery

✅ Bridge Complete!
```

---

## Next Step

👉 **Read KASPLEX_QUICKSTART.md** to start your deployment!
