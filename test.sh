#!/usr/bin/env bash

# For use with `dapp testnet --accounts 5`

set -e

function sign {
    wat=$(seth --to-bytes32 "$(seth --from-ascii "$1")")
    
    ethusd=$(seth --to-wei "$2" eth)
    wad=$(seth --to-word "$ethusd")

    zzz=$(seth --to-word "$3")

    seth keccak 0x"$wad$zzz$wat"
}

res=$(sign "ETHUSD" 220.5 "$(date +%s)")
echo "$res"

[ "$1" = 'y' ] && {
    echo "Building..."
    export SOLC_FLAGS=--optimize
    dapp build 2&>/dev/null
}

ETH_GAS=2000000
ETH_KEYSTORE=~/.dapp/testnet/8545/keystore
ETH_PASSWORD=./empty
ETH_RPC_ACCOUNTS=yes
ETH_FROM=$(seth --to-address "$(seth rpc eth_coinbase)")
export ETH_FROM ETH_KEYSTORE ETH_PASSWORD ETH_GAS ETH_RPC_ACCOUNTS

mapfile -t accounts < <(seth rpc eth_accounts)

# 1 oracle

price=200
ethusd=$(seth --to-wei "$price" eth)
ts=$(seth block latest timestamp)

wad=$(seth --to-word "$ethusd")
zzz=$(seth --to-word "$ts")
wat=$(seth --to-bytes32 "$(seth --from-ascii ETHUSD)")

hash=$(seth keccak 0x"$wad$zzz$wat")
echo "$hash"
price=$(seth --to-word "$ethusd")

sig=$(ethsign msg --from "$ETH_FROM" --data "$hash" --passphrase-file "$ETH_PASSWORD")
echo "$sig"

res=$(sed 's/^0x//' <<< "$sig")
r=${res:0:64}
s=${res:64:64}
v=${res:128:2}
v=$(seth --to-word "0x$v")

median=$(dapp create Median)
echo "$median"

seth send "$median" 'setMin(uint256)' "$(seth --to-word 1)"
seth send "$median" 'lift(address)' "$ETH_FROM"
seth call "$median" "orcl(address)(bool)" "$ETH_FROM"

tx=$(set -x; seth send --async "$median" 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' \
"[$price]" \
"[$zzz]" \
"[$v]" \
"[$r]" \
"[$s]")

echo SUCCESS: "$(seth receipt "$tx" status)"
echo GAS USED: "$(seth receipt "$tx" gasUsed)"

seth call "$median" 'peek()(bytes32,bool)'

## 15 oracles

price=230
ethusd=$(seth --to-wei "$price" eth)
ts=$(seth block latest timestamp)

wad=$(seth --to-word "$ethusd")
zzz=$(seth --to-word "$ts")
wat=$(seth --to-bytes32 "$(seth --from-ascii ETHUSD)")

hash=$(seth keccak 0x"$wad$zzz$wat")
echo "$hash"
price=$(seth --to-word "$ethusd")

sig=$(ethsign msg --from "$ETH_FROM" --data "$hash" --passphrase-file "$ETH_PASSWORD")
echo "$sig"

res=$(sed 's/^0x//' <<< "$sig")
r=${res:0:64}
s=${res:64:64}
v=${res:128:2}
v=$(seth --to-word "0x$v")

tx=$(set -x; seth send --async "$median" 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' \
"[$price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price]" \
"[$zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz]" \
"[$v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v]" \
"[$r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r]" \
"[$s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s]")

echo SUCCESS: $(seth receipt "$tx" status)
echo GAS USED: $(seth receipt "$tx" gasUsed)

# omg=$(seth call "$median" 'read()(bytes32)')
# seth --to-dec "$omg" | seth --to-fix 18 $(cat)
seth call "$median" 'peek()(bytes32,bool)'

# 25 oracles

price=350
ethusd=$(seth --to-wei "$price" eth)
ts=$(seth block latest timestamp)

wad=$(seth --to-word "$ethusd")
zzz=$(seth --to-word "$ts")
wat=$(seth --to-bytes32 "$(seth --from-ascii ETHUSD)")

hash=$(seth keccak 0x"$wad$zzz$wat")
echo "$hash"
price=$(seth --to-word "$ethusd")

sig=$(ethsign msg --from "$ETH_FROM" --data "$hash" --passphrase-file "$ETH_PASSWORD")
echo "$sig"

res=$(sed 's/^0x//' <<< "$sig")
r=${res:0:64}
s=${res:64:64}
v=${res:128:2}
v=$(seth --to-word "0x$v")

tx=$(set -x; seth send --async "$median" 'poke(uint256[],uint256[],uint8[],bytes32[],bytes32[])' \
"[$price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price, $price]" \
"[$zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz, $zzz]" \
"[$v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v, $v]" \
"[$r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r, $r]" \
"[$s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s, $s]")

echo SUCCESS: $(seth receipt "$tx" status)
echo GAS USED: $(seth receipt "$tx" gasUsed)

# omg=$(seth call "$median" 'read()(bytes32)')
# seth --to-dec "$omg" | seth --to-fix 18 $(cat)
seth call "$median" 'peek()(bytes32,bool)'