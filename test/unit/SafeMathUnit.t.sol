// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2, stdError} from "forge-std/Test.sol";
import {ExposeSafeMath} from "../harness/ExposeSafeMath.sol";

contract SafeMathUnitTests is Test {
    ExposeSafeMath exposedContract;

    uint256 public constant MAX_UINT = type(uint256).max;

    function setUp() public {
        exposedContract = new ExposeSafeMath();
    }

    function test_add() public view {
        uint256 a = 1;
        uint256 b = 2;
        uint256 result = exposedContract._add(a, b);
        assertEq(result, 3);
    }

    function test_add_RevertIf_Overflow() public {
        vm.expectRevert(stdError.arithmeticError);
        exposedContract._add(MAX_UINT, 1);
    }

    function test_sub() public view {
        uint256 a = 5;
        uint256 b = 3;
        uint256 result = exposedContract._sub(a, b);
        assertEq(result, 2);
    }

    function test_sub_RevertIf_Underflow() public {
        vm.expectRevert("SafeMath: subtraction overflow");
        exposedContract._sub(3, 5);
    }

    function test_mul() public view {
        uint256 a = 3;
        uint256 b = 4;
        uint256 result = exposedContract._mul(a, b);
        assertEq(result, 12);
    }

    function test_mul_aIsZero() public view {
        uint256 a = 0;
        uint256 b = 4;
        uint256 result = exposedContract._mul(a, b);
        assertEq(result, 0);
    }

    function test_mul_RevertIf_Overflow() public {
        vm.expectRevert(stdError.arithmeticError);
        exposedContract._mul(MAX_UINT, 2);
    }

    function test_div() public view {
        uint256 a = 12;
        uint256 b = 4;
        uint256 result = exposedContract._div(a, b);
        assertEq(result, 3);
    }

    function test_div_RevertIf_DivideByZero() public {
        vm.expectRevert("SafeMath: division by zero");
        exposedContract._div(12, 0);
    }

    function test_mod() public view {
        uint256 a = 14;
        uint256 b = 5;
        uint256 result = exposedContract._mod(a, b);
        assertEq(result, 4);
    }

    function test_mod_RevertIf_ModuloByZero() public {
        vm.expectRevert("SafeMath: modulo by zero");
        exposedContract._mod(14, 0);
    }
}
