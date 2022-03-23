// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

struct DebtInfo {
    address nft;
    uint256 tokenId;
    address borrower;
    address borrowToken;
    uint256 borrowAmount;
    uint256 paybackAmount;
    uint256 startDeadline;
    uint256 returnDeadline;
}

interface IDebtToken is IERC721 {
    function currentTokenId() external view returns (uint256);

    function debtInfoOf(uint256 _debtTokenId) external view returns (DebtInfo memory debtInfo);

    function mint(DebtInfo memory _debtInfo) external returns (uint256 debtTokenId);

    function burn(uint256 _debtTokenId) external;
}
