// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract EtherStaking {
    address owner;

    //Interest Rate of 10%
    uint8 constant RATE = 10;

    struct Stake {
        address user;
        uint256 amountStaked;
        uint256 duration;
        uint256 reward;
        bool isComplete;
    }

    mapping(address => Stake[]) userStakes;

    constructor() payable {
        owner = msg.sender;
    }

    event StakeCreated(
        address indexed user,
        uint256 amount,
        uint256 duration,
        uint256 reward
    );
    event StakeWithdrawn(
        address indexed user,
        uint256 amount,
        uint256 reward,
        uint totalAmount
    );

    function stake(uint256 _duration) external payable {
        require(msg.sender != address(0), "Address zero detected");
        require(msg.value > 0, "Amount must be greater than zero");
        require(_duration >= 30, "Minimum staking period is 30 days");
        require(_duration <= 365, "Maximum staking period is 365 days");

        //Interest is calculated as Principal x Rate x Time(in years) /100
        uint256 _reward = (msg.value * RATE * _duration * 1e18) /
            (100 * 365 * 1e18);

        Stake memory newStake;
        newStake.user = msg.sender;
        newStake.amountStaked = msg.value;
        newStake.duration = _duration;
        newStake.reward = _reward;
        newStake.isComplete = false;

        userStakes[msg.sender].push(newStake);

        emit StakeCreated(msg.sender, msg.value, _duration, _reward);
    }

    function withdraw(uint _userStakeIndex) external {
        require(msg.sender != address(0), "Address zero detected");
        require(
            _userStakeIndex < userStakes[msg.sender].length,
            "Stake doesn't exist"
        );

        Stake storage userStake = userStakes[msg.sender][_userStakeIndex];
        require(!userStake.isComplete, "Stake already completed");

        uint256 stakingEndTime = userStakes[msg.sender][_userStakeIndex]
            .duration *
            1 days +
            block.timestamp;
        require(
            block.timestamp >= stakingEndTime,
            "Staking period is not yet over"
        );

        uint256 totalAmount = userStake.amountStaked + userStake.reward;

        userStake.isComplete = true;

        (bool success, ) = payable(msg.sender).call{value: totalAmount}("");
        require(success, "Transaction failed");

        emit StakeWithdrawn(
            msg.sender,
            userStake.amountStaked,
            userStake.reward,
            totalAmount
        );
    }
}
