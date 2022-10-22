pragma solidity ^0.8.13;

import {ERC20} from "solmate/tokens/ERC20.sol";

//TODO IMPLEMENT ICHALLENGE INTERFACE
contract Challenge {
    //----------------------------
    //IMMUTABLE VARIABLES
    //----------------------------

    ///@notice unique ID of the coding challenge
    uint256 public immutable challengeId;
    ///@notice of the given challenge
    string public challengeName;
    ///@notice address of the contract of the token to be rewarded
    //TODO: might wanna just deploy token contract first and then just make this a constant
    address public immutable rewardToken;
    ///@notice amount of tokens to deposit to be subscribe to the challenge
    uint256 public immutable depositAmount;
    ///@notice timestamp of when the challenge starts in UNIX epochal
    uint256 public immutable beginTimestamp;
    ///@notice timestamp of when the challenge ends in UNIX epochal
    uint256 public immutable endTimestamp;

    //----------------------------
    //STATE VARIABLES
    //----------------------------

    ///@notice indicates whether or not an address is subscribed to the challenge or not
    mapping(address => bool) public isSubscribed;
    ///@notice number of participants that are subscribed;
    uint80 public numberOfSubscribers;
    ///@notice address of the winner of the challenge
    address public winner;
    ///@notice flag that indicates whether or not someone has already won the challenge
    bool public isCompleted;
    ///@notice flag that indicates whether or not
    bool public isClaimed;
    ///@notice admin address that sets owner
    address private owner;

    //----------------------------
    //ERRORS
    //----------------------------
    error ChallengeNotActive();
    error UneligibleToClaim();
    error RewardAlreadyClaimed();
    error InsufficientBalance();
    error AlreadySubscribed();
    error SubscriptionPeriodOver();
    error Uneligible();
    error NotWinner();
    error AlreadyCompleted();
    error AlreadyClaimed();
    error Unauthorised(address);
    //----------------------------
    //EVENTS
    //----------------------------

    event Deposit(address indexed candidate, uint256 amount);
    event Withdraw(address indexed candidate, uint256 amount);
    event RewardClaimed();
    event ChallengeCompleted(address indexed winner, uint256 rewardAmount);

    constructor(
        uint256 _challengId,
        string memory _challengeName,
        address _rewardToken,
        uint256 _beginTimestamp,
        uint256 _endTimestamp,
        uint256 _depositAmount,
        address _owner
    ) {
        challengeId = _challengId;
        challengeName = _challengeName;
        rewardToken = _rewardToken;
        beginTimestamp = _beginTimestamp;
        endTimestamp = _endTimestamp;
        depositAmount = _depositAmount;
        owner = _owner;
    }
    //----------------------------
    //MODIFIERS
    //----------------------------
    //TODO: maybe use solmate's Owned library here

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorised(msg.sender);
        _;
    }

    modifier activeLock() {
        if (block.timestamp < beginTimestamp || block.timestamp > endTimestamp) revert ChallengeNotActive();
        _;
    }

    modifier checkEligibility() {
        if (!isSubscribed[msg.sender]) revert Uneligible();
        _;
    }
    //----------------------------
    //EXTERNAL FUNCTIONS
    //----------------------------

    function subscribe() external {
        if (block.timestamp > beginTimestamp) revert SubscriptionPeriodOver();
        if (isSubscribed[msg.sender]) revert AlreadySubscribed();
        //TODO: ask for approval to authorise the contract to transfer token on its behalf
        ERC20(rewardToken).transferFrom(msg.sender, address(this), depositAmount);
        isSubscribed[msg.sender] = true;
        unchecked {
            numberOfSubscribers++;
        }
        emit Deposit(msg.sender, depositAmount);
    }

    function withdraw() external checkEligibility {
        isSubscribed[msg.sender] = false;
        unchecked {
            numberOfSubscribers--;
        }
        ERC20(rewardToken).transfer(msg.sender, depositAmount);
        emit Withdraw(msg.sender, depositAmount);
    }

    function claimReward() external {
        //dont need to check timestamp because address can only be set during active time
        if (msg.sender != winner) revert NotWinner();
        if (isClaimed) revert AlreadyClaimed();
        uint256 prizePool = ERC20(rewardToken).balanceOf(address(this));
        ERC20(rewardToken).transfer(msg.sender, prizePool);
        isClaimed = true;
        emit RewardClaimed();
    }

    //----------------------------
    //CONVENIENCE FUNCTIONS
    //----------------------------
    function currentPrizePool() external view returns (uint256 balance) {
        balance = ERC20(rewardToken).balanceOf(address(this));
    }

    function isActive() external view returns (bool) {
        return (block.timestamp > beginTimestamp && block.timestamp < endTimestamp);
    }

    //----------------------------
    //AUTH FUNCTIONS
    //----------------------------

    function setWinner(address _candidate) external activeLock onlyOwner {
        if (isCompleted) revert AlreadyCompleted();
        if (!isSubscribed[_candidate]) revert Uneligible();
        winner = _candidate;
        isCompleted = true;
        emit ChallengeCompleted(_candidate, ERC20(rewardToken).balanceOf(address(this)));
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
