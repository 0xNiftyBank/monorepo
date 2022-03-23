// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/utils/Counters.sol";
import "openzeppelin-contracts/contracts/token/ERC721/ERC721.sol";

import "./interfaces/IDebtToken.sol";

contract DebtToken is IDebtToken, ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private tokenCounter;

    mapping(uint256 => DebtInfo) private debts;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
        Ownable()
    {}

    function currentTokenId() external view returns (uint256) {
        return tokenCounter.current();
    }

    function debtInfoOf(uint256 _debtTokenId) external view returns (DebtInfo memory debtInfo) {
        debtInfo = debts[_debtTokenId];
        return debtInfo;
    }

    function mint(DebtInfo memory _debtInfo) external onlyOwner returns (uint256 debtTokenId) {
        debtTokenId = nextTokenId();
        _safeMint(_debtInfo.borrower, debtTokenId);
        debts[debtTokenId] = _debtInfo;
        return debtTokenId;
    }

    function burn(uint256 _debtTokenId) external onlyOwner {
        _burn(_debtTokenId);
        delete debts[_debtTokenId];
    }

    function nextTokenId() private returns (uint256) {
        tokenCounter.increment();
        return tokenCounter.current();
    }
}
