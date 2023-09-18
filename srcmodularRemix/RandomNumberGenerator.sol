// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract RandomNumberGenerator is VRFConsumerBaseV2 {
    
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;
    uint256 private immutable i_mintFee;

    mapping(uint256 => address) public s_requestIdToSender;
    mapping(uint256 => uint256) public s_requestIdToKnight;
    mapping(uint256 => uint256) public s_requestIdToShield;

    event RandomNumberRequested(uint256 requestId);
    event RandomNumberFulfilled(uint256 requestId, uint256 randomNumber);

    constructor(
        address vrfCoordinatorV2,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit,
        uint256 initialMintFee
    ) 
        VRFConsumerBaseV2(vrfCoordinatorV2)
    {
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinatorV2);
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_mintFee = initialMintFee;
    }

    function requestRandomNumber() public payable returns (uint256 requestId) {
        require(
            msg.value >= i_mintFee,
            "Not enough ETH to fulfill the request"
        );
        requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );
        emit RandomNumberRequested(requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] memory randomWords)
        internal
        override
    {
        uint256 randomResult = randomWords[0];
        emit RandomNumberFulfilled(requestId, randomResult);
    }
}
