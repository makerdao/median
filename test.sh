#!/usr/bin/env bash

# For use with `dapp testnet --accounts N`

set -e

chain=$(seth chain 2>/dev/null) || {
    echo "Not connected, please run:"
    echo "  dapp testnet --accounts n (where n is an odd number)"
    echo ""
    exit 1
}

[[ $chain = ethlive ]] && {
    echo "Wow, you are connected to mainnet. Exiting!"
    exit 1
}

[[ $(seth rpc eth_accounts | cut -b 3-4 | sort | uniq | wc -l) == $(seth rpc eth_accounts | wc -l) ]] || {
    echo "There is a slot clash in the accounts that seth generated, try rerunning dapp testnet."
    exit 1
}

function hash {
    local wat wad zzz
    
    wat=$(seth --to-bytes32 "$(seth --from-ascii "$1")")    
    wad=$(seth --to-wei "$2" eth)
    wad=$(seth --to-word "$wad")
    zzz=$(seth --to-word "$3")

    seth keccak 0x"$wad$zzz$wat"
}

function join { local IFS=","; echo "$*"; }

mapfile -t accounts < <(seth rpc eth_accounts)

minaccounts=1
[[ ${#accounts[@]} -ge "$minaccounts" ]] || {
    echo "You need at least $minaccounts accounts"
    exit 1
}

ETH_GAS=2000000
ETH_KEYSTORE=~/.dapp/testnet/8545/keystore
ETH_PASSWORD=./empty
ETH_RPC_ACCOUNTS=yes
ETH_FROM=$(seth --to-address "${accounts[0]}")
export ETH_FROM ETH_KEYSTORE ETH_PASSWORD ETH_GAS ETH_RPC_ACCOUNTS

median=$(seth --to-address "$1" 2>/dev/null) || {
    echo >&2 "Building..."
    export SOLC_FLAGS="--optimize --evm-version constantinople"
    dapp build
    echo >&2 "Creating median..."
    name=$(seth --to-bytes32 "$(seth --from-ascii "ethusd")")
    median=$(dapp create Median)

    echo >&2 "Setting bar to ${#accounts[@]}"
    seth send "$median" 'setBar(uint256)' "$(seth --to-word ${#accounts[@]})"
    for acc in "${accounts[@]}"; do
        allaccs+=("${acc#0x}")
    done
    echo >&2 "Lifting ${#accounts[@]} accounts"
    seth send "$median" 'lift(address[] memory)' "[$(join "${allaccs[@]}")]"
}

echo "Median: $median"
i=1
ts=1549168920
for acc in "${accounts[@]}"; do
    price=$((250 + i))
    i=$((i + 1))
    hash=$(hash "ethusd" "$price" "$ts")
    sig=$(ethsign msg --from "$acc" --data "$hash" --passphrase-file "$ETH_PASSWORD")
    res=$(sed 's/^0x//' <<< "$sig")
    r=${res:0:64}
    s=${res:64:64}
    v=${res:128:2}
    v=$(seth --to-word "0x$v")
    
    price=$(seth --to-wei "$price" eth)
    prices+=("$(seth --to-word "$price")")
    tss+=("$(seth --to-word "$ts")")
    rs+=("$r")
    ss+=("$s")
    vs+=("$v")
#     cat <<EOF
# Address: $acc
#   val: $price
#   ts : $ts
#   v  : $v
#   r  : $r
#   s  : $s
# EOF
done

allts=$(join "${tss[@]}")
allprices=$(join  "${prices[@]}")
allr=$(join "${rs[@]}")
alls=$(join "${ss[@]}")
allv=$(join "${vs[@]}")

echo "Sending tx..."
tx=$(set -x; seth send --async "$median" 'poke(uint256[] memory,uint256[] memory,uint8[] memory,bytes32[] memory,bytes32[] memory)' \
"[$allprices]" \
"[$allts]" \
"[$allv]" \
"[$allr]" \
"[$alls]")

echo "TX: $tx"
echo SUCCESS: "$(seth receipt "$tx" status)"
echo GAS USED: "$(seth receipt "$tx" gasUsed)"

# setzer peek "$median"
