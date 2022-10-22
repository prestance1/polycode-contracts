pragma solidity ^0.8.13;
///@title The interface for Challenge factory
///@notice The Challenge factory facilitates the creation of on-chain Challenges

interface IChallengeFactory {
    function owner() external view returns (address);

    function getChallenge(uint256 _challengeId) external view returns (address);

    function getId(address _challenge) external view returns (uint256);

    function allChallenges(uint256) external view returns (address);

    function allChallengesLength() external view returns (uint256);

    function createChallenge(
        uint256 _challengeId,
        string calldata _challengeName,
        uint256 _depositAmount,
        uint256 _beginTimestamp,
        uint256 _endTimestamp
    ) external returns (address);

    function setOwner(address _newOwner) external;
}
