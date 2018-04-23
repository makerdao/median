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

pragma solidity ^0.4.20;

import "ds-thing/thing.sol";

contract Median is DSThing {

    uint128        val;
    uint32  public age;
    
    uint8   public min; // minimum valid feeds

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;

    event LogPrice(uint128 val, uint32 age);

    function read() public view returns (bytes32) {
        require(val > 0);
        return bytes32(val);
    }

    function peek() public view returns (bytes32,bool) {
        return (bytes32(val), val > 0);
    }

    function poke(uint128 med_, uint128[] val_, uint32[] age_,
                  bytes32[] h, uint8[] v, bytes32[] r, bytes32[] s) public
    {
        uint length = val_.length;
        
        require(length >= min);

        // Array to store signer addresses, to check for uniqueness later
        address[] memory signers = new address[](length);

        for (uint i = 0; i < length; i++) {
            // Validate the hash and values values were signed by an authorized oracle
            require(keccak256(uint(val_[i]), uint(age_[i])) == h[i]);

            address signer = ecrecover(
                keccak256("\x19Ethereum Signed Message:\n32", h[i]),
                v[i], r[i], s[i]
            );

            // Check that signer is an oracle
            require(orcl[signer]);

            // Price feed age greater than last medianizer age
            require(age_[i] > age);

            // Check for ordered values (TODO: better out of bounds check?)
            if ((i + 1) < length) {
                require(val_[i] <= val_[i + 1]);
            }
            
            // Check for uniqueness (TODO: is this the best we can do?)
            for (uint j = 0; j < i; j++) {
                require(signers[j] != signer);
            }
            signers[i] = signer;
        }
        
        // Grab the median (values are already ordered)
        if (length % 2 == 0) {
            // Even number of feeds, grab middle ones and average
            uint128 one = val_[(length / 2) - 1];
            uint128 two = val_[length / 2];
            // Check the median value provided is accurate
            require(med_ == wdiv(add(one, two), 2 ether));
        } else {
            // Grab middle value, check if it's accurate
            require(med_ == val_[(length - 1) / 2]);
        }
        // Write the value and timestamp to storage
        val = med_;
        age = uint32(block.timestamp);

        LogPrice(val, age); // some event
    }

    function lift(address a) public auth {
        require(a != 0x0);
        orcl[a] = true;
    }

    function drop(address a) public auth {
        orcl[a] = false;
    }

    function setMin(uint8 min_) public auth {
        require(min_ > 0);
        min = min_;
    }

}
