const { Web3, Contract } = require('web3');  // Import Web3 and Contract from web3 in v4

let addressProdexToken = require('../ignition/deployments/chain-1337/deployed_addresses.json')["ProdexModule#ProdexToken"]// Ensure token address is a string
let addressFactory = require('../ignition/deployments/chain-1337/deployed_addresses.json')["FactoryFrenzy#FactoryFrenzy"]// Ensure factory address is a string

let abiFactoryFrenzy = require('../ignition/deployments/chain-1337/artifacts/FactoryFrenzy#FactoryFrenzy.json').abi// Ensure factory ABI is a string
let abiProdexToken = require('../ignition/deployments/chain-1337/artifacts/ProdexModule#ProdexToken.json').abi// Ensure token ABI is a string


// Initialize the Web3 provider using localhost (Hardhat or Ganache)
const web3 = new Web3('http://127.0.0.1:8545');

const account = web3.eth.accounts.privateKeyToAccount("0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d");
web3.eth.accounts.wallet.add(account);

const contractProdexToken = new Contract(abiProdexToken, addressProdexToken, web3);
const contractFactoryFrenzy = new Contract(abiFactoryFrenzy, addressFactory, web3);

//Get job reward for A1
async function run() {
    //Initialise the contract
    // await contractFactoryFrenzy.methods.initialize(5).send({from: account.address,});

    let jobReward = await contractFactoryFrenzy.methods.getJobReward(0).call();
    console.log("Job Reward for 0 ", jobReward.toString());
    // //Collect reward for A1
    let receipt = await contractFactoryFrenzy.methods.collectJob(0).send({from: account.address,});
}

run();
