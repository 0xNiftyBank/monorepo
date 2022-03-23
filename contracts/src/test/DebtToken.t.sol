// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

import {DebtToken} from "../DebtToken.sol";
import {DSTestPlus} from "./utils/DSTestPlus.sol";

interface CheatCodes {
  function prank(address) external;
  function expectRevert(bytes calldata) external;
}

contract DebtTokenTest is DSTestPlus {
    address constant DEBT_TOKEN_DEPLOYER = 0xb0b670fc1F7724119963018DB0BfA86aDb22d941;
    address constant DEBT_TOKEN_OWNER = 0xED7d5F38C79115ca12fe6C0041abb22F0A06C300;
    address constant OTHER_ADDRESS = 0x7373c42502874C88954bDd6D50b53061F018422e;
    // address constant MDX_FACTORY = 0x25D2e80cB6B86881Fd7e07dd263Fb79f4AbE033c;

    DebtToken debtToken;
    CheatCodes cheats;

    function setUp() public {
        console.log(unicode"🧪 Testing DebtToken.sol...");
        cheats = CheatCodes(HEVM_ADDRESS);
        cheats.prank(DEBT_TOKEN_DEPLOYER);
        debtToken = new DebtToken("Test Debt Token", "TDT");
    }

    function testNameAndSymbol() public {
        assertEq(debtToken.name(), "Test Debt Token");
        assertEq(debtToken.symbol(), "TDT");
        console.log(unicode"✅ name() and symbol() test passed");
    }

    function testOwner() public {
        assertEq(debtToken.owner(), DEBT_TOKEN_DEPLOYER);
        console.log(unicode"✅ owner() test passed");
    }

    function testMint() public {
        cheats.prank(DEBT_TOKEN_DEPLOYER);
        uint256 tokenId = debtToken.mint(DEBT_TOKEN_OWNER);
        
        assertEq(tokenId, 1);
        assertEq(debtToken.ownerOf(tokenId), DEBT_TOKEN_OWNER);
        console.log(unicode"✅ mint() test passed");
    }

    function testMintAsNotOwner() public {
        cheats.expectRevert(
            bytes("Ownable: caller is not the owner")
        );
        cheats.prank(OTHER_ADDRESS);
        debtToken.mint(DEBT_TOKEN_OWNER);
    }

    function testBurn() public {
        cheats.prank(DEBT_TOKEN_DEPLOYER);
        uint256 tokenId = debtToken.mint(DEBT_TOKEN_OWNER);
        assertEq(debtToken.ownerOf(tokenId), DEBT_TOKEN_OWNER);

        cheats.prank(DEBT_TOKEN_DEPLOYER);
        debtToken.burn(tokenId);
        console.log(unicode"✅ burn() test passed");
    }

    function testBurnAsNotOwner() public {
        cheats.prank(DEBT_TOKEN_DEPLOYER);
        uint256 tokenId = debtToken.mint(DEBT_TOKEN_OWNER);
        assertEq(debtToken.ownerOf(tokenId), DEBT_TOKEN_OWNER);

        cheats.expectRevert(
            bytes("Ownable: caller is not the owner")
        );
        cheats.prank(OTHER_ADDRESS);
        debtToken.burn(tokenId);
    }
}
