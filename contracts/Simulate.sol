// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IUniswapV2Pair} from "./interface/IUniswapV2Pair.sol";
import {UniswapV2Library} from "./libraries/UniswapV2Library.sol";

error InvalidPairs(address pair0, address pair1);
error InvalidPairToken(address pair, address token);

contract Simulate {
    /**
     * @dev Simulates a trade between two Uniswap pairs and calculates the profit.
     * @param pair0 The address of the first Uniswap pair.
     * @param pair1 The address of the second Uniswap pair.
     * @param tokenIn The address of the input token.
     * @param amountIn The amount of input token to trade.
     * @return profit The calculated profit from the trade.
     */
    function simulate(
        address pair0,
        address pair1,
        address tokenIn,
        uint256 amountIn
    ) public view returns (uint256 profit) {
        /// @dev Check if the pairs have the same token0 and token1
        if (
            IUniswapV2Pair(pair0).token0() != IUniswapV2Pair(pair1).token0() ||
            IUniswapV2Pair(pair0).token1() != IUniswapV2Pair(pair1).token1()
        ) {
            revert InvalidPairs(pair0, pair1);
        }

        (uint112 pair0_reserve0, uint112 pair0_reserve1, ) = IUniswapV2Pair(
            pair0
        ).getReserves();
        (uint112 pair1_reserve0, uint112 pair1_reserve1, ) = IUniswapV2Pair(
            pair1
        ).getReserves();

        uint256 amountOut;
        uint256 amountFinal;

        address token0 = IUniswapV2Pair(pair0).token0();

        if (token0 == tokenIn) {
            amountOut = UniswapV2Library.getAmountOut(
                amountIn,
                reserve0,
                reserve1
            ); // token1 is the output token
            amountFinal = UniswapV2Library.getAmountOut(
                amountOut,
                pair1_reserve1,
                pair1_reserve0
            );
        } else if (token1 == tokenIn) {
            amountOut = UniswapV2Library.getAmountOut(
                amountIn,
                reserve1,
                reserve0
            ); // token0 is the output token
            amountFinal = UniswapV2Library.getAmountOut(
                amountOut,
                pair1_reserve0,
                pair1_reserve1
            );
        } else {
            revert InvalidPairToken(pair0, tokenIn);
        }

        profit = amountFinal > amountIn ? amountFinal - amountIn : 0;
    }
}
