// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "./interfaces/IDebtToken.sol";
import "./interfaces/INiftyBank.sol";

contract NiftyBank is INiftyBank, Ownable {

    address private debtToken;
    struct debtInfo {
        uint256 debtTokenId;
        address borrower;
        address paybackToken;
        uint256 returnDeadline;
    }

    mapping(address => mapping(uint256 => debtInfo)) debts;
    mapping(address => mapping(uint256 => uint256)) debtAmount;
    constructor(address _debtToken) Ownable() {
        debtToken = _debtToken;
    }

    function depositNft(
        address _nft, 
        uint256 _tokenId, 
        address _paybackToken,
        uint256 _minDebtAmount, 
        uint256 _returnDeadline
    ) external {

        IERC721(_nft).safeTransferFrom(msg.sender, address(this), _tokenId);
        uint256 debtTokenId = IDebtToken(debtToken).mint(msg.sender);
        debts[_nft][_tokenId] = debtInfo({
            debtTokenId: debtTokenId,
            borrower: msg.sender,
            paybackToken: _paybackToken,
            returnDeadline: _returnDeadline
        });
    }

    function withdrawNft(
        address _nft,
        uint256 _tokenId
    ) external {
        require(msg.sender == debts[_nft][_tokenId].borrower, "Only the borrower can withdraw");
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        require(IDebtToken(debtToken).ownerOf(debtTokenId) == msg.sender, "Not the debt token holder");
        IDebtToken(debtToken).burn(debtTokenId);
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function confirmOffer(
        address _nft,
        uint256 _tokenId,
        uint256 _amount
    ) external {
        require(msg.sender == debts[_nft][_tokenId].borrower, "Only the borrower can withdraw");
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        require(IDebtToken(debtToken).ownerOf(debtTokenId) == msg.sender, "Not the debt token holder");
        require(block.timestamp < debts[_nft][_tokenId].returnDeadline, "Exceeds deadline");
        debtAmount[_nft][_tokenId] = _amount;
    }

    function payDebt(
        address _nft,
        uint256 _tokenId
    ) external {
        require(msg.sender == debts[_nft][_tokenId].borrower, "Only the borrower can pay debt");
        require(block.timestamp < debts[_nft][_tokenId].returnDeadline, "Exceeds deadline");
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        address paybackToken = debts[_nft][_tokenId].paybackToken;
        address lender = IDebtToken(debtToken).ownerOf(debtTokenId);
        IERC20(paybackToken).transferFrom(msg.sender, lender, debtAmount[_nft][_tokenId]);
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
        IDebtToken(debtToken).burn(debtTokenId);
    }

    function claimDefaultedNft(
        address _nft,
        uint256 _tokenId
    ) external {
        require(block.timestamp >= debts[_nft][_tokenId].returnDeadline, "Exceeds deadline");
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        address lender = IDebtToken(debtToken).ownerOf(debtTokenId);
        require(msg.sender == lender, "Only the lender can claim the NFT");
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
    }
}
