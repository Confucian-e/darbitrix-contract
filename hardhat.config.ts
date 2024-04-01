import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
  networks: {
    localhost: {
      url: "http://localhost:8545",
    },
  },
  abiExporter: {
    path: "./abi",
    runOnCompile: true,
    only: ["IArbitrage", "ICalculation"],
    format: "json",
  },
};

export default config;
