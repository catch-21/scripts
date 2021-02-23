#!/bin/bash

i=1
while [[ -d ./$i ]]
do
    ((i=i+1))
done

mkdir ./$i

cardano-cli address key-gen --verification-key-file $i/policy.vkey --signing-key-file $i/policy.skey
echo $(cardano-cli address key-hash --payment-verification-key-file $i/policy.vkey) > $i/keyhash
echo "{\"keyHash\": \"$(cat $i/keyhash)\", \"type\": \"sig\"}" > $i/policy.script
echo $(cardano-cli transaction policyid --script-file $i/policy.script) > $i/policyId
echo $(cardano-cli address build --payment-verification-key-file $i/policy.vkey --testnet-magic $(cat magic)) > $i/policy.addr
