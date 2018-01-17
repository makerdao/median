// median.t.sol - tests for Medianizer v2

// Copyright (C) 2017  DappHub, LLC

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

pragma solidity ^0.4.18;

import "ds-test/test.sol";

import "./median.sol";

contract Oracle {
    Median m;
    
    function Oracle(Median m_) public {
        m = m_;
    }

    function doPoke(uint128 med, uint128[] val, uint64[] age,
                    bytes32[] h, uint8[] v, bytes32[] r, bytes32[] s) public
    {
        m.poke(med, val, age, h, v, r, s);
    }

}

contract MedianTest is DSTest {
    Median m;

    function setUp() public {
        m = new Median();
    }

    function testOne() public {
        uint v = 479 ether;
        log_named_uint("v", v);
        uint t = 1513030216;
        bytes32 h = keccak256(v,t);
        log_named_bytes32("h", h);
        assertTrue(true);
    }

    function testTwo() public {
        uint8 v = 28;
        bytes32 r = 0xb55285a60863bd6debed9b73bf39b3f66171df51d63a903244a4402928ad728c;
        bytes32 s = 0x24bdbd23b27c3ea3946f86bd59aaaa04f908287ef3ac54ddb9ce5b90d45b96b7;
        bytes32 h = 0xcc3805294611db321d58e6745a0841767eb87fd96a3ddbdbe88d40a81f4af6fa;
        address a1 = 0xe0264Bb2ECba9729501E21a366F57670b3CAfa1C;
        address a2 = ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", h), 
            v, r, s);
        assertEq(a1,a2);
    }

}
