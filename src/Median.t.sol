pragma solidity ^0.4.19;

import "ds-test/test.sol";

import "./Median.sol";

contract MedianTest is DSTest {
    Median median;

    function setUp() public {
        median = new Median();
    }

    function testFail_basic_sanity() public {
        assertTrue(false);
    }

    function test_basic_sanity() public {
        assertTrue(true);
    }
}
