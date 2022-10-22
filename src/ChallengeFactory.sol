pragma solidity ^0.8.13;

import {Challenge} from "./Challenge.sol";

contract ChallengeFactory {
    address immutable rewardToken;
    mapping(address => uint256) public getId;
    mapping(uint256 => address) public getChallenge;
    address[] public allChallenges;
    address private owner;

    event ChallengeCreated(uint256 indexed challengeId, address indexed challenge);

    error InvalidTimestamp(uint256, uint256);
    error ChallengeAlreadyCreated(address);

    constructor(address _rewardToken) {
        rewardToken = _rewardToken;
    }

    function allChallengesLength() external view returns (uint256) {
        return allChallenges.length;
    }

    function deployChallenge(
        uint256 _challengeId,
        string memory _challengeName,
        uint256 _depositAmount,
        uint256 _beginTimestamp,
        uint256 _endTimestamp
    ) public returns (Challenge challenge) {
        challenge =
        new Challenge{salt: keccak256(abi.encodePacked(_challengeId))}(_challengeId, _challengeName, rewardToken, _beginTimestamp, _endTimestamp, _depositAmount, owner);
    }

    function createChallenge(
        uint256 _challengeId,
        string calldata _challengeName,
        uint256 _depositAmount,
        uint256 _beginTimestamp,
        uint256 _endTimestamp
    ) external returns (address challenge) {
        if (block.timestamp > _beginTimestamp) revert InvalidTimestamp(_beginTimestamp, _endTimestamp);
        if (_endTimestamp < _beginTimestamp) revert InvalidTimestamp(_beginTimestamp, _endTimestamp);
        if (getChallenge[_challengeId] != address(0)) revert ChallengeAlreadyCreated(getChallenge[_challengeId]);
        Challenge challengeContract =
            deployChallenge(_challengeId, _challengeName, _depositAmount, _beginTimestamp, _endTimestamp);
        challenge = address(challengeContract);
    }
}
