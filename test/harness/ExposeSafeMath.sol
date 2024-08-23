// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;

import {SafeMath} from "../../src/TreasuryVester.sol";

contract ExposeSafeMath {
    using SafeMath for uint256;

    function _add(uint256 a, uint256 b) public pure returns (uint256) {
        return a.add(b);
    }

    function _sub(uint256 a, uint256 b) public pure returns (uint256) {
        return a.sub(b);
    }

    function _mul(uint256 a, uint256 b) public pure returns (uint256) {
        return a.mul(b);
    }

    function _div(uint256 a, uint256 b) public pure returns (uint256) {
        return a.div(b);
    }

    function _mod(uint256 a, uint256 b) public pure returns (uint256) {
        return a.mod(b);
    }
}
