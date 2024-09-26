const { buildModule } = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers } = require("hardhat");

module.exports = buildModule("FactoryFrenzy", (m) => {
    // Step 1: Deploy the Prodex Token contract with an initial supply of 1 million tokens
    const initialSupply = ethers.parseUnits("1000000", 18);
    const prodexToken = m.contract("ProdexToken", [initialSupply]);

    // Step 2: Deploy the FactoryFrenzy contract with the Prodex Token's address
    const factoryFrenzy = m.contract("FactoryFrenzy", [prodexToken]);

    return { prodexToken, factoryFrenzy };
});
