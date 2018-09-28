// median.t.sol - tests for Medianizer v2

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

pragma solidity ^0.4.24;

// import "ds-test/test.sol";

// import "./median.sol";

// contract Oracle {
//     Median m;
    
//     constructor(Median m_) public {
//         m = m_;
//     }

//     function doPoke(
//         uint256 med, uint256[] val, uint256[] age,
//         uint8[] v, bytes32[] r, bytes32[] s) public
//     {
//         m.poke(med, val, age, v, r, s);
//     }

// }

// contract MedianTest is DSTest {
//     Median m;

//     function setUp() public {
//         m = new Median();
//     }

//     function testOne() public {
//         uint v = 479 ether;
//         emit log_named_uint("v", v);
//         uint t = 1513030216;
//         emit log_named_uint("t", t);
//         bytes32 h = keccak256(abi.encodePacked(v,t));
//         emit log_named_bytes32("h", h);
//         assertTrue(true);
//     }

//     function testTwo() public {
//         uint128 a = 350 ether;
//         emit log_named_uint("a", a);
//         bytes memory b = abi.encodePacked(a);
//         emit logs(b);
//         bytes32 h = keccak256(b);
//         emit log_named_bytes32("h", h);
//         assertTrue(false);
//     }

// }
