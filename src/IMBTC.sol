// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;


import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IERC777 {
    function tokensToSend(address operator, address from, address to, uint256 amount, bytes memory userData, bytes memory operatorData) external;
    function tokensReceived(address operator, address from, address to, uint256 amount, bytes memory userData, bytes memory operatorData) external;
    function getInterfaceImplementer() external pure returns (bool);
}


contract IMBTC is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) external {
        _mint(account, amount);
    }

    function transfer(address to, uint256 amount) public override returns (bool) {
        
        _callTokensToSend(msg.sender, msg.sender, to, amount, "", "");

        _transfer(_msgSender(), to, amount);

        // _callTokensReceived(msg.sender, msg.sender, to, amount, "", "");
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override returns (bool) {
        _callTokensToSend(msg.sender, from, to, value, "", "");

        _transfer(from, to, value);

        // _callTokensReceived(msg.sender, from, to, value, "", "");
        return true;
    } 


    function _callTokensToSend(address operator, address from, address to, uint256 amount, bytes memory userData, bytes memory operatorData) internal virtual {
        if (IERC777(from).getInterfaceImplementer()) {
            IERC777(from).tokensToSend(operator, from, to, amount, userData, operatorData);
        }
    }

    // function _callTokensReceived(address operator, address from, address to, uint256 amount, bytes memory userData, bytes memory operatorData) internal virtual {
    //     if (true) {
    //         IERC777(to).tokensReceived(operator, from, to, amount, userData, operatorData);
    //     }
    // }
}