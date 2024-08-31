import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0xc0229854296dcBFe38c25A086B13F8C88EbFB5B4";

const ERC20StakingModule = buildModule("ERC20StakingModule", (m) => {

    const staking = m.contract("ERC20Staking", [tokenAddress]);

    return { staking };
});

export default ERC20StakingModule;