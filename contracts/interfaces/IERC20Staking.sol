// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

interface IERC20Staking {
    function stake(uint _amount, uint256 _duration) external;

    function withdraw(uint _userStakeIndex) external;
}
