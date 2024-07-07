// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {TreasuryVester} from "../../src/TreasuryVester.sol";
import {MockUNI} from "../mocks/MockUNI.sol";

contract TreasuryVesterUnitTests is Test {
    TreasuryVester public treasuryVester;
    MockUNI uni;
    address uniAddress;

    address user = makeAddr("user");

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
        // treasuryVester = TreasuryVester(
        //     deployCode(
        //         "TreasuryVester.sol:TreasuryVester",
        //         abi.encode(uni, recipient, vestingAmount, vestingBegin, vestingCliff, vestingEnd)
        //     )
        // );
        // console2.log(treasuryVester);

        uni.mint(address(treasuryVester), vestingAmount);
    }

    function test_constructor_InitsSuccessfully() public view {
        assertEq(treasuryVester.uni(), uniAddress);
        assertEq(treasuryVester.recipient(), recipient);

        assertEq(treasuryVester.vestingAmount(), vestingAmount);
        assertEq(treasuryVester.vestingBegin(), vestingBegin);
        assertEq(treasuryVester.vestingCliff(), vestingCliff);
        assertEq(treasuryVester.vestingEnd(), vestingEnd);
        assertEq(treasuryVester.lastUpdate(), vestingBegin);
    }

    function test_constructor_RevertIf_VestingBeginTooEarly() public {
        vm.expectRevert("TreasuryVester::constructor: vesting begin too early");
        new TreasuryVester(uniAddress, recipient, vestingAmount, 0, vestingCliff, vestingEnd);
    }

    function test_constructor_RevertIf_CliffIsTooEarly() public {
        vm.expectRevert("TreasuryVester::constructor: cliff is too early");

        new TreasuryVester(uniAddress, recipient, vestingAmount, vestingBegin, vestingBegin - 1, vestingEnd);
    }

    function test_constructor_RevertIf_EndIsTooEarly() public {
        vm.expectRevert("TreasuryVester::constructor: end is too early");
        new TreasuryVester(uniAddress, recipient, vestingAmount, vestingBegin, vestingCliff, vestingCliff);
    }

    function test_setRecipient_RevertIf_CalledByNonRecipient() public {
        vm.expectRevert("TreasuryVester::setRecipient: unauthorized");
        treasuryVester.setRecipient(user);
    }

    // ! Not sure if this is intended, but anyone can set themselves to be recipient ???
    function test_setRecipient_ChangesSuccessfully() public {
        vm.prank(user);
        treasuryVester.setRecipient(user);

        assertEq(treasuryVester.recipient(), user);
    }

    function test_claim_RevertIf_NotTimeYet() public {
        vm.expectRevert("TreasuryVester::claim: not time yet");
        treasuryVester.claim();
    }

    function test_claim_PartialClaimsSuccess() public {
        vm.warp(vestingBegin + (vestingEnd - vestingBegin) / 2);
        uint256 expectedAmount = vestingAmount / 2;

        vm.prank(recipient);
        treasuryVester.claim();

        uint256 recipientBalance = uni.balanceOf(recipient);
        uint256 lastUpdate = treasuryVester.lastUpdate();

        assertEq(recipientBalance, expectedAmount);
        assertEq(lastUpdate, block.timestamp);
    }

    function test_claim_FullClaimSuccess() public {
        vm.warp(vestingEnd + 1);
        vm.prank(recipient);
        treasuryVester.claim();

        uint256 recipientBalance = uni.balanceOf(recipient);
        assertEq(recipientBalance, vestingAmount);
    }
}
