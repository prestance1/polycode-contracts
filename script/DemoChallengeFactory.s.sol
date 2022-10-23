pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {DemoChallengeFactory} from "../src/demo/DemoChallengeFactory.sol";

contract FactoryScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        DemoChallengeFactory challengeFactory = new DemoChallengeFactory();
        vm.stopBroadcast();
    }
}
