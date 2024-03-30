// SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.20;

import "./interfaces/IQuest.sol";
import { Clones } from "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { ITavern } from "./interfaces/ITavern.sol";

/**
 * @title Quest Factory (Tavern)
 * @notice Deploys Quest Contracts and manages them
 * @author @cosmodude
 */

contract Tavern is ITavern {
    using SafeERC20 for IERC20;
    
    address public owner;
    address private _barkeeper;
    address public escrowNativeImplementation; // for native blockchain tokens
    address public questImplementation;
    address public mediator; // for disputes
    uint256 public reviewPeriod = 1;

    modifier onlyBarkeeper() {
        require(msg.sender == _barkeeper, "only barkeeper");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    constructor(
        address _questImplementation,
        address _escrowNativeImplementation
    ) {
        escrowNativeImplementation = _escrowNativeImplementation;
        questImplementation = _questImplementation;
        owner = msg.sender;
    }

    /**
     * @notice Function to create quests with Native token payments
     * @param _seekerId Nft id of the seeker of the quest
     * @param _solverId Nft id of the solver of the quest
     * @param _paymentAmount Amount of Native tokens to be paid
     * @param infoURI Link to the info a bout quest (flexible, decide with backend)
     */
    function createNewQuest(
        // user identifiers
        uint32 _seekerId,
        uint32 _solverId,
        uint256 _paymentAmount,
        string memory infoURI
    ) external payable {
        IQuest quest = IQuest(Clones.clone(questImplementation));
        address escrowImpl = escrowNativeImplementation;
   
        emit QuestCreatedNative(
            _seekerId, 
            _solverId, 
            address(quest), 
            escrowImpl, 
            _paymentAmount
        );

        quest.initialize(
            msg.sender,
            msg.sender,
            _paymentAmount,
            infoURI,
            escrowImpl,
            address(0)
        );
    }

    
    // in case of backend problem
    function setBarkeeper(address keeper) external onlyOwner {
        _barkeeper = keeper;
    }

    function setQuestImplementation(address impl) external onlyOwner {
        questImplementation = impl;
    }

    function setEscrowNativeImplementation(address impl) external onlyOwner {
        escrowNativeImplementation = impl;
    }
    function setMediator(address _mediator) external onlyOwner {
        mediator = _mediator;
    }

    function setReviewPeriod(uint256 period) external onlyOwner {
        reviewPeriod = period;
    }

    function getBarkeeper() external view onlyOwner returns (address) {
        return _barkeeper;
    }

    function recoverTokens(
        address _token,
        address benefactor
    ) public onlyOwner {
        if (_token == address(0)) {
            (bool sent, ) = payable(benefactor).call{
                value: address(this).balance
            }("");
            require(sent, "Send error");
            return;
        }
        uint256 tokenBalance = IERC20(_token).balanceOf(address(this));
        IERC20(_token).transfer(benefactor, tokenBalance);
        return;
    }
}