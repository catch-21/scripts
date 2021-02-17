#!/bin/bash

####
## Need to execute in directory with:
## - acct.skey and acct.addr that will receive tokens - must have UTxO with enough funds to make transaction
## - node directory with active socket
## - magic
####

UTXO=$1
COUNT=$2
ASSET_NAME=$3 #optional
if [[ $4 ]]; then TOKEN_VALUE=$4; else TOKEN_VALUE=1; fi #optional

ADDR=$(cat acct.addr)
FEE=1000000
DIR=many-ma-policy

mkdir -p ./$DIR
rm -f ./$DIR/*

cardano-cli address key-gen --verification-key-file $DIR/policy.vkey --signing-key-file $DIR/policy.skey
echo $(cardano-cli address key-hash --payment-verification-key-file $DIR/policy.vkey) > $DIR/keyhash
echo "{\"keyHash\": \"$(cat $DIR/keyhash)\", \"type\": \"sig\"}" > $DIR/policy.script
echo $(cardano-cli transaction policyid --script-file $DIR/policy.script) > $DIR/policyId
policyId=$(cat $DIR/policyId)

utxo_query=$(CARDANO_NODE_SOCKET_PATH=node/node.sock cardano-cli query utxo --address $ADDR --testnet-magic $(cat magic) --mary-era)

got_utxo="false"
utxo_query_line=3
while [ "$got_utxo" != "true" ]
do
    utxo=($(echo "$utxo_query" | sed -n "${utxo_query_line}p"))
    if [[ -z "$utxo" ]]; then echo "utxo not in query" && exit 1; fi
    if [[ $utxo != $UTXO ]]; then echo "utxo "$utxo" doesn't match expected" && utxo_query_line=$(expr $utxo_query_line + 1) && continue; fi
    tx_hash=${utxo[0]}
    tx_ix=${utxo[1]}
    lovelace=${utxo[2]}
    echo "Found utxo $UTXO"
    got_utxo="true"
done

ma_string=""
mint_string=""
for ((i=1; i<=$COUNT; i++))
do
   ma_string="$ma_string+$TOKEN_VALUE $policyId.$ASSET_NAME$i"
done
[[ ${#ma_string} > 0 ]] && mint_string="${ma_string:1}"

printf "\nBuilding raw transaction...\n"
echo $(cardano-cli transaction build-raw --tx-in $tx_hash#$tx_ix --tx-out="$ADDR+$(expr $lovelace - $FEE) $ma_string" --mint="$mint_string" --fee $FEE --out-file txbody --mary-era)

echo "Signing..."
echo $(cardano-cli transaction sign --tx-body-file txbody --signing-key-file acct.skey --signing-key-file $DIR/policy.skey --script-file $DIR/policy.script --testnet-magic $(cat magic) --tx-file tx)

echo "Submit?"
read
$(CARDANO_NODE_SOCKET_PATH=node/node.sock cardano-cli transaction submit --tx-file tx --testnet-magic $(cat magic))
