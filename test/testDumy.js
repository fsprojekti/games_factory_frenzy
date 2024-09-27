const { Web3, Contract } = require('web3');  // Import Web3 and Contract from web3 in v4

let addressToken = '0xBc0256e34B46C7Cf4FC4c30694f1D775e8A16185';  // Ensure token address is a string

let abi = require('@openzeppelin/contracts/build/contracts/ERC20.json').abi;  // Use the correct path for ABI

// Initialize the Web3 provider using the Alchemy URL
const web3 = new Web3(new Web3.providers.HttpProvider('https://eth-sepolia.g.alchemy.com/v2/gT14Jy5OZf7GFW26jyJag-2PPQVN_81t'));

// Create a contract instance using the ABI and address
const contractToken = new Contract(abi, addressToken, web3);  // Use Contract directly from web3

console.log('Contract initialized:', contractToken.options.address);

//Get symbol of the token
contractToken.methods.symbol().call().then(console.log);

//Get balance of an address 0x81875ed62AAEFE32b37671709B182e07C669C907
contractToken.methods.balanceOf('0x81875ed62AAEFE32b37671709B182e07C669C907').call().then(console.log);
