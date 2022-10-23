
pragma solidity ^0.8.13;

import {DemoChallenge} from "./DemoChallenge.sol";

contract DemoChallengeFactory {
    //----------------------------
    //CONSTANTS
    //----------------------------

    ///@notice address of the token to reward users with
    address constant PLC = 0x9b53c5A7a5a1C1A38401A11F51a223d3f17BCf03;

    //----------------------------
    //STATE VARIABLES
    //----------------------------

    ///@notice maps challenge contracts to ids.
    mapping(address => uint256) public getId;
    ///@notice maps challenge ids to contracts
    mapping(uint256 => address) public getChallenge;
    ///@notice list containing the addresses of all deployed challenges
    address[] public allChallenges;
    ///@notice admin access to the deployer contract
    address public owner;

    //----------------------------
    //EVENTS
    //----------------------------
    event ChallengeDeployed(uint256 indexed challengeId, address indexed challenge);

    //----------------------------
    //ERRORS
    //----------------------------
    error InvalidTimestamp(uint256, uint256);
    error ChallengeAlreadyCreated(address);
    error Unauthorised(address, address);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorised(owner, msg.sender);
        _;
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
    ) internal returns (DemoChallenge challenge) {
        challenge =
        new DemoChallenge{salt: keccak256(abi.encodePacked(_challengeId))}(_challengeId, _challengeName, _beginTimestamp, _endTimestamp, _depositAmount, owner);
    }

    function createChallenge(
        uint256 _challengeId,
        string calldata _challengeName,
        uint256 _depositAmount,
        uint256 _beginTimestamp,
        uint256 _endTimestamp
    ) external onlyOwner returns (address challenge) {
        if (block.timestamp > _beginTimestamp) revert InvalidTimestamp(_beginTimestamp, _endTimestamp);
        if (_endTimestamp < _beginTimestamp) revert InvalidTimestamp(_beginTimestamp, _endTimestamp);
        if (getChallenge[_challengeId] != address(0)) revert ChallengeAlreadyCreated(getChallenge[_challengeId]);
        DemoChallenge challengeContract =
            deployChallenge(_challengeId, _challengeName, _depositAmount, _beginTimestamp, _endTimestamp);
        challenge = address(challengeContract);
        allChallenges.push(challenge);
        getId[challenge] = _challengeId;
        getChallenge[_challengeId] = challenge;

        emit ChallengeDeployed(_challengeId, challenge);
    }

    function setOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
}
