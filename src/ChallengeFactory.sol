pragma solidity ^0.8.13;

contract ChallengeFactory {
    address immutable rewardToken;
    mapping(address => uint256) public getId;
    mapping(uint256 => address) public getChallenge;
    address[] public allChallenges;

    event ChallengeCreated(uint256 indexed challengeId, address indexed challenge);

    constructor(address _rewardToken) {
        rewardToken = _rewardToken;
    }

    function allChallengesLength() external view returns (uint256) {
        return allChallenges.length;
    }
}
