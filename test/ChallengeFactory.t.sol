// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/ChallengeFactory.sol";
import "../src/Challenge.sol";
import {PLC} from "../src/PLCToken.sol";

contract ChallengeFactoryTest is Test {
    ChallengeFactory public factory;
    PLC public plc;
    address alice = address(0x42);
    address bob = address(0x43);
    address team = address(0x44);

    function setUp() public {
        factory = new ChallengeFactory();
        plc = new PLC();
    }

    function testDeploy() public {
        address challengeAddress =
            factory.createChallenge(1, "Two Sum", 20 * 10 ** 18, block.timestamp, block.timestamp + 10000);
        console.log(challengeAddress);
        assertEq(factory.getId(challengeAddress), 1);
    }

    function testWinner() public {
        address challengeAddress =
            factory.createChallenge(2, "Two Sum", 20 * 10 ** 18, block.timestamp, block.timestamp + 10000);
        console.log(challengeAddress);

        plc.transfer(alice, 30 * 10 ** 18);
        console.log(uint256(plc.balanceOf(alice)));
        vm.startPrank(alice);
        plc.approve(challengeAddress, 25 * 10 ** 18);
        console.log(plc.allowance(alice, challengeAddress));
        Challenge(challengeAddress).subscribe();
        bool subscriptionvalue = Challenge(challengeAddress).isSubscribed(alice);
        console.log(subscriptionvalue);
        vm.stopPrank();

        Challenge(challengeAddress).setWinner(alice);
        console.log(Challenge(challengeAddress).winner());
        assertEq(Challenge(challengeAddress).winner(), alice);
    }

    function testClaimReward() public {
        address challengeAddress =
            factory.createChallenge(2, "Two Sum", 20 * 10 ** 18, block.timestamp, block.timestamp + 10000);
        console.log(challengeAddress);

        plc.transfer(alice, 30 * 10 ** 18);
        console.log(uint256(plc.balanceOf(alice)));
        vm.startPrank(alice);
        plc.approve(challengeAddress, 25 * 10 ** 18);
        console.log(plc.allowance(alice, challengeAddress));
        Challenge(challengeAddress).subscribe();
        bool subscriptionvalue = Challenge(challengeAddress).isSubscribed(alice);
        console.log(subscriptionvalue);
        vm.stopPrank();

        Challenge(challengeAddress).setWinner(alice);
        console.log(Challenge(challengeAddress).winner());
        vm.startPrank(alice);
        Challenge(challengeAddress).claimReward();
        assertEq(Challenge(challengeAddress).isClaimed(), true);
    }
}
