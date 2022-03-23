// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {DebtToken} from "../DebtToken.sol";
import "openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";
import "ds-test/test.sol";

contract DebtTokenTest is DSTest, IERC721Receiver {
    DebtToken debtToken;

    function setUp() public {
        debtToken = new DebtToken("NiftyCoin", "NIF");
    }

    function testConstructor() public {
        assertEq(debtToken.name(), "NiftyCoin");
        assertEq(debtToken.symbol(), "NIF");
    }

    function testMintAndBurn() public {
        debtToken.setNiftyBank(address(this));
        assertEq(debtToken.niftyBank(), address(this));

        uint256 mintedTokenId = debtToken.mint(address(this));
        assertEq(mintedTokenId, 1);

        debtToken.burn(1);

        assertEq(debtToken.currentTokenId(), 1);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
