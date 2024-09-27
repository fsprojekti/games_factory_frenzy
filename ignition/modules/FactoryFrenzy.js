const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers } = require("hardhat");

module.exports = buildModule("FactoryFrenzy", (m) => {
    let prodexToken="0xeb8Bc4fdEB7f9A9034b1242f46abd76B32fD4c95";
    // Step 2: Deploy the FactoryFrenzy contract with the Prodex Token's address
    const factoryFrenzy = m.contract("FactoryFrenzy", [prodexToken]);

    return {factoryFrenzy};
});
