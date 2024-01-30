// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ChainLend} from "../src/ChainLend.sol";
import {Attacker} from "../src/Attacker.sol";
import {USDC} from "../src/USDC.sol";
import {IMBTC} from "../src/IMBTC.sol";
import {Test, console} from "forge-std/Test.sol";
import {DeployContracts} from "../script/DeployContracts.s.sol";


contract AttackerTest is Test {

    ChainLend private chainLend;
    Attacker private attacker;
    USDC private usdc;
    IMBTC private imbtc;
    address private s_user = makeAddr("user");

    function setUp() public {
        DeployContracts deployContracts = new DeployContracts();
        (chainLend, attacker, usdc, imbtc) = deployContracts.run();
        imbtc.mint(address(attacker), 10);
        imbtc.mint(address(chainLend), 200);
    }

    function testDiscrepancy() public {
        vm.prank(s_user);
        attacker.deposit(9);
        attacker.attack();
        console.log("imbtc balance", imbtc.balanceOf(address(attacker)));
        console.log("chainled Balance", chainLend.deposits(address(attacker)));
    }
}
