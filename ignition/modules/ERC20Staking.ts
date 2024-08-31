import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const tokenAddress = "0xc0229854296dcBFe38c25A086B13F8C88EbFB5B4";

const IERC20StakingModule = buildModule("IERC20StakingModule", (m) => {

    const staking = m.contract("IERC20Staking", [tokenAddress]);

    return { staking };
});

export default IERC20StakingModule;