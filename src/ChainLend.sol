// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";

contract ChainLend {
    
    // Deposit token is imBTC, borrow token is USDC
    IERC20 public depositToken;
    IERC20 public borrowToken;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public debt;
    
    constructor(address _depositToken, address _borrowToken) {
        depositToken = IERC20(_depositToken);
        borrowToken = IERC20(_borrowToken);
    }

    function deposit(uint256 amount) public {
        uint256 deposited = deposits[msg.sender];
        depositToken.transferFrom(msg.sender, address(this), amount); // @audit - reentrancy chance before _move() on imBTC
        deposits[msg.sender] = deposited + amount;
    }

    // Can only be called if the debt is repayed
    function withdraw(uint256 amount) public {

        uint256 deposited = deposits[msg.sender];
        require(debt[msg.sender] <= 0, "Please clear your debt to Withdraw Collateral");
        require(amount <= deposited, "Withdraw Limit Exceeded");

        deposits[msg.sender] = deposited - amount;
        depositToken.transfer(msg.sender, amount); // @audit - reentrancy chance after _move() on imBTC
    }

    // Assuming correct prices and oracles are in place to calculate the correct borrow limit
    // For smplicity purposes, setting the imBTC oracle price to 20,000 USDC for 1 imBTC.
    function borrow(uint256 amount) public { // @audit-ok - follows CEI pattern but could help attacks
        
        uint256 deposited = deposits[msg.sender];
        uint256 borrowed = debt[msg.sender];
        require(deposited > 0, "You need to deposit before borrowing");

        // BorrowLimit is deposited balance by caller multiplied with the price of imBTC,
        // and then dividing it by 1e8 because USDC decimals is 6 while imBTC is 8
        uint256 borrowLimit = (deposited * 20_000 * 1e6) / 1e8;
        // Finally allowing only 80% of the deposited balance to be borrowed (80% Loan to value)
        borrowLimit =  ((borrowLimit * 80) / 100) - borrowed;
        require(amount <= borrowLimit, "BorrowLimit Exceeded");

        debt[msg.sender] += amount;
        borrowToken.transfer(msg.sender, amount);
    }

    function getInterfaceImplementer() external pure returns (bool){
        return false;
    }

    function repay(uint256 amount) public{ // @audit - doesn't follow CEI pattern but doesn't help any attacks

        require(debt[msg.sender] > 0, "You don't have any debt");
        require(amount <= debt[msg.sender], "Amount to high! You don't have that much debt");

        borrowToken.transferFrom(msg.sender, address(this), amount);
        debt[msg.sender] -= amount;
    }
}