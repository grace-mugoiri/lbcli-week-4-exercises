# Create a raw transaction that can be spent in 2 weeks time, assuming the current block is 25
# Amount of 20,000,000 satoshis to this address: 2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP 
# Use the UTXOs from the transaction below
# transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

transaction="01000000000101c8b0928edebbec5e698d5f86d0474595d9f6a5b2e4e3772cd9d1005f23bdef772500000000ffffffff0276b4fa0000000000160014f848fe5267491a8a5d32423de4b0a24d1065c6030e9c6e000000000016001434d14a23d2ba08d3e3edee9172f0c97f046266fb0247304402205fee57960883f6d69acf283192785f1147a3e11b97cf01a210cf7e9916500c040220483de1c51af5027440565caead6c1064bac92cb477b536e060f004c733c45128012102d12b6b907c5a1ef025d0924a29e354f6d7b1b11b5a7ddff94710d6f0042f3da800000000"

# Decode the transaction so we can programmatically find the txid and UTXOs
DECODED=$(bitcoin-cli -regtest decoderawtransaction "$transaction")
TXID=$(echo "$DECODED" | jq -r '.txid')

# Task says "UTXOs" (plural) — use BOTH outputs of the given transaction as inputs,
# since neither one alone covers the 20,000,000 sat payment.
INPUTS=$(echo "$DECODED" | jq -c --arg txid "$TXID" \
  '[.vout[] | {txid: $txid, vout: .n, sequence: 4294967294}]')

# Current block height is 25; 2 weeks = 2016 blocks (144 blocks/day * 14 days)
CURRENT_BLOCK=25
LOCKTIME=$((CURRENT_BLOCK + 2016))

# Recipient and amount
RECIPIENT="2MvLcssW49n9atmksjwg2ZCMsEMsoj3pzUP"
AMOUNT="0.20000000"

# Build the raw transaction with the calculated locktime.
# sequence must be < 0xffffffff for nLockTime to be honored.
RAW_TX=$(bitcoin-cli -regtest createrawtransaction \
  "$INPUTS" \
  "{\"$RECIPIENT\":$AMOUNT}" \
  $LOCKTIME)

echo "$RAW_TX"