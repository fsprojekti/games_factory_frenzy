require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.20",
  networks: {
    hardhat: {
      chainId: 1337 // Optional: setting a custom chain ID for Hardhat Network
    },
    sepolia: {
      url: 'https://sepolia.infura.io/v3/5b5e5c71a5ed48a1bd63956d8e6ccb5e',
      accounts: [require('./.secret.json').privateKey],
    },
    amony:{
      url: 'https://rpc-amoy.polygon.technology/',
      accounts: [require('./.secret.json').privateKey],
    }
  }
};
