// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IVault} from "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import {IFlashLoanRecipient} from "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";
import {IERC20} from "@balancer-labs/v2-interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

import {IArbitrage, Call, InvalidCaller, CallFailed, LengthNotMatch} from "./interface/IArbitrage.sol";

/**
 * @title Arbitrage contract to swap between DEXs using FLashLoan to borrow assets
 * @author Confucian
 * @notice Beta Version
 */
contract Arbitrage is IArbitrage, IFlashLoanRecipient {
    /// @dev Vault address of Balancer
    address public immutable vault;

    /**
     * @dev Constructor function for the Arbitrage contract.
     * @param _vault The address of the vault contract.
     */
    constructor(address _vault) {
        vault = _vault;
    }

    /**
     * @dev approve tokens before making flashloan
     * @param tokens approve tokens
     * @param spenders approve spenders
     */
    function approveTokens(
        IERC20[] calldata tokens,
        address[] calldata spenders
    ) external {
        if (tokens.length != spenders.length)
            revert LengthNotMatch(tokens.length, spenders.length);
        uint256 maxUint = type(uint256).max;
        for (uint256 i = 0; i < tokens.length; ++i) {
            tokens[i].approve(spenders[i], maxUint);
        }
    }

    /**
     * @dev Entrypoint to make flashloan
     * @param tokens Tokens to borrow
     * @param amounts Amounts to borrow
     * @param userData Data to pass to the recipient
     */
    function makeFlashLoan(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata userData
    ) external {
        if (tokens.length != amounts.length)
            revert LengthNotMatch(tokens.length, amounts.length);
        address receipient = address(this);
        IVault(vault).flashLoan(
            IFlashLoanRecipient(receipient),
            tokens,
            amounts,
            userData
        );
    }

    /**
     * @dev Callback function to receive flashloan
     * @param tokens Tokens have been borrowed
     * @param amounts Amounts have been borrowed
     * @param feeAmounts Fees to pay for falshloan
     * @param userData Data user passed
     */
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        if (msg.sender != vault) revert InvalidCaller(msg.sender);

        if (userData.length != 0) {
            Call[] memory calls = abi.decode(userData, (Call[]));
            /// @dev swap tokens
            for (uint256 i = 0; i < calls.length; ++i) {
                execute(calls[i]);
            }
        }

        payback(tokens, amounts, feeAmounts);

        reedem(tokens);
    }

    /**
     * @dev Execute a call
     * @param param Call struct param
     */
    function execute(Call memory param) internal {
        (bool success, bytes memory reason) = param.target.call(param.callData);
        if (!success) revert CallFailed(param.target, param.callData, reason);
    }

    /**
     * @dev Transfers specified amounts of tokens to the vault address.
     * @param tokens An array of ERC20 tokens to transfer.
     * @param amounts An array of amounts to transfer for each token.
     * @param feeAmounts An array of fee amounts to add to each transfer.
     */
    function payback(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts
    ) internal {
        for (uint256 i = 0; i < tokens.length; ++i) {
            tokens[i].transfer(vault, amounts[i] + feeAmounts[i]);
        }
    }

    /**
     * @dev Internal function to redeem tokens.
     * @param tokens An array of ERC20 tokens to redeem.
     */
    function reedem(IERC20[] memory tokens) internal {
        address account = tx.origin;
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                token.transfer(account, balance);
                emit Profit(account, address(token), balance);
            }
        }
    }
}
