// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

import "./interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private tokenCounter;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable()
    {}

    function mint(address _to) external onlyOwner returns (uint256) {
        uint256 newTokenId = nextTokenId();
        _safeMint(_to, newTokenId);
        return newTokenId;
    }

    function burn(uint256 _tokenId) external onlyOwner {
        _burn(_tokenId);
    }

    function nextTokenId() private returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
    }
}
