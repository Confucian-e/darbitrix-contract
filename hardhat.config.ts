import { HardhatUserConfig, vars } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-abi-exporter";

const Arbitrum_RPC_URL = vars.get(
  "Arbitrum_RPC_URL",
  "https://arbitrum.drpc.org"
);
const PK = vars.get("PK", "0x");
const ETHERSCAN_API_KEY = vars.get("ETHERSCAN_API_KEY");

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
    arbitrum: {
      url: Arbitrum_RPC_URL,
      accounts: [PK],
    },
  },
  etherscan: {
    apiKey: {
      arbitrumOne: ETHERSCAN_API_KEY,
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
