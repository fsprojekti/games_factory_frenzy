const {buildModule} = require("@nomicfoundation/hardhat-ignition/modules");
const { ethers } = require("hardhat");

module.exports = buildModule("ProdexModule", (m) => {
    const initialSupply =  ethers.parseUnits("1000000", 18);
    const prodexToken = m.contract("ProdexToken", [initialSupply]);
    return {prodexToken};
})
