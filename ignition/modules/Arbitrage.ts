import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const vault = "0xBA12222222228d8Ba445958a75a0704d566BF2C8";

const ArbitrageModule = buildModule("ArbitrageModule", (m) => {
  const vault_address = m.getParameter("vault", vault);

  const arbitrage = m.contract("Arbitrage", [vault_address]);

  return { arbitrage };
});

export default ArbitrageModule;
