// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

import {IVault} from "@balancer-labs/v2-interfaces/contracts/vault/IVault.sol";
import {IFlashLoanRecipient} from "@balancer-labs/v2-interfaces/contracts/vault/IFlashLoanRecipient.sol";
import {IERC20} from "@balancer-labs/v2-interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

import {IArbitrage, Call, InvalidCaller, CallFailed, LengthNotMatch} from "./interface/IArbitrage.sol";

contract Arbitrage is IArbitrage, Ownable, IFlashLoanRecipient {
    /// @dev Vault address of Balancer
    address public immutable vault;

    constructor(address _vault) Ownable(msg.sender) {
        vault = _vault;
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
    ) external onlyOwner {
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
        if (msg.sender != vault) revert InvalidCaller();

        uint256 len = tokens.length;
        Call[] memory calls = abi.decode(userData, (Call[]));

        // swap tokens
        for (uint256 i = 0; i < len; ++i) {
            execute(calls[i]);
        }

        // pay back
        for (uint256 i = 0; i < len; ++i) {
            tokens[i].transfer(vault, amounts[i] + feeAmounts[i]);
        }
    }

    /**
     * @dev Execute a call
     * @param param Call struct param
     */
    function execute(Call memory param) internal {
        (bool success, ) = param.target.call(param.callData);
        if (!success) revert CallFailed();
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
        if (tokens.length != spenders.length) revert LengthNotMatch();
        uint256 maxUint = type(uint256).max;
        for (uint256 i = 0; i < tokens.length; ++i) {
            tokens[i].approve(spenders[i], maxUint);
        }
    }

    /**
     * @dev Withdraw tokens from contract
     * @param tokens tokens address
     */
    function withdraw(address[] calldata tokens) external onlyOwner {
        address owner = msg.sender;
        for (uint256 i = 0; i < tokens.length; ++i) {
            if (tokens[i] == address(0)) {
                payable(owner).transfer(address(this).balance);
            } else {
                IERC20 token = IERC20(tokens[i]);
                token.transfer(owner, token.balanceOf(address(this)));
            }
        }
    }

    // ======================= Experimental =======================

    /**
     * @dev Delegate call to target
     * @param target targe address
     * @param data calldata to pass
     */
    function delegateCall(
        address target,
        bytes calldata data
    ) external onlyOwner {
        (bool success, ) = target.delegatecall(data);
        if (!success) revert CallFailed();
    }
}
