const {buildModule} = require("@nomicfoundation/hardhat-ignition/modules");

module.exports = buildModule("FactoryA", (m) => {
    const factoryA = m.contract("FactoryFrenzy",[]);
    m.call(factoryA, "initialize", [5]);
    return {factoryA};
})
