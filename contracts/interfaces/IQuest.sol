//SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.20;

interface IQuest {
    function initialize(
        address seeker, 
        address solver, 
        uint256 paymentAmount, 
        string memory infoURI, 
        address escrowImplementation, 
        address token
    ) external;
    
    function startDispute() external payable;
    function resolveDispute(uint32 solverShare) external;
    function finishQuest() external;
    function receiveReward() external;
}