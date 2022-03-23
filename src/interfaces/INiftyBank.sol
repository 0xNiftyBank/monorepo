// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INiftyBank {
    function depositNft(
        address _nft, 
        uint256 _tokenId, 
        address _paybackToken,
        uint256 _minDebtAmount, 
        uint256 _returnDeadline
    ) external;

    function withdrawNft(
        address _nft,
        uint256 _tokenId
    ) external;

    function confirmOffer(
        address _nft,
        uint256 _tokenId,
        uint256 _amount
    ) external;

    function payDebt(
        address _nft,
        uint256 _tokenId
    ) external;

    function claimDefaultedNft(
        address _nft,
        uint256 _tokenId
    ) external;
}