pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {ChallengeFactory} from "../src/ChallengeFactory.sol";

contract TokenScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        ChallengeFactory challengeFactory = new ChallengeFactory();
        vm.stopBroadcast();
    }
}
