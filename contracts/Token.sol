// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC20/ERC20.sol";

contract CARToken is ERC20 {
    constructor() ERC20("Car Token", "CRT") {
        _mint(msg.sender, 100 * 10**18);
    }
}
