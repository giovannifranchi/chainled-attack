// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

import {ChainLend} from "../src/ChainLend.sol";
import {Attacker} from "../src/Attacker.sol";
import {USDC} from "../src/USDC.sol";
import {IMBTC} from "../src/IMBTC.sol";
import {Script} from "forge-std/Script.sol";

contract DeployContracts is Script {

    function run() public returns(ChainLend, Attacker, USDC, IMBTC) {
        vm.startBroadcast();
        USDC usdc = new USDC();
        IMBTC imbtc = new IMBTC("imbtc", "imbtc");
        ChainLend chainLend = new ChainLend(address(imbtc), address(usdc));
        Attacker attacker = new Attacker(address(chainLend), 3);
        vm.stopBroadcast();
        return (chainLend, attacker, usdc, imbtc);
    }
}