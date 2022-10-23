pragma solidity ^0.8.13;

import {ERC20} from "openzeppelin-contracts/token/ERC20/ERC20.sol";
import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";

import {ERC20Burnable} from "openzeppelin-contracts/token/ERC20/extensions/ERC20Burnable.sol";

//TODO IMPLEMENT ICHALLENGE INTERFACE
contract DemoChallenge {
    //----------------------------
    //IMMUTABLE VARIABLES
    //----------------------------

    ///@notice unique ID of the coding challenge
    uint256 public immutable challengeId;
    ///@notice of the given challenge
    string public challengeName;
    ///@notice address of the contract of the token to be rewarded
    //TODO: might wanna just deploy token contract first and then just make this a constant
    address constant PLC = 0x9b53c5A7a5a1C1A38401A11F51a223d3f17BCf03;
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
    ///@notice addresses of the particpants
    address[] public participants;
    ///@notice number of participants that are subscribed;
    uint80 public numberOfSubscribers;
    ///@notice address of the winner of the challenge
    address public winner;
    ///@notice flag that indicates whether or not someone has already won the challenge
    bool public isCompleted;
    ///@notice flag that indicates whether or not
    bool public isClaimed;
    ///@notice admin address that sets owner
    address public owner;

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

    event Subscription(address indexed candidate, uint256 amount);
    event Unsubscription(address indexed candidate, uint256 amount);
    event RewardClaimed();
    event ChallengeCompleted(address indexed winner, uint256 rewardAmount);

    constructor(
        uint256 _challengId,
        string memory _challengeName,
        uint256 _beginTimestamp,
        uint256 _endTimestamp,
        uint256 _depositAmount,
        address _owner
    ) {
        challengeId = _challengId;
        challengeName = _challengeName;
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
        // if (msg.sender != owner) revert Unauthorised(msg.sender);
        _;
    }

    modifier activeLock() {
        // if (!isActive()) revert ChallengeNotActive();
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
        // if (block.timestamp > beginTimestamp) revert SubscriptionPeriodOver();
        if (isSubscribed[msg.sender]) revert AlreadySubscribed();
        //TODO: ask for approval to authorise the contract to transfer token on its behalf
        IERC20(PLC).transferFrom(msg.sender, address(this), depositAmount);
        isSubscribed[msg.sender] = true;
        unchecked {
            numberOfSubscribers++;
        }
        participants.push(msg.sender);

        emit Subscription(msg.sender, depositAmount);
    }

    function unsubscribe() external checkEligibility {
        isSubscribed[msg.sender] = false;
        unchecked {
            numberOfSubscribers--;
        }
        IERC20(PLC).transfer(msg.sender, depositAmount);
        emit Unsubscription(msg.sender, depositAmount);
    }

    function claimReward() external {
        //dont need to check timestamp because address can only be set during active time
        if (msg.sender != winner) revert NotWinner();
        if (isClaimed) revert AlreadyClaimed();
        uint256 prizePool = ERC20(PLC).balanceOf(address(this));
        IERC20(PLC).transfer(msg.sender, prizePool);
        isClaimed = true;
        emit RewardClaimed();
    }

    function getParticipants() external view returns (address[] memory) {
        return participants;
    }
    //----------------------------
    //CONVENIENCE FUNCTIONS
    //----------------------------

    function currentPrizePool() public view returns (uint256 balance) {
        balance = IERC20(PLC).balanceOf(address(this));
    }

    function isActive() public view returns (bool) {
        return (block.timestamp >= beginTimestamp && block.timestamp <= endTimestamp);
    }

    //----------------------------
    //AUTH FUNCTIONS
    //----------------------------

    function setWinner(address _candidate) external activeLock onlyOwner {
        if (isCompleted) revert AlreadyCompleted();
        if (!isSubscribed[_candidate]) revert Uneligible();
        winner = _candidate;
        isCompleted = true;
        emit ChallengeCompleted(_candidate, IERC20(PLC).balanceOf(address(this)));
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    //TODO: Maybe make it accessible for anyone to enable MEV opportunities, and the researchers gets a cut of the tokens burnt

    function burnPrizePool() external {
        //send cut to MEV researcher
        IERC20(PLC).transfer(msg.sender, currentPrizePool() / 10);
        //burn the rest
        ERC20Burnable(PLC).burn(currentPrizePool());
    }
}
