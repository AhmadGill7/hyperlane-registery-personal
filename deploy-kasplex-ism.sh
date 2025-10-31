#!/bin/bash

# Deploy a MultisigISM for Kasplex using the factory

# Your validator address
VALIDATOR="0x4f0b4c4c23E31f3e5bCCEfFb649AfdE964B7dF50"

# MultisigISM factory address (MessageId variant)
FACTORY="0x40A0Fc28582b3b08450A76d3674F5039054aAE94"

# Your private key
PRIVATE_KEY="da6ecf6ab4007ef6cb3133ca874be8fb84db39fd46a866a820c70c72642e6847"

# Kasplex RPC
RPC="https://rpc.kasplextest.xyz"

echo "Deploying MultisigISM with validator: $VALIDATOR"

# Deploy the ISM
# The factory.deploy function signature: deploy(address[] calldata _validators, uint8 _threshold)
cast send $FACTORY \
  "deploy(address[],uint8)" \
  "[$VALIDATOR]" \
  1 \
  --rpc-url $RPC \
  --private-key $PRIVATE_KEY \
  --gas-limit 3000000

echo ""
echo "Check the transaction receipt for the deployed ISM address"
echo "Then run: cast call <ISM_ADDRESS> 'moduleType()(uint8)' --rpc-url $RPC"
