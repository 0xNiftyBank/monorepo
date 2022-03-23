// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "./interfaces/IDebtToken.sol";
import "./interfaces/INiftyBank.sol";

contract NiftyBank is INiftyBank, Ownable {
    address private debtToken;
    struct DebtInfo {
        uint256 debtTokenId;
        address borrower;
        address paybackToken;
        uint256 borrowAmount;
        uint256 paybackAmount;
        uint256 startDeadline;
        uint256 returnDeadline;
    }

    mapping(address => mapping(uint256 => DebtInfo)) debts;

    constructor(address _debtToken) Ownable() {
        debtToken = _debtToken;
    }

    function depositNft(
        address _nft,
        uint256 _tokenId,
        address _paybackToken,
        uint256 _borrowAmount,
        uint256 _paybackAmount,
        uint256 _startDeadline,
        uint256 _returnDeadline
    ) external {
        require(
            _paybackAmount >= _borrowAmount,
            "Pay back at least the borrow amount"
        );
        IERC721(_nft).safeTransferFrom(msg.sender, address(this), _tokenId);
        uint256 debtTokenId = IDebtToken(debtToken).mint(msg.sender);
        debts[_nft][_tokenId] = DebtInfo({
            debtTokenId: debtTokenId,
            borrower: msg.sender,
            paybackToken: _paybackToken,
            borrowAmount: _borrowAmount,
            paybackAmount: _paybackAmount,
            startDeadline: _startDeadline,
            returnDeadline: _returnDeadline
        });
    }

    function withdrawNft(address _nft, uint256 _tokenId) external {
        require(
            msg.sender == debts[_nft][_tokenId].borrower,
            "Only the borrower can withdraw"
        );
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        require(
            IDebtToken(debtToken).ownerOf(debtTokenId) == msg.sender,
            "Not the debt token holder"
        );
        IDebtToken(debtToken).burn(debtTokenId);
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function executeLoan(address _nft, uint256 _tokenId) external {
        require(
            block.timestamp < debts[_nft][_tokenId].startDeadline,
            "Loan offer expired"
        );

        DebtInfo memory debtInfo = debts[_nft][_tokenId];
        IDebtToken debtTokenContract = IDebtToken(debtToken);
        require(
            debtTokenContract.ownerOf(debtInfo.debtTokenId) ==
                debtInfo.borrower,
            "Loan already started"
        );

        // Transfer funds
        require(
            IERC20(debtInfo.paybackToken).transferFrom(
                msg.sender,
                debtInfo.borrower,
                debtInfo.borrowAmount
            ),
            "Borrow amount transfer failed"
        );
        // Transfer Debt Token
        debtTokenContract.safeTransferFrom(
            debtInfo.borrower,
            msg.sender,
            debtInfo.debtTokenId
        );
    }

    function payDebt(address _nft, uint256 _tokenId) external {
        require(
            msg.sender == debts[_nft][_tokenId].borrower,
            "Only the borrower can pay debt"
        );
        require(
            block.timestamp < debts[_nft][_tokenId].returnDeadline,
            "Exceeds deadline"
        );
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        address paybackToken = debts[_nft][_tokenId].paybackToken;
        address lender = IDebtToken(debtToken).ownerOf(debtTokenId);
        require(
            IERC20(paybackToken).transferFrom(
                msg.sender,
                lender,
                debts[_nft][_tokenId].paybackAmount
            ),
            "Failed to pay back debt"
        );
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
        IDebtToken(debtToken).burn(debtTokenId);
    }

    function claimDefaultedNft(address _nft, uint256 _tokenId) external {
        require(
            block.timestamp >= debts[_nft][_tokenId].returnDeadline,
            "Exceeds deadline"
        );
        uint256 debtTokenId = debts[_nft][_tokenId].debtTokenId;
        address lender = IDebtToken(debtToken).ownerOf(debtTokenId);
        require(msg.sender == lender, "Only the lender can claim the NFT");
        IERC721(_nft).safeTransferFrom(address(this), msg.sender, _tokenId);
    }
}
