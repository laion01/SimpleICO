const hre = require("hardhat");
require("color");

async function main() {

  const ERC20 = await hre.ethers.getContractFactory("Full_ERC20");
  const erc20 = await ERC20.deploy("CryptoWarriors", "CWS", "1000000000000000000000000");
  await erc20.deployed();
  console.log("Token Address:", erc20.address);

  var releaseTime = Math.floor(new Date().getTime()/1000) + 3600 * 24 * 30;

  const ERC20_ICO = await hre.ethers.getContractFactory("ERC20_ICO");
  const ico = await ERC20_ICO.deploy(erc20.address, "0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684", releaseTime);
  await ico.deployed();
  console.log("ERC20-ICO Address:", ico.address);

  await erc20.setICOAddress(ico.address);
  await erc20.transfer(ico.address, "1000000000000000000000000");
  await ico.setToken(erc20.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
