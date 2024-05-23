import { ethers } from "hardhat";

const vault = "0xBA12222222228d8Ba445958a75a0704d566BF2C8";

async function deploy() {
  const Arbitrage = await ethers.deployContract("Arbitrage", [vault]);
  const arbitrage = await Arbitrage.waitForDeployment();

  console.log(`Arbitrage contract deployed to ${arbitrage.target}`);
}

deploy()
  .then(() => {
    process.exit(0);
  })
  .catch((err) => {
    console.error(err);
  });
