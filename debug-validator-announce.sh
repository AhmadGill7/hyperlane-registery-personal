#!/bin/bash

# Debug Validator Announce Signature Issue
# This script helps diagnose why validator announcement is failing on Kasplex

if [ -z "$HYP_KEY" ]; then
    echo "❌ Error: HYP_KEY environment variable is not set"
    exit 1
fi

VALIDATOR_ADDRESS=$(cast wallet address --private-key $HYP_KEY)
MAILBOX="0xC505a8B225D46eB5252D96549C074e70855Fe4F3"
VALIDATOR_ANNOUNCE="0xc16287c8880c9Ab8b542846d321ec2DC90EF6993"
STORAGE_LOCATION="file:///app/hyperlane-validator-signatures-kasplextestnet"
DOMAIN=167012

echo "🔍 Debugging Validator Announcement on Kasplex"
echo "================================================"
echo "Validator Address: $VALIDATOR_ADDRESS"
echo "Mailbox: $MAILBOX"
echo "ValidatorAnnounce: $VALIDATOR_ANNOUNCE"
echo "Storage Location: $STORAGE_LOCATION"
echo "Domain: $DOMAIN"
echo ""

# Check if ValidatorAnnounce contract exists
echo "1️⃣ Checking ValidatorAnnounce contract..."
CODE=$(cast code $VALIDATOR_ANNOUNCE --rpc-url https://rpc.kasplextest.xyz)
if [ "$CODE" == "0x" ]; then
    echo "❌ ValidatorAnnounce contract does not exist!"
    exit 1
else
    echo "✅ ValidatorAnnounce contract exists"
fi

# Check the mailbox address in ValidatorAnnounce
echo ""
echo "2️⃣ Checking mailbox in ValidatorAnnounce contract..."
ANNOUNCED_MAILBOX=$(cast call $VALIDATOR_ANNOUNCE "mailbox()(address)" --rpc-url https://rpc.kasplextest.xyz)
echo "Announced Mailbox: $ANNOUNCED_MAILBOX"
echo "Expected Mailbox: $MAILBOX"

if [ "$(echo $ANNOUNCED_MAILBOX | tr '[:upper:]' '[:lower:]')" != "$(echo $MAILBOX | tr '[:upper:]' '[:lower:]')" ]; then
    echo "⚠️  WARNING: Mailbox mismatch!"
fi

# Get the announcement digest that needs to be signed
echo ""
echo "3️⃣ Getting announcement digest..."
DIGEST=$(cast call $VALIDATOR_ANNOUNCE "getAnnouncementDigest(string)(bytes32)" "$STORAGE_LOCATION" --rpc-url https://rpc.kasplextest.xyz)
echo "Announcement Digest: $DIGEST"

# Sign the digest
echo ""
echo "4️⃣ Signing the announcement digest..."
SIGNATURE=$(cast wallet sign --private-key $HYP_KEY "$DIGEST")
echo "Signature: $SIGNATURE"

# Try to verify the signature
echo ""
echo "5️⃣ Testing signature recovery..."
RECOVERED=$(cast call $VALIDATOR_ANNOUNCE "announce(address,string,bytes)(bool)" $VALIDATOR_ADDRESS "$STORAGE_LOCATION" "$SIGNATURE" --rpc-url https://rpc.kasplextest.xyz 2>&1)

if echo "$RECOVERED" | grep -q "!signature"; then
    echo "❌ Signature verification FAILED!"
    echo "Error: $RECOVERED"
    
    # Additional diagnostic: Try to recover the signer from the signature manually
    echo ""
    echo "6️⃣ Manual signature recovery test..."
    
    # Get what address the contract would recover
    echo "Testing with cast..."
    cast wallet verify --address $VALIDATOR_ADDRESS "$DIGEST" "$SIGNATURE"
    
    echo ""
    echo "🔍 DIAGNOSIS:"
    echo "The validator announcement is failing because the signature cannot be verified."
    echo "This could be due to:"
    echo "  1. Different signing scheme expected by the contract"
    echo "  2. EIP-191 vs EIP-712 signing method mismatch"
    echo "  3. Chain ID or domain included in signature"
    echo ""
    echo "SOLUTION: The ValidatorAnnounce contract might need to be redeployed or"
    echo "the validator agent might need different signing configuration."
    
elif echo "$RECOVERED" | grep -q "replay"; then
    echo "⚠️  Signature is valid but announcement was already made (replay protection)"
    echo "This is actually GOOD - it means your validator CAN announce!"
else
    echo "✅ Signature verification would succeed!"
    echo "Response: $RECOVERED"
fi

echo ""
echo "7️⃣ Checking if validator has already announced..."
ANNOUNCED_LOCATIONS=$(cast call $VALIDATOR_ANNOUNCE "getAnnouncedStorageLocations(address[])(string[][])" "[$VALIDATOR_ADDRESS]" --rpc-url https://rpc.kasplextest.xyz 2>&1)
echo "Announced locations: $ANNOUNCED_LOCATIONS"
