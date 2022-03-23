// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

import "./interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private tokenCounter;

    address public niftyBank;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable()
    {}

    function setNiftyBank(address _niftyBank) external onlyOwner {
        niftyBank = _niftyBank;
    }

    function currentTokenId() external view returns (uint256) {
        return tokenCounter.current();
    }

    function mint(address _borrower) external returns (uint256) {
        require(
            niftyBank != address(0) && msg.sender == niftyBank,
            "Should only be called by niftyBank"
        );
        uint256 newTokenId = nextTokenId();
        _safeMint(_borrower, newTokenId);
        return newTokenId;
    }

    function burn(uint256 _tokenId) external {
        require(
            niftyBank != address(0) && msg.sender == niftyBank,
            "Should only be called by niftyBank"
        );
        _burn(_tokenId);
    }

    function nextTokenId() private returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
    }
}
