pragma solidity ^0.8.13;
///@title The interface for the challenge contract
///@notice contract responsible for handling token deposits, withdrawal and rewarding for challenge participants

interface IChallenge {
    function challengeId() external view returns (uint256);
    function challengeName() external view returns (string memory);
    function depositAmount() external view returns (uint256);
    function beginTimestamp() external view returns (uint256);
    function endTimestamp() external view returns (uint256);
    function isSubscribed() external view returns (bool);
    function numberOfSubscriber() external view returns (uint80);
    function winner() external view returns (address);
    function isCompleted() external view returns (bool);
    function isClaimed() external view returns (bool);
    function owner() external view returns (address);
    function subscribe() external;
    function withdraw() external;
    function claimReward() external;
    function isActive() external view returns (bool);
    function setWinner(address _candidate) external;
    function setOwner(address _newOwner) external;
    function burnPrizePool() external;
}
