// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IERC20.sol";
import "./SafeERC20.sol";
import "hardhat/console.sol";

/*===================================================
    OpenZeppelin Contracts (last updated v4.5.0)
=====================================================*/

contract ERC20_ICO is Ownable {
    using SafeERC20 for IERC20;

    // IYA token
    IERC20 private baseToken;
    IERC20 private usdtToken;

    // time to start claim.
    uint256 public releaseTime = 0; // Thu Apr 14 2022 00:00:00 UTC

    // wallet to withdraw
    address public wallet;

    // presale and airdrop program with refferals
    uint256 private salePrice = 10000000000000000000; //  token for 0.01 bnb (set as per requirements)

    /**
     * @dev Initialize with token address and round information.
     */
    constructor (address _baseToken, address _usdtToken, uint256 _releaseTime) Ownable() {
        wallet = msg.sender;
        baseToken = IERC20(_baseToken);
        usdtToken = IERC20(_usdtToken);
        releaseTime = _releaseTime;
    }
    
    receive() payable external {}
    fallback() payable external {}

    function setToken(address _baseToken) public onlyOwner {
        require(_baseToken != address(0), "presale-err: invalid address");
        baseToken = IERC20(_baseToken);
    }

    /**
     * @dev ICO Endtime.
     */
    function setReleaseTime(uint256 endtime) public onlyOwner {
        releaseTime = endtime;
    }

    /**
     * @dev Withdraw  baseToken token from this contract.
     */
    function withdrawTokens(address _token) external onlyOwner {
        if(_token == address(0)) {
            payable(wallet).transfer(address(this).balance);
        } else {
            IERC20(_token).safeTransfer(wallet, IERC20(_token).balanceOf(address(this)));
        }
    }

    /**
     * @dev Set wallet to withdraw.
     */
    function setWalletReceiver(address _newWallet) external onlyOwner {
        wallet = _newWallet;
    }

    function buy(uint256 usdtAmount) public returns (bool) {
        require(block.timestamp <= releaseTime && usdtAmount >= 0 ether, "Transaction recovery");
        uint256 _msgValue = usdtAmount;
        uint256 _token = _msgValue * salePrice / ( 10 ** 18 );
        baseToken.safeTransfer(msg.sender, _token);
        usdtToken.safeTransferFrom(msg.sender, address(this), usdtAmount);
        return true;
    }
}