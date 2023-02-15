// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");

const { hexStripZeros } = require("ethers/lib/utils")

const main = async()=> {
  try {
    const nftContractFactory = await hre.ethers.getContractFactory("starling")
    const nftContract = await nftContractFactory.deploy();
    await nftContract.deployed();
    
    console.log("Contract Deployed to:", nftContract.address);
    process.exit(0);
  } catch (ex) {
    console.log(ex)
    process.exit(1)
  }

}
main();