import { ethers } from "hardhat";

async function main() {
    const myTokenAddress = "0xc0229854296dcBFe38c25A086B13F8C88EbFB5B4";
    const myToken = await ethers.getContractAt("IERC20", myTokenAddress);

    const ERC20StakingContractAddress = "0xAbd5a36ce5f8Ad74E668Cf8219c27a4F958004c7";
    const ERC20Staking = await ethers.getContractAt("ISaveERC20", ERC20StakingContractAddress);

    // Approve savings contract to spend token
    const approvalAmount = ethers.parseUnits("1000", 18);

    const approveTx = await myToken.approve(ERC20Staking, approvalAmount);
    approveTx.wait();

    const contractBalanceBeforeDeposit = await ERC20Staking.getContractBalance();
    console.log("Contract balance before :::", contractBalanceBeforeDeposit);

    const stakeAmount = ethers.parseUnits("150", 18);
    const depositTx = await ERC20Staking.stake(stakeAmount);

    console.log(depositTx);

    depositTx.wait();

    const contractBalanceAfterDeposit = await ERC20Staking.getContractBalance();

    console.log("Contract balance after :::", contractBalanceAfterDeposit);



    // Withdrawal Interaction

    const withDrawAmount = ethers.parseUnits("15", 18);
    const withDrawTx = await ERC20Staking.withdraw(withDrawAmount);

    console.log(withDrawTx);

    withDrawTx.wait();

    const contractBalanceAfterWithdrawal = await ERC20Staking.getContractBalance();
    console.log("Contract balance after :::", contractBalanceAfterWithdrawal)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});
