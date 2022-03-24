// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import { IDebtToken, DebtInfo } from "../interfaces/IDebtToken.sol";
import { INiftyBank } from "../interfaces/INiftyBank.sol";
import { NiftyBank } from "../NiftyBank.sol";
import { NftToken } from "./utils/NftToken.sol";
import { StableToken } from "./utils/StableToken.sol";

import "ds-test/test.sol";

interface CheatCodes {
  function prank(address) external;
  function expectRevert(bytes calldata) external;
}

contract NiftyBankTest is DSTest {
    address constant DEPLOYER = 0xb0b670fc1F7724119963018DB0BfA86aDb22d941;
    address constant BORROWER = 0xED7d5F38C79115ca12fe6C0041abb22F0A06C300;
    address constant LENDER = 0x7373c42502874C88954bDd6D50b53061F018422e;

    address private _nft;
    uint256 private _tokenId;
    address private _borrowToken;
    uint256 private _borrowerBalance;
    uint256 private _borrowAmount;
    uint256 private _paybackAmount;
    uint256 private _startDeadline;
    uint256 private _returnDeadline;
    uint256 private _debtTokenId;

    CheatCodes cheats;
    INiftyBank niftyBank;
    IDebtToken debtTokenContract;

    NftToken nftToken;
    StableToken stableToken;

    function setUp() public {
        _borrowerBalance = 1000;
        _borrowAmount = 10000;
        _paybackAmount = _borrowAmount + _borrowerBalance;
        _startDeadline = block.timestamp;
        _returnDeadline = block.timestamp;

        // Deploy NiftyBank
        cheats = CheatCodes(HEVM_ADDRESS);
        cheats.prank(DEPLOYER);
        niftyBank = new NiftyBank();
        debtTokenContract = niftyBank.debtTokenContract();

        // Deploy NFT
        cheats.prank(DEPLOYER);
        nftToken = new NftToken("NFT", "NFT");
        _nft = address(nftToken);

        cheats.prank(DEPLOYER);
        _tokenId = nftToken.mint(BORROWER);

        // Deploy stable coin
        cheats.prank(DEPLOYER);
        stableToken = new StableToken("Fake USD", "USD");
        _borrowToken = address(stableToken);

        cheats.prank(DEPLOYER);
        stableToken.mint(LENDER, _borrowAmount);
        cheats.prank(DEPLOYER);
        stableToken.mint(BORROWER, _borrowerBalance);
    }

    function testDepositNft() public {
        // Borrower approve NiftyBank to use their NFT
        cheats.prank(BORROWER);
        nftToken.setApprovalForAll(address(niftyBank), true);

        // Borrower deposit NFT to NiftyBank
        cheats.prank(BORROWER);
        _debtTokenId = niftyBank.depositNft(
            _nft,
            _tokenId,
            _borrowToken,
            _borrowAmount,
            _paybackAmount,
            _startDeadline,
            _returnDeadline
        );

        // Verify that borrower obtained DebtToken
        assertEq(debtTokenContract.ownerOf(_debtTokenId), BORROWER);

        // Verify DebtInfo
        DebtInfo memory debtInfo = debtTokenContract.debtInfoOf(_debtTokenId);        
        assertEq(debtInfo.nft, _nft);
        assertEq(debtInfo.tokenId, _tokenId);
        assertEq(debtInfo.borrower, BORROWER);
        assertEq(debtInfo.borrowToken, _borrowToken);
        assertEq(debtInfo.borrowAmount, _borrowAmount);
        assertEq(debtInfo.paybackAmount, _paybackAmount);
        assertEq(debtInfo.startDeadline, _startDeadline);
        assertEq(debtInfo.returnDeadline, _returnDeadline);

        // Verify that current owner of NFT is NiftyBank
        assertEq(nftToken.ownerOf(_tokenId), address(niftyBank));
    }

    function testWithdrawNft() public {
        // Borrower deposit the NFT first
        testDepositNft();

        // Borrower withdraw NFT from NiftyBank
        cheats.prank(BORROWER);
        niftyBank.withdrawNft(_debtTokenId);

        // Verify that DebtToken has been burnt
        cheats.expectRevert(
            bytes("ERC721: owner query for nonexistent token")
        );
        debtTokenContract.ownerOf(_debtTokenId);

        // Verify that current owner of NFT is the borrower
        assertEq(nftToken.ownerOf(_tokenId), BORROWER);
    }

    function testExecuteLoan() public {
        // Borrower deposit the NFT first
        testDepositNft();

        // Lender approve NiftyBank to use their NFT
        cheats.prank(LENDER);
        stableToken.approve(address(niftyBank), _borrowAmount);

        // Lender lend money to borrower through `executeLoan()`
        cheats.prank(LENDER);
        niftyBank.executeLoan(_debtTokenId);

        // Verify that current owner of DebtToken is the lender
        assertEq(debtTokenContract.ownerOf(_debtTokenId), LENDER);

        // Verify that current stable coin balance of the borrower increased by `_borrowAmount`
        assertEq(stableToken.balanceOf(BORROWER), _borrowAmount + _borrowerBalance);
    }

    function testPayDebt() public {
        // Borrower deposit the NFT and lender lend money
        testExecuteLoan();

        // Borrower approves NiftyBank to use their stable coins
        cheats.prank(BORROWER);
        stableToken.approve(address(niftyBank), _paybackAmount);

        // Borrower pay the debt
        cheats.prank(BORROWER);
        niftyBank.payDebt(_debtTokenId);

        // Verify that DebtToken has been burnt
        cheats.expectRevert(
            bytes("ERC721: owner query for nonexistent token")
        );
        debtTokenContract.ownerOf(_debtTokenId);

        // Verify that current owner of NFT is the borrower
        assertEq(nftToken.ownerOf(_tokenId), BORROWER);

        // Verify that lender get paid back
        assertEq(stableToken.balanceOf(LENDER), _paybackAmount);
    }

    function testClaimDefaultedNft() public {
        // Borrower deposit the NFT and lender lend money
        testExecuteLoan();

        // Borrower approves NiftyBank to use their stable coins
        cheats.prank(BORROWER);
        stableToken.approve(address(niftyBank), _paybackAmount);

        // Lender claims default NFT
        cheats.prank(LENDER);
        niftyBank.claimDefaultedNft(_debtTokenId);

        // Verify that DebtToken has been burnt
        cheats.expectRevert(
            bytes("ERC721: owner query for nonexistent token")
        );
        debtTokenContract.ownerOf(_debtTokenId);

        // Verify that current owner of NFT is the borrower
        assertEq(nftToken.ownerOf(_tokenId), LENDER);

        // Verify that lender does not get paid back
        assertEq(stableToken.balanceOf(LENDER), 0);
    }
}
