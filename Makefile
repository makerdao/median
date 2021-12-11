.PHONY: test.sh
build   :; dapp --use solc:0.5.12 build
clean   :; dapp clean
test    :; dapp --use solc:0.5.12 test -v ${TEST_FLAGS}
test.sh :; nix-shell -p bash --run ./test.sh
