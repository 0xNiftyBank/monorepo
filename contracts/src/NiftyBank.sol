// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

import "./interfaces/IDebtToken.sol";
import "./interfaces/INiftyBank.sol";
import "./DebtToken.sol";

contract NiftyBank is INiftyBank {
    IDebtToken private _debtTokenContract;

    constructor() {
        _debtTokenContract = new DebtToken("NiftyBank Debt Token", "NDT");
    }

    function debtTokenContract() external view returns (IDebtToken) {
        return _debtTokenContract;
    }

    function getAllDebtInfos()
        external
        view
        returns (DebtInfo[] memory debtInfos)
    {
        uint256 numDebts = _debtTokenContract.currentTokenId();
        debtInfos = new DebtInfo[](numDebts);

        for (uint256 i = 0; i < numDebts; i++) {
            // NOTE: One off here due to id being incremented before returned
            debtInfos[i] = _debtTokenContract.debtInfoOf(i + 1);
        }
    }

    function depositNft(
        address _nft,
        uint256 _tokenId,
        address _borrowToken,
        uint256 _borrowAmount,
        uint256 _paybackAmount,
        uint256 _startDeadline,
        uint256 _returnDeadline
    ) external returns (uint256 debtTokenId) {
        require(
            _paybackAmount >= _borrowAmount,
            "Pay back at least the borrow amount"
        );
        require(
            _returnDeadline >= _startDeadline,
            "returnDeadline should be later than startDeadline"
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
        debtTokenId = _debtTokenContract.mint(debtInfo);
        return debtTokenId;
    }

    function withdrawNft(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = _debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            msg.sender == debtInfo.borrower,
            "Only the borrower can withdraw"
        );
        require(
            _debtTokenContract.ownerOf(_debtTokenId) == msg.sender,
            "Not the debt token holder"
        );
        _debtTokenContract.burn(_debtTokenId);
        IERC721(debtInfo.nft).safeTransferFrom(
            address(this),
            msg.sender,
            debtInfo.tokenId
        );
    }

    function executeLoan(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = _debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            block.timestamp <= debtInfo.startDeadline,
            "Loan offer expired"
        );

        require(
            _debtTokenContract.ownerOf(_debtTokenId) == debtInfo.borrower,
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
        _debtTokenContract.safeTransferFrom(
            debtInfo.borrower,
            msg.sender,
            _debtTokenId
        );
    }

    function payDebt(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = _debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            msg.sender == debtInfo.borrower,
            "Only the borrower can pay debt"
        );
        address lender = _debtTokenContract.ownerOf(_debtTokenId);
        require(
            IERC20(debtInfo.borrowToken).transferFrom(
                msg.sender,
                lender,
                debtInfo.paybackAmount
            ),
            "Failed to pay back debt"
        );

        IERC721(debtInfo.nft).safeTransferFrom(
            address(this),
            msg.sender,
            debtInfo.tokenId
        );
        _debtTokenContract.burn(_debtTokenId);
    }

    function claimDefaultedNft(uint256 _debtTokenId) external {
        DebtInfo memory debtInfo = _debtTokenContract.debtInfoOf(_debtTokenId);
        require(
            block.timestamp >= debtInfo.returnDeadline,
            "Debt is not defaulted yet"
        );
        address lender = _debtTokenContract.ownerOf(_debtTokenId);
        require(msg.sender == lender, "Only the lender can claim the NFT");

        IERC721(debtInfo.nft).safeTransferFrom(
            address(this),
            lender,
            debtInfo.tokenId
        );
        _debtTokenContract.burn(_debtTokenId);
    }

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
