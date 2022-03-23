// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

interface IDebtToken is IERC721 {
    function mint(address _borrower) external returns (uint256);

    function burn(uint256 _tokenId) external;
}
