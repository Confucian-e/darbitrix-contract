// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IERC20} from "@balancer-labs/v2-interfaces/contracts/solidity-utils/openzeppelin/IERC20.sol";

error InvalidCaller(address caller);
error CallFailed(address target, bytes callData, bytes reason);
error LengthNotMatch(uint256 length1, uint256 length2);

struct Call {
    address target;
    bytes callData;
}

interface IArbitrage {
    event Profit(
        address indexed account,
        address indexed token,
        uint256 balance
    );

    function makeFlashLoan(
        IERC20[] calldata tokens,
        uint256[] calldata amounts,
        bytes calldata userData
    ) external;
}
