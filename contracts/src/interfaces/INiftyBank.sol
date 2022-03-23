// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INiftyBank {
    function depositNft(
        address _nft,
        uint256 _tokenId,
        address _paybackToken,
        uint256 _borrowAmount,
        uint256 _paybackAmount,
        uint256 _startDeadline,
        uint256 _returnDeadline
    ) external;

    function executeLoan(uint256 _debtTokenId) external;

    function withdrawNft(uint256 _debtTokenId) external;

    function payDebt(uint256 _debtTokenId) external;

    function claimDefaultedNft(uint256 _debtTokenId) external;
}
