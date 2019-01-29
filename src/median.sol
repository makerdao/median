// median.sol - Medianizer v2

// Copyright (C) 2019 Lev Livnev <lev@liv.nev.org.uk>

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.2;

contract MedianI {
  function read() external returns (bytes32);
  function peek() external returns (bytes32, bool);
  function poke(uint256[] memory val_, uint256[] memory age_, uint8[] memory v, bytes32[] memory r, bytes32[] memory s) public;
  function lift(address a) external;
  function drop(address a) external;
  function setMin(uint256 min_) external;
}

// TODO: auth, logs
// TODO: safety/range checks

contract Median {

  constructor (bytes32 _wat) public {
    assembly {
      // set wat = _wat
      codecopy(0, sub(codesize, 32), 32)
      sstore(2, mload(0))
    }
  }

  function () external {
    assembly {
      let sig := div(calldataload(0), 0x100000000000000000000000000000000000000000000000000000000)
      if eq(sig, 0x57de26a4) /* function read() external returns (bytes32) */ {
        // iff val > 0
        if eq(sload(0), 0) {
          mstore(0, "Invalid price feed")
          revert(0, 32)
        }

        mstore(64, sload(0))
        return(64, 32)
      }

      if eq(sig, 0x59e02dd7) /* function peek() external returns (bytes32,bool) */ {
        mstore(64, sload(0))
        mstore(96, gt(sload(0), 0))
        return(64, 64)
      }

      if eq(sig, 0x89bbb8b2) /* function poke(uint256[] val_, uint256[] age_, uint8[] v, bytes32[] r, bytes32[] s) public returns () */ {
        // l := val_.length
        let offset_val := add(4, calldataload(4))
        let l := calldataload(offset_val)

        // iff l >= min
        if lt(l, sload(3)) {
          mstore(0, "Not enough signed messages")
          revert(0, 32)
        }

        // iff l % 2 == 1
        if eq(mod(l, 2), 0) {
          mstore(0, "Need odd number of messages")
          revert(0, 32)
        }

        let age := sload(1)
        let wat := sload(2)

        let offset_age := add(4, calldataload(36))
        let offset_v   := add(4, calldataload(68))
        let offset_r   := add(4, calldataload(100))
        let offset_s   := add(4, calldataload(132))

        let bloom     := 0
        let lastval   := 0

        for { let i := 0 } lt(i, l) { i := add(i, 1) } {
          let offseti := add(32, mul(i, 32))
          let vali := calldataload(add(offset_val, offseti))
          let agei := calldataload(add(offset_age, offseti))

          // signer := recover(val_[i], age_[i], v[i], r[i], s[i], wat)
          let signer := recover(vali,
                                agei,
                                calldataload(add(offset_v, offseti)),
                                calldataload(add(offset_r, offseti)),
                                calldataload(add(offset_s, offseti)),
                                wat)

          // iff orcl[signer]
          let hash_0 := hash2(4, signer)
          if eq(sload(hash_0), 0) {
            mstore(0, "Signature by invalid oracle")
            revert(0, 32)
          }

          // iff age_[i] > age
          if iszero(gt(agei, age)) {
            mstore(0, "Stale message")
            revert(0, 32)
          }

          // iff val_[i] > lastval
          if lt(vali, lastval) {
            mstore(0, "Messages not in order")
            revert(0, 32)
          }

          // lastval := val[i]
          lastval := vali

          // slot := get_slot(signer)
          let slot := get_slot(signer)

          // iff shr(bloom, slot) % 2 == 0
          if eq(1, mod(shift_right(bloom, slot), 2)) {
            mstore(0, "Oracle already signed")
            revert(0, 32)
          }

          // bloom := add(bloom, 2**slot)
          bloom := add(bloom, exp(2, slot))
        }

        // set val := val_[(l - 1)/2]
        sstore(0, calldataload(add(add(offset_val, 16), mul(l, 16))))

        // set age := timestamp
        sstore(1, timestamp)

        stop()
      }

      if eq(sig, 0x3c278bd5) /* function lift(address a) external returns () */ {
        // iff a != 0
        if eq(calldataload(4), 0) {
          mstore(0, "No oracle 0")
          revert(0, 32)
        }

        // set orcl[a] = 1
        let hash_0 := hash2(4, calldataload(4))
        sstore(hash_0, 1)

        stop()
      }

      if eq(sig, 0x91f2700a) /* function drop(address a) external returns () */ {
        // set orcl[a] = 0
        let hash_0 := hash2(4, calldataload(4))
        sstore(hash_0, 0)

        stop()
      }

      if eq(sig, 0x45dc3dd8) /* function setMin(uint256 min_) external returns () */ {
        // iff min != 0
        if eq(calldataload(4), 0) {
          mstore(0, "min > 0")
          revert(0, 32)
        }

        // set min = min_
        sstore(3, calldataload(4))

        stop()
      }

      // failed to select any of the public methods
      mstore(0, "failed to select a method")
      revert(0, 32)

      function recover(val_, age_, v, r, s, wat_) -> a {
        // hash_0 := keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat_))))
        let hash_0 := hash4(0x19457468657265756d205369676e6564204d6573736167653a0a333200000000, 28, val_, age_, wat_)

        mstore(64, hash_0)
        mstore(96, v)
        mstore(128, r)
        mstore(160, s)
        if iszero(staticcall(gas, 1, 64, 128, 64, 32)) {
          mstore(0, "ECRECOVER failure!")
          revert(0, 32)
        }

        a := mload(64)
      }

      function get_slot(a) -> slot {
        slot := shift_right(a, 152)
      }

      function shift_right(a, b) -> c {
        c := div(a, exp(2, b))
      }

      // map[key] translates to hash(key ++ idx(map))
      function hash2(b, i) -> h {
        mstore(0, i)
        mstore(32, b)
        h := keccak256(0, 64)
      }

      function hash4(a, sizea, b, c, d) -> h {
        mstore(0, a)
        mstore(sizea, b)
        mstore(add(sizea, 32), c)
        mstore(add(sizea, 64), d)
        mstore(sizea, keccak256(sizea, 96))
        h := keccak256(0, add(sizea, 32))
      }
    }
  }
}
