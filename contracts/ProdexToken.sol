// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title GameToken
 * @dev Custom ERC20 Token for the game, mintable by the owner.
 */
contract ProdexToken is ERC20, Ownable {
    /**
     * @dev Constructor that gives msg.sender (owner) the initial supply of tokens
     * and sets the name and symbol of the token.
     */
    constructor(uint256 initialSupply) ERC20("Prodex", "PDX") Ownable(msg.sender){
        _mint(msg.sender, initialSupply);
    }

    /**
     * @dev Mint new tokens. Only the contract owner can call this function.
     * @param to The address to receive the minted tokens.
     * @param amount The amount of tokens to mint.
     */
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
