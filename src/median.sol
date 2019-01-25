// median.sol - Medianizer v2

// Copyright (C) 2017, 2018  DappHub, LLC

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

import "ds-thing/thing.sol";

contract Median is DSAuth {

    uint128 public val;
    uint48  public age;
    bytes32 public wat;
    uint256 public min; // minimum valid feeds

    //Set type of Oracle
    constructor(bytes32 _wat) public {
        wat = _wat;
    }

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    event LogMedianPrice(uint128 val, uint48 age);
    event LogFeedPrice(address src, uint256 val, uint256 age);

    function read() external view returns (bytes32) {
        require(val > 0, "Invalid price feed");
        return bytes32(uint256(val));
    }

    function peek() external view returns (bytes32,bool) {
        return (bytes32(uint256(val)), val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s, bytes32 wat_) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, wat_)))),
            v, r, s
        );
    }

    function getSlot(address a) internal pure returns (uint8) {
        return uint8(uint256(a) >> 152);
    }

    function shr(uint256 a, uint256 b) internal pure returns (uint256) {
        return a >> b;
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        uint256 l = val_.length;
        require(l >= min, "Not enough signed messages");
        require(l % 2 != 0, "Need odd number of messages");

        // bloom filter
        uint256 bloom = 0;

        for (uint i = 0; i < l; i++) {
            // Validate the values were signed by an authorized oracle
            uint256 val_i  = val_[i];
            uint256 age_i  = age_[i];
            address signer = recover(val_i, age_i, v[i], r[i], s[i], wat);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");

            // Price feed age greater than last medianizer age
            require(age_i > uint256(age), "Stale message");

            // Check for ordered values (TODO: better out of bounds check?)
            if ((i + 1) < l) {
                require(val_i <= val_[i + 1], "Messages not in order");
            }

            // Check for uniqueness (TODO: is this the best we can do?)
            // for (uint j = 0; j < i; j++) {
            //     require(signers[j] != signer, "Oracle already signed");
            // }
            // signers[i] = signer;

            uint8 slot = getSlot(signer);
            require(shr(bloom, slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
            emit LogFeedPrice(signer, val_i, age_i);
        }

        // Write the value and timestamp to storage
        // require(med_ == val_[(l - 1) / 2], "Sanity check fail");
        val = uint128(val_[(l - 1) / 2]);
        age = uint48(block.timestamp);

        emit LogMedianPrice(val, age);
    }

    function lift(address a) external auth {
        require(a != address(0), "No oracle 0");
        orcl[a] = true;
    }

    function drop(address a) external auth {
        orcl[a] = false;
    }

    function setMin(uint256 min_) external auth {
        require(min_ > 0, "Minimum valid oracles cannot be 0");
        min = min_;
    }

}
