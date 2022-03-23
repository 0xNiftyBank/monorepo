// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "./interfaces/IDebtToken.sol";
import "./interfaces/INiftyBank.sol";

contract NiftyBank is INiftyBank, Ownable {
    address public debtToken;
    struct DebtInfo {
        address nft;
        uint256 tokenId;
        address borrower;
        address paybackToken;
        uint256 borrowAmount;
        uint256 paybackAmount;
        uint256 startDeadline;
        uint256 returnDeadline;
    }

    mapping(uint256 => DebtInfo) debts;

    constructor(address _debtToken) Ownable() {
        debtToken = _debtToken;
    }

    function debtOf(uint256 _debtTokenId) external view 
    returns 
    (address, uint256, address, address, uint256, uint256, uint256, uint256) {
        DebtInfo memory debtInfo = debts[_debtTokenId];
        return (
            debtInfo.nft, 
            debtInfo.tokenId, 
            debtInfo.borrower, 
            debtInfo.paybackToken, 
            debtInfo.borrowAmount,
            debtInfo.paybackAmount,
            debtInfo.startDeadline,
            debtInfo.returnDeadline
        );
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
        debts[debtTokenId] = DebtInfo({
            nft: _nft,
            tokenId: _tokenId,
            borrower: msg.sender,
            paybackToken: _paybackToken,
            borrowAmount: _borrowAmount,
            paybackAmount: _paybackAmount,
            startDeadline: _startDeadline,
            returnDeadline: _returnDeadline
        });
    }

    function withdrawNft(uint256 _debtTokenId) external {
        require(
            msg.sender == debts[_debtTokenId].borrower,
            "Only the borrower can withdraw"
        );
        require(
            IDebtToken(debtToken).ownerOf(_debtTokenId) == msg.sender,
            "Not the debt token holder"
        );
        IDebtToken(debtToken).burn(_debtTokenId);
        address nft = debts[_debtTokenId].nft;
        uint256 tokenId = debts[_debtTokenId].tokenId;
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }

    function executeLoan(uint256 _debtTokenId) external {
        require(
            block.timestamp < debts[_debtTokenId].startDeadline,
            "Loan offer expired"
        );

        DebtInfo memory debtInfo = debts[_debtTokenId];
        IDebtToken debtTokenContract = IDebtToken(debtToken);
        require(
            debtTokenContract.ownerOf(_debtTokenId) ==
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
            _debtTokenId
        );
    }

    function payDebt(uint256 _debtTokenId) external {
        require(
            msg.sender == debts[_debtTokenId].borrower,
            "Only the borrower can pay debt"
        );
        require(
            block.timestamp < debts[_debtTokenId].returnDeadline,
            "Exceeds deadline"
        );
        address paybackToken = debts[_debtTokenId].paybackToken;
        address lender = IDebtToken(debtToken).ownerOf(_debtTokenId);
        require(
            IERC20(paybackToken).transferFrom(
                msg.sender,
                lender,
                debts[_debtTokenId].paybackAmount
            ),
            "Failed to pay back debt"
        );

        address nft = debts[_debtTokenId].nft;
        uint256 tokenId = debts[_debtTokenId].tokenId;
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
        IDebtToken(debtToken).burn(_debtTokenId);
    }

    function claimDefaultedNft(uint256 _debtTokenId) external {
        require(
            block.timestamp >= debts[_debtTokenId].returnDeadline,
            "Exceeds deadline"
        );
        address lender = IDebtToken(debtToken).ownerOf(_debtTokenId);
        require(msg.sender == lender, "Only the lender can claim the NFT");

        address nft = debts[_debtTokenId].nft;
        uint256 tokenId = debts[_debtTokenId].tokenId;
        IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    }
}
