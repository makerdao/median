#!/usr/bin/env bash

set -e
export LC_NUMERIC=C

# With arg "init"
# Create accounts
# Deploy medianizer

keystore=~/.dapp/testnet/8545/keystore

if [ "$1" = init ]; then
    ETH_FROM=$(seth rpc eth_coinbase)
    export ETH_FROM
    export ETH_KEYSTORE=~/.dapp/testnet/8545/keystore/
    export ETH_PASSWORD=~/makerdao/terra/keystore/pass
    median=$(dapp create Median -G 2000000)
    seth send "$median" 'min(uint8)' 1 -G 100000
    for i in {1..1}; do
        address=$(
        geth 2>/dev/null account new --keystore "$keystore" --password=<(exit) 2>/dev/null \
            | grep Address | sed 's/Address: {\(.*\)}/\1/')
        seth send "$address" -V "$(seth --to-wei 1 eth)" -G 21000
        seth send "$median" 'lift(address)' "$address" -G 100000
        accounts+=($address)
    done
fi

price=$(setzer price magic)

for account in "${accounts[@]}"; do
    price=$(bc<<<"$price + 1")
    date=$(date +%s)
    hash=$(~/makerdao/terra/pack "$price" "$date")
    hash="0x$hash"
    sig=$(/home/nanexcool/go/bin/ethsign msg --from "$account" --key-store "$ETH_KEYSTORE" \
        --passphrase-file "$ETH_PASSWORD" --data "$hash")
    dates+=("$date")
    medianprices+=("$price")
    prices+=("$(seth --to-word "$(seth --to-wei "$price" eth)")")
    hashes+=("${hash##0x}")
    sig=${sig##0x}
    v=${sig:128:2}
    vs+=($(seth --to-word 0x"$v"))
    rs+=(${sig:0:64})
    ss+=(${sig:64:64})
done

# echo "${dates[@]}"
# echo "${prices[@]}"
# echo "${hashes[@]}"
# echo "${sigs[@]}"

price=$(tr " " "\n" <<< "${medianprices[@]}" | datamash median 1)
price=$(seth --to-wei "$price" eth)
price=$(seth --to-word "$price")

export ETH_GAS=500000

tx=$(set -x; seth send --async "$median" 'poke(uint128,uint128[],uint64[],bytes32[],uint8[],bytes32[],bytes32[])' \
"$price" \
"[$(IFS=,; echo "${prices[*]}")]" \
"[$(IFS=,; echo "${dates[*]}")]" \
"[$(IFS=,; echo "${hashes[*]}")]" \
"[$(IFS=,; echo "${vs[*]}")]" \
"[$(IFS=,; echo "${rs[*]}")]" \
"[$(IFS=,; echo "${ss[*]}")]")

echo "$tx"

exit

date=$(date +%s)
price=$(seth --to-wei 1500 eth)

hash1=$(seth keccak "$(seth --to-word "$price")$(seth --to-word "$date")")

hash2=$(~/makerdao/terra/pack "$price" "$date")
hash2="0x$hash2"

echo "$hash1"
echo "$hash2"

[[ $hash1 = "$hash2" ]] && echo "HASHES MATCH!"

res1=$(seth sign "$hash1")
echo "$res1"

res2=$(/home/nanexcool/go/bin/ethsign msg --from "$ETH_FROM" --key-store "$ETH_KEYSTORE" \
 --passphrase-file "$ETH_PASSWORD" --data "$hash2")
echo "$res2"

[[ $res1 = "$res2" ]] && echo "SIGATURES MATCH!"

sig=${res1##0x}
v=${sig:128:2}
v=$(seth --to-word 0x"$v")
r=${sig:0:64}
s=${sig:64:64}

echo "v:  $v"
echo "r:  $r"
echo "s:  $s"

tx=$(set -x; seth send --async "$median" 'poke(uint128,uint128[],uint64[],bytes32[],uint8[],bytes32[],bytes32[])' \
"$(seth --to-word "$price")" \
"[$(seth --to-word "$price")]" \
"[$date]" \
"[${hash1##0x}]" \
"[$v]" \
"[$r]" \
"[$s]")

echo "$tx"
#seth call "$median" 'check(bytes32,uint8,bytes32,bytes32)(address)' "${hash1##0x}" "$v" "$r" "$s"