import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const EtherStakingModule = buildModule("EtherStakingModule", (m) => {

    const etherstaking = m.contract("EtherStaking");

    return { etherstaking };
});

export default EtherStakingModule;