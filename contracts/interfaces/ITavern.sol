//SPDX-License-Identifier: GNU AGPLv3
pragma solidity 0.8.20;

interface ITavern {

    // quests with payments in native token
    event QuestCreatedNative(
        uint32 seekerId,
        uint32 solverId,
        address quest,
        address escrowImplementation,
        uint256 paymentAmount
    );
    
    // quests with token payments
    event QuestCreatedToken(
        uint32 seekerId,
        uint32 solverId,
        address quest,
        address escrowImplementation,
        uint256 paymentAmount,
        address token
    );

    function escrowNativeImplementation() external view returns (address);
    function questImplementation() external view returns (address);
    function reviewPeriod() external view returns (uint256);
    function mediator() external view returns(address);
}