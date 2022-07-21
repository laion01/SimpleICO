// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract LuxuryShares is ERC20, ERC20Burnable, Ownable {
    
    /**
     * @dev Set the max supply
     */
    uint256 private _maxSupply = 700000000 * 10 ** decimals();

    constructor() ERC20("Maharmeh", "MRM") {
        /**
         * @dev Set the premint amount
         */
        _mint(msg.sender, 700000000 * 10 ** decimals());
    }

    /**
     * @dev Returns max supply of the token.
     */
     function getMaxSupply() public view returns (uint256) {
         return _maxSupply;
     }

    /**
     * @dev Only the owner will be able to mint tokens and ensures
     * total supply doesn't go beyond the max supply
     */
     function mint(address to, uint256 amount) public onlyOwner {
         /**
          * @dev Total Spply + Mint Amount should not exceed Max Supply
          */
         require(totalSupply() + amount <= getMaxSupply(), "Max Supply Exceeded");
         _mint(to, amount);
     }
}