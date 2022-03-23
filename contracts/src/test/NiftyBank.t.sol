// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {DebtToken} from "../DebtToken.sol";
import {NiftyBank} from "../NiftyBank.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "ds-test/test.sol";

contract NiftyBankTest is DSTest, IERC721Receiver {
    NiftyBank niftyBank;
    DebtToken debtToken;

    function setUp() public {
        debtToken = new DebtToken("NiftyCoin", "NIF");
        niftyBank = new NiftyBank(address(debtToken));
    }

    function testConstructor() public {
        assertEq(niftyBank.debtToken(), address(debtToken));
    }

    // function testDepositNft() public {
    //     // the timestamp is sufficiently large
    //     niftyBank.depositNft(address(0), 1, address(0), 100, 200, 1648168683, 1648268683);
    //     (
    //         address nft, 
    //         uint256 tokenId, 
    //         address borrower, 
    //         address paybackToken, 
    //         uint256 borrowAmount, 
    //         uint256 paybackAmount, 
    //         uint256 startDeadline, 
    //         uint256 returnDeadline
    //     ) = niftyBank.debtOf(1);        
    //     assertEq(nft, address(0));
    // }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
