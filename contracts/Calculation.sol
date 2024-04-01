// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Pair} from "./interface/IUniswapV2Pair.sol";
import {UniswapV2Library} from "./libraries/UniswapV2Library.sol";

import {ICalculation, InvalidPairs, InvalidPairToken} from "./interface/ICalculation.sol";

contract Calculation is ICalculation {
    /**
     * @dev Simulates a trade between two Uniswap pairs and calculates the profit.
     * @param pair0 The address of the first Uniswap pair.
     * @param pair1 The address of the second Uniswap pair.
     * @param tokenIn The address of the input token.
     * @param amountIn The amount of input token to trade.
     * @return profit The calculated profit from the trade.
     */
    function calculateProfit(
        address pair0,
        address pair1,
        address tokenIn,
        uint256 amountIn
    ) public view override returns (uint256 profit) {
        address token0 = IUniswapV2Pair(pair0).token0();
        address token1 = IUniswapV2Pair(pair0).token1();

        /// @dev Check if the pairs have the same token0 and token1
        if (
            token0 != IUniswapV2Pair(pair1).token0() ||
            token1 != IUniswapV2Pair(pair1).token1()
        ) revert InvalidPairs(pair0, pair1);

        /// @dev Check if the pair has tokenIn
        if (token0 != tokenIn && token1 != tokenIn)
            revert InvalidPairToken(pair0, tokenIn);

        (uint112 pair0_reserve0, uint112 pair0_reserve1, ) = IUniswapV2Pair(
            pair0
        ).getReserves();
        (uint112 pair1_reserve0, uint112 pair1_reserve1, ) = IUniswapV2Pair(
            pair1
        ).getReserves();

        uint256 amountOut;
        uint256 amountFinal;
        bool isToken0 = token0 == tokenIn;

        (uint256 reserve0, uint256 reserve1) = isToken0
            ? (pair0_reserve0, pair0_reserve1)
            : (pair0_reserve1, pair0_reserve0);

        amountOut = UniswapV2Library.getAmountOut(amountIn, reserve0, reserve1);

        (reserve0, reserve1) = isToken0
            ? (pair1_reserve1, pair1_reserve0)
            : (pair1_reserve0, pair1_reserve1);

        amountFinal = UniswapV2Library.getAmountOut(
            amountOut,
            reserve0,
            reserve1
        );

        profit = amountFinal > amountIn ? amountFinal - amountIn : 0;
    }
}
