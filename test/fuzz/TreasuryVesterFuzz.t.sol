// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {TreasuryVester} from "../../src/TreasuryVester.sol";
import {MockUNI} from "../mocks/MockUNI.sol";

contract TreasuryVesterFuzzTests is Test {
    TreasuryVester public treasuryVester;
    MockUNI uni;
    address uniAddress;

    address recipient = makeAddr("recipient");
    uint256 vestingAmount = 1 ether;
    uint256 vestingBegin;
    uint256 vestingCliff;
    uint256 vestingEnd;

    uint256 constant ONE_HOUR = 60 * 60 * 60;

    function setUp() public {
        vestingBegin = block.timestamp + 1;
        vestingCliff = vestingBegin + ONE_HOUR;
        vestingEnd = vestingCliff + ONE_HOUR;

        uni = new MockUNI();
        uniAddress = address(uni);

        treasuryVester =
            new TreasuryVester(uniAddress, recipient, vestingAmount, vestingBegin, vestingCliff, vestingEnd);
        uni.mint(address(treasuryVester), vestingAmount);
    }

    function testFuzz_constructor_InitsCorrectly(
        address uni_,
        address recipient_,
        uint256 amount,
        uint256 begin,
        uint256 cliff,
        uint256 end
    ) public {
        vm.assume(amount > 0);
        vm.assume(begin >= block.timestamp);
        vm.assume(cliff >= begin);
        vm.assume(end > cliff);

        TreasuryVester vesterFuzz = new TreasuryVester(uni_, recipient_, amount, begin, cliff, end);

        assertEq(vesterFuzz.uni(), uni_);
        assertEq(vesterFuzz.recipient(), recipient_);
        assertEq(vesterFuzz.vestingAmount(), amount);
        assertEq(vesterFuzz.vestingBegin(), begin);
        assertEq(vesterFuzz.vestingCliff(), cliff);
        assertEq(vesterFuzz.vestingEnd(), end);
    }

    function testFuzz_setRecipient_Changes(address newRecipient) public {
        vm.prank(newRecipient);
        treasuryVester.setRecipient(newRecipient);
        assertEq(treasuryVester.recipient(), newRecipient);
    }

    function testFuzz_claim_Partial(uint256 claimTime) public {
        claimTime = bound(claimTime, vestingCliff, vestingEnd);
        vm.warp(claimTime);
        uint256 initialBalance = uni.balanceOf(recipient);

        uint256 expectedAmount =
            vestingAmount * (block.timestamp - treasuryVester.lastUpdate()) / (vestingEnd - vestingBegin);
        vm.prank(recipient);
        treasuryVester.claim();
        uint256 balanceAfterClaim = uni.balanceOf(recipient);

        assertEq(initialBalance, 0);
        assertEq(balanceAfterClaim, expectedAmount);
    }

    function testFuzz_claim_Full(uint256 claimTime) public {
        vm.assume(claimTime > vestingEnd);
        vm.warp(claimTime);
        uint256 initialBalance = uni.balanceOf(recipient);

        uint256 expectedAmount = uni.balanceOf(address(treasuryVester));
        vm.prank(recipient);
        treasuryVester.claim();
        uint256 balanceAfterClaim = uni.balanceOf(recipient);
        assertEq(initialBalance, 0);
        assertEq(balanceAfterClaim, expectedAmount);
    }
}
