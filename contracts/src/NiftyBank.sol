// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import "./interfaces/IDebtToken.sol";
import "./interfaces/INiftyBank.sol";
import "./DebtToken.sol";

contract NiftyBank is INiftyBank {
    IDebtToken public debtTokenContract;

    constructor() {
        debtTokenContract = new DebtToken('NiftyBank Debt Token', 'NDT');
    }

    function depositNft(
        address _nft,
        uint256 _tokenId,
        address _borrowToken,
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
        DebtInfo memory debtInfo = DebtInfo({
            nft: _nft,
            tokenId: _tokenId,
            borrower: msg.sender,
            borrowToken: _borrowToken,
            borrowAmount: _borrowAmount,
            paybackAmount: _paybackAmount,
            startDeadline: _startDeadline,
            returnDeadline: _returnDeadline
        });
        uint256 debtTokenId = debtTokenContract.mint(debtInfo);
    }

    function withdrawNft(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            msg.sender == debtInfo.borrower,
            "Only the borrower can withdraw"
        );
        require(
            debtTokenContract.ownerOf(_debtTokenId) == msg.sender,
            "Not the debt token holder"
        );
        debtTokenContract.burn(_debtTokenId);
        IERC721(debtInfo.nft).safeTransferFrom(address(this), msg.sender, debtInfo.tokenId);
    }

    function executeLoan(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            block.timestamp < debtInfo.startDeadline,
            "Loan offer expired"
        );

        require(
            debtTokenContract.ownerOf(_debtTokenId) ==
                debtInfo.borrower,
            "Loan already started"
        );

        // Transfer funds
        require(
            IERC20(debtInfo.borrowToken).transferFrom(
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
        DebtInfo memory debtInfo = debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            msg.sender == debtInfo.borrower,
            "Only the borrower can pay debt"
        );
        require(
            block.timestamp < debtInfo.returnDeadline,
            "Exceeds deadline"
        );
        address lender = debtTokenContract.ownerOf(_debtTokenId);
        require(
            IERC20(debtInfo.borrowToken).transferFrom(
                msg.sender,
                lender,
                debtInfo.paybackAmount
            ),
            "Failed to pay back debt"
        );

        IERC721(debtInfo.nft).safeTransferFrom(address(this), msg.sender, debtInfo.tokenId);
        debtTokenContract.burn(_debtTokenId);
    }

    function claimDefaultedNft(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            block.timestamp >= debtInfo.returnDeadline,
            "Exceeds deadline"
        );
        address lender = debtTokenContract.ownerOf(_debtTokenId);
        require(msg.sender == lender, "Only the lender can claim the NFT");

        IERC721(debtInfo.nft).safeTransferFrom(address(this), msg.sender, debtInfo.tokenId);
    }
}
