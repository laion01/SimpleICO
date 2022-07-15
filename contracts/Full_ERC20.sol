// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./ERC20Capped.sol";
import "./ERC20Mintable.sol";
import "./ERC20Burnable.sol";
import "./Pancakeswap/IPancakeRouter01.sol";
import "./Pancakeswap/IPancakeFactory.sol";
import "hardhat/console.sol";

/**
 * @title Full_ERC20
 * @dev Implementation of the ERC20
 */

interface IICO { 
    function releaseTime() external view returns (uint256);
}

contract Full_ERC20 is ERC20Capped, ERC20Mintable, ERC20Burnable {
    address public icoAddress = address(0);
    IICO private icoContract;
    uint256 public holderCount;

    constructor (string memory t_name, string memory t_symbol, uint256 t_cap)
        ERC20(t_name, t_symbol)
        ERC20Capped(t_cap)
        payable
    {
        _setupDecimals(18);
        holderCount = 0;
        _mint(msg.sender, t_cap);
    }
    /**
     * @dev Function to mint tokens.
     *
     * NOTE: restricting access to owner only. See {ERC20Mintable-mint}.
     *
     * @param account The address that will receive the minted tokens
     * @param amount The amount of tokens to mint
     */
    function _mint(address account, uint256 amount) internal override(ERC20, ERC20Capped) onlyOwner {
        require(amount > 0, "zero amount");
        uint256 am = balanceOf(account);
        super._mint(account, amount);

        if(am == 0)
            holderCount ++;
    }

    function setICOAddress(address addr) public {
        require(icoAddress == address(0), "Already Set");
        icoAddress = addr;
        icoContract = IICO(addr);
    }

    /**
     * @dev Function to stop minting new tokens.
     *
     * NOTE: restricting access to owner only. See {ERC20Mintable-finishMinting}.
     */
    function _finishMinting() internal override onlyOwner {
        super._finishMinting();
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     * Take transaction fee from sender and transfer fee to the transaction fee wallet.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        if(sender != owner()) {
            require(icoAddress != address(0), "ICO not setup");
            require(icoContract.releaseTime() < block.timestamp, "Transfer locked during ICO");    
        }
        uint256 recipient_amount = balanceOf(recipient);
        super.transferFrom(sender, recipient, amount);

        if(recipient_amount == 0)
            holderCount ++;
        if(balanceOf(sender) == 0)
            holderCount --;
        return true;
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        if(msg.sender != owner()) {
            require(icoAddress != address(0), "ICO not setup");
            require(icoContract.releaseTime() < block.timestamp, "Transfer locked during ICO");    
        }
        
        uint256 recipient_amount = balanceOf(recipient);
        super.transfer(recipient, amount);

        if(recipient_amount == 0)
            holderCount ++;
        if(balanceOf(address(msg.sender)) == 0)
            holderCount --;
        return true;
    }
}