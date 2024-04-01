// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

error InvalidPairs(address pair0, address pair1);
error InvalidPairToken(address pair, address token);

interface ICalculation {
    function calculateProfit(
        address pair0,
        address pair1,
        address tokenIn,
        uint256 amountIn
    ) external returns (uint256);
}
