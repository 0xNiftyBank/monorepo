// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StableToken is ERC20, Ownable {

    constructor(string memory _name, string memory _symbol)
        ERC20(_name, _symbol)
        Ownable()
    {}

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
