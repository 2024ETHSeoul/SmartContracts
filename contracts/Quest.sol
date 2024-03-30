//SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.20;

import {IEscrow} from "./interfaces/IEscrow.sol";
import {Clones} from "@openzeppelin/contracts/proxy/Clones.sol";
import {IQuest} from "./interfaces/IQuest.sol";
import {ITavern} from "./interfaces/ITavern.sol";
import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

/**
 * @title Quest Implementation
 * @notice Controls the quest flow
 * @author @cosmodude
 * @dev Implementation contract, instances are created as ERC1167 clones
 */

contract Quest is IQuest {
    using SafeERC20 for IERC20;

    // state variables
    bool public initialized;
    bool public started;
    bool public extendedOnce;
    bool public extendedTwice;
    bool public extendedThrice;
    bool public beingDisputed;
    bool public finished;
    bool public rewarded;
    bool public withToken;

    address public escrowImplementation; // native or with token
    address public seeker;
    address public solver;
    address public mediator;
    string public infoURI;

    address public token;

    uint256 public paymentAmount;
    uint256 public rewardTime;

    ITavern private tavern;

    address private escrow;

    modifier onlySeeker () {
        require(seeker == msg.sender, "only Seeker");
        _;
    }

    modifier onlySolver () {
        require(solver == msg.sender, "only Solver");
        _;
    }

    modifier onlyMediator() {
        require(msg.sender == mediator, "only mediator");
        _;
    }

    function initialize(
        address _seeker,
        address _solver,
        uint256 _paymentAmount,
        string memory _infoURI,
        address _escrowImplementation,
        address _token
    ) external {
        tavern = ITavern(msg.sender);
        require(!initialized, "Already Initialized");
        initialized = true;

        token = _token;
        escrowImplementation = _escrowImplementation;

        seeker = _seeker;
        solver = _solver;

        paymentAmount = _paymentAmount;

        infoURI = _infoURI;
    }

    function startQuest() external payable {
        require(initialized, "not initialized");
        require(!started, "already started");

        started = true;
        escrow = Clones.clone(escrowImplementation);
        
    }

    /**
     * @dev ERC20 Tokens should be approved on rewarder
     */
    function startDispute() external payable {
        require(started, "quest not started");
        require(!beingDisputed, "Dispute started before");
        require(!rewarded, "Rewarded before");
        beingDisputed = true;
        mediator = tavern.mediator();
        if (token == address(0)) {
            IEscrow(escrow).processStartDispute{value: msg.value}();
        } else {
            require(msg.value == 0, "Native token sent");
            IEscrow(escrow).processStartDispute{value: 0}();
        }
    }

    function resolveDispute(uint32 solverShare) external onlyMediator {
        require(beingDisputed, "Dispute not started");
        require(!rewarded, "Rewarded before");
        require(solverShare <= 10000, "Share can't be more than 10000");
        rewarded = true;
        IEscrow(escrow).processResolution(solverShare);
    }

    function finishQuest() external   {
        require(started, "quest not started");

        finished = true;
        rewardTime = block.timestamp + tavern.reviewPeriod();
    }

    function extend() external {
        require(finished, "Quest not finished");
        require(!extendedThrice, "Max extensions number reached");
        require(!rewarded, "Was rewarded before");
        if(extendedOnce){
            extendedTwice = true;
        } 
        else if (extendedTwice){
            extendedThrice = true;
        }
        else{extendedOnce = true;}

        rewardTime += tavern.reviewPeriod();
    }

    function receiveReward() external   {
        require(finished, "Quest not finished");
        require(!rewarded, "Rewarded before");
        require(!beingDisputed, "Is under dispute");
        require(rewardTime <= block.timestamp, "Not reward time yet");
        rewarded = true;
        IEscrow(escrow).processPayment();
    }

}
