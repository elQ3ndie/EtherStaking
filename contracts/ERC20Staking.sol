// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract ERC20Staking {
    address public owner;
    address public tokenAddress;

    //Interest Rate of 10%
    uint8 constant RATE = 10;

    struct Stake {
        address user;
        uint256 amountStaked;
        uint256 duration;
        uint256 startTime;
        uint256 reward;
        bool isComplete;
    }

    mapping(address => Stake[]) userStakes;

    constructor(address _tokenAddress) {
        owner = msg.sender;
        tokenAddress = _tokenAddress;
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

    function stake(uint _amount, uint256 _duration) external {
        require(msg.sender != address(0), "Address zero detected");
        require(_amount > 0, "Amount must be greater than zero");
        require(_duration >= 30, "Minimum staking period is 30 days");
        require(_duration <= 365, "Maximum staking period is 365 days");
        require(
            IERC20(tokenAddress).balanceOf(msg.sender) >= _amount,
            "Insufficient funds"
        );

        bool success = IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "Token transfer failed");

        //Interest is calculated as Principal x Rate x Time(in years) /100
        uint256 _reward = (_amount * RATE * _duration * 1e18) /
            (100 * 365 * 1e18);

        Stake memory newStake;
        newStake.user = msg.sender;
        newStake.amountStaked = _amount;
        newStake.duration = _duration;
        newStake.startTime = block.timestamp;
        newStake.reward = _reward;
        newStake.isComplete = false;

        userStakes[msg.sender].push(newStake);

        emit StakeCreated(msg.sender, _amount, _duration, _reward);
    }

    function withdraw(uint _userStakeIndex) external {
        require(msg.sender != address(0), "Address zero detected");
        require(
            _userStakeIndex < userStakes[msg.sender].length,
            "Stake doesn't exist"
        );

        Stake storage userStake = userStakes[msg.sender][_userStakeIndex];
        require(!userStake.isComplete, "Stake already completed");

        uint256 stakingEndTime = userStake.startTime +
            userStake.duration *
            1 days;
        require(
            block.timestamp >= stakingEndTime,
            "Staking period is not yet over"
        );

        uint256 totalAmount = userStake.amountStaked + userStake.reward;

        userStake.isComplete = true;

        bool success = IERC20(tokenAddress).transfer(msg.sender, totalAmount);
        require(success, "Transaction failed");

        emit StakeWithdrawn(
            msg.sender,
            userStake.amountStaked,
            userStake.reward,
            totalAmount
        );
    }
}
