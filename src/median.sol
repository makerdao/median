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
//pragma experimental ABIEncoderV2;

contract Median {

    // --- Auth ---
    mapping (address => uint) public wards;
    function rely(address guy) public auth { wards[guy] = 1; }
    function deny(address guy) public auth { wards[guy] = 0; }
    modifier auth { require(wards[msg.sender] == 1); _; }

    uint128 public val = 1;
    uint32  public age = 1;
    bytes32 public wat = "ethusd";
    uint256 public min = 1; // minimum valid feeds

    // Authorized oracles, set by an auth
    mapping (address => bool) public orcl;
    
    event LogMedianPrice(uint256 val, uint256 age);
    event LogFeedPrice(address src, uint256 val, uint256 age);

    //Set type of Oracle
    constructor(bytes32 wat_) public {
        wards[msg.sender] = 1;
        wat = wat_;
    }

    function read() external view returns (uint256) {
        require(val > 0, "Invalid price feed");
        return val;
    }

    function peek() external view returns (uint256,bool) {
        return (val, val > 0);
    }

    function recover(uint256 val_, uint256 age_, uint8 v, bytes32 r, bytes32 s, bytes32 pair_) internal pure returns (address) {
        return ecrecover(
            keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", keccak256(abi.encodePacked(val_, age_, pair_)))),
            v, r, s
        );
    }

    function poke(
        uint256[] calldata val_, uint256[] calldata age_,
        uint8[] calldata v, bytes32[] calldata r, bytes32[] calldata s) external
    {
        require(val_.length == min, "Not enough signed messages");

        uint256 bloom = 0;
        uint256 last = 0;
        uint256 zzz = age;
        // bytes32 pair = wat;

        for (uint i = 0; i < val_.length; i++) {
            // Validate the values were signed by an authorized oracle
            address signer = recover(val_[i], age_[i], v[i], r[i], s[i], wat);
            // Check that signer is an oracle
            require(orcl[signer], "Signature by invalid oracle");

            // Price feed age greater than last medianizer age
            require(age_[i] > zzz, "Stale message");

            // Check for ordered values
            require(val_[i] >= last, "Messages not in order");
            last = val_[i];

            uint8 slot = uint8(uint256(signer) >> 152);
            require((bloom >> slot) % 2 == 0, "Oracle already signed");
            bloom += uint256(2) ** slot;
            // emit LogFeedPrice(signer, val_[i], age_[i]);
        }
        
        // Write the value and timestamp to storage
        val = uint128(val_[val_.length >> 1]);
        age = uint32(block.timestamp);

        emit LogMedianPrice(val, age); // some event
    }

    function lift(address payable [15] calldata a) external auth {
        for (uint i = 0; i < a.length; i++) {
            require(a[i] != address(0), "No oracle 0");
            orcl[a[i]] = true;
        }
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
        require(min_ % 2 != 0, "Need odd number of messages");
        min = min_;
    }

}
