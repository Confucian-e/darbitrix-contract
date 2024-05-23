import { ethers } from "hardhat";

async function deploy(name: string, symbol: string) {
  const Token = await ethers.deployContract("MyToken", [name, symbol]);
  const token = await Token.waitForDeployment();
  console.log(`${name} deployed to: ${token.target}`);
}

async function main() {
  await deploy("TokenA", "TA");
  await deploy("TokenB", "TB");
}

main()
  .then(() => process.exit(0))
  .catch((err) => {
    console.error(err);
    process.exit(1);
  });
