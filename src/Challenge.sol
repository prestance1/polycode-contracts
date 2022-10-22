pragma solidity ^0.8.13;
import {ERC20} from "solmate/tokens/ERC20.sol";

//TODO IMPLEMENT ICHALLENGE INTERFACE
contract Challenge {
    
    uint256 public immutable challengeId;
    address public immutable rewardToken;
    uint256 public immutable eligibilityAmount;
    
    mapping(address => bool) public isEligible;
    
    uint256 public immutable beginTimestamp;
    uint256 public immutable endTimestamp;
    
    address public winner;
    bool public isClaimed; 

    error ChallengeExpired();
    error ChallengeNotActive();
    error UneligibleToClaim();
    error RewardAlreadyClaimed();
    error InsufficientBalance();
    error AlreadySubscribed();
    error SubscriptionPeriodOver();
    error DidNotSubscribe();
    error NotWinner();

    event Deposit(address indexed candidate, uint amount);
    event Withdraw(address indexed candidate, uint amount);
    event RewardClaimed();
    event ChallengeCompleted(address indexed winner, uint rewardAmount);
    constructor(
        uint256 _challengId,
        address _rewardToken,
        uint256 _beginTimestamp,
        uint256 _endTimestamp,
        uint256 _eligibilityAmount
        ) {
            challengeId = _challengId;
            rewardToken = _rewardToken;
            beginTimestamp = _beginTimestamp;
            endTimestamp = _endTimestamp;
            eligibilityAmount = _eligibilityAmount;

        }
    
    modifier activeLock() {
        if(block.timestamp < beginTimestamp || block.timestamp > endTimestamp) revert ChallengeNotActive();
        _;
    }

    modifier checkEligibility() {
        if(!isEligible[msg.sender]) revert UneligibleToClaim();
        _;
    }

    modifier checkExpiry() {
        if(block.timestamp > endTimestamp) revert ChallengeExpired();
        _;
    }

    modifier checkClaimed() {
        if( isClaimed ) revert RewardAlreadyClaimed();
        _;
    }

    function subscribe() external {
        if (block.timestamp > beginTimestamp) revert SubscriptionPeriodOver();
        if (isEligible[msg.sender]) revert AlreadySubscribed();
        ERC20(rewardToken).transferFrom(msg.sender, address(this), eligibilityAmount);
        isEligible[msg.sender] = true;
        emit Deposit(msg.sender, eligibilityAmount);
    }

    function withdraw() external {
        if(!isEligible[msg.sender]) revert DidNotSubscribe();
        isEligible[msg.sender] = false;
        ERC20(rewardToken).transfer(msg.sender, eligibilityAmount);
        emit Withdraw(msg.sender, eligibilityAmount);
    }

    // function claimReward() external {
    //     //dont need to check timestamp because address can only be set during active time
    //     if (msg.sender != winner) revert NotWinner();
    //     ERC20()
    // }






}