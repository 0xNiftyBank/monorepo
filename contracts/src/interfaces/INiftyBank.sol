// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { IDebtToken, DebtInfo } from "./IDebtToken.sol";

import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

interface INiftyBank is IERC721Receiver {
    function debtTokenContract() external view returns (IDebtToken);

    function depositNft(
        address _nft,
        uint256 _tokenId,
        address _paybackToken,
        uint256 _borrowAmount,
        uint256 _paybackAmount,
        uint256 _startDeadline,
        uint256 _returnDeadline
    ) external returns(uint256 debtTokenId);

    function getAllDebtInfos() external view returns (DebtInfo[] memory);
    function executeLoan(uint256 _debtTokenId) external;

    function withdrawNft(uint256 _debtTokenId) external;

    function payDebt(uint256 _debtTokenId) external;

    function claimDefaultedNft(uint256 _debtTokenId) external;
}
