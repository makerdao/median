#!/usr/bin/env bash

# For use with `dapp testnet`

set -e

export SOLC_FLAGS=--optimize
port=2000
[[ $1 ]] && port=$1
export ETH_RPC_PORT=$port
export ETH_FROM=`seth rpc eth_coinbase`
export ETH_GAS=3000000

dapp build

usd=550
price=$(seth --to-word $(seth --to-wei "$usd" eth))
date=$(seth --to-word $(date +%s))

median=$(dapp create Median)
echo $median

seth send "$median" 'min(uint8)' $(seth --to-word 1)

seth send "$median" 'lift(address)' $ETH_FROM

hash=$(seth keccak "$price$date")
hash=$(sed 's/^0x//' <<< "$hash")

res=$(seth sign -F "$ETH_FROM" "$hash")
res=$(sed 's/^0x//' <<< "$res")
r=${res:0:64}
s=${res:64:64}
v=0x${res:128:2}
v=$(seth --to-word "$v")

tx=$(set -x; seth send --async "$median" 'poke(uint128,uint128[],uint64[],bytes32[],uint8[],bytes32[],bytes32[])' \
$price \
"[$price]" \
"[$date]" \
"[$hash]" \
"[$v]" \
"[$r]" \
"[$s]")

echo SUCCESS: $(seth receipt "$tx" status)
echo GAS USED: $(seth receipt "$tx" gasUsed)

seth call "$median" 'peek()(bytes32,bool)'

usd=620.1
price=$(seth --to-word $(seth --to-wei "$usd" eth))
date=$(seth --to-word $(date +%s))

hash=$(seth keccak "$price$date")
hash=$(sed 's/^0x//' <<< "$hash")

res=$(seth sign -F "$ETH_FROM" "$hash")
res=$(sed 's/^0x//' <<< "$res")
r=${res:0:64}
s=${res:64:64}
v=0x${res:128:2}
v=$(seth --to-word "$v")

tx=$(set -x; seth send --async "$median" 'poke(uint128,uint128[],uint64[],bytes32[],uint8[],bytes32[],bytes32[])' \
$price \
"[$price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price]" \
"[$date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date, $date]" \
"[$hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash, $hash]" \
"[$v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v]" \
"[$r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r]" \
"[$s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s]")

echo SUCCESS: $(seth receipt "$tx" status)
echo GAS USED: $(seth receipt "$tx" gasUsed)

# omg=$(seth call "$median" 'read()(bytes32)')
# seth --to-dec "$omg" | seth --to-fix 18 $(cat)
seth call "$median" 'peek()(bytes32,bool)'
