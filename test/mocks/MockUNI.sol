// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockUNI is ERC20 {
    constructor() ERC20("Mock UNI Token", "MUNI") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
