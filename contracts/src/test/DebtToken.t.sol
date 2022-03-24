// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.12;

// import { DebtInfo } from "../interfaces/IDebtToken.sol";
// import { DebtToken } from "../DebtToken.sol";
// import { DSTestPlus } from "./utils/DSTestPlus.sol";

// interface CheatCodes {
//   function prank(address) external;
//   function expectRevert(bytes calldata) external;
// }

// contract DebtTokenTest is DSTestPlus {
//     address constant DEBT_TOKEN_DEPLOYER = 0xb0b670fc1F7724119963018DB0BfA86aDb22d941;
//     address constant DEBT_TOKEN_OWNER = 0xED7d5F38C79115ca12fe6C0041abb22F0A06C300;
//     address constant OTHER_ADDRESS = 0x7373c42502874C88954bDd6D50b53061F018422e;

//     address private _nft;
//     uint256 private _tokenId;
//     address private _borrowToken;
//     uint256 private _borrowAmount;
//     uint256 private _paybackAmount;
//     uint256 private _startDeadline;
//     uint256 private _returnDeadline;

//     CheatCodes cheats;
//     DebtToken debtToken;

//     function setUp() public {
//         _nft = 0x25D2e80cB6B86881Fd7e07dd263Fb79f4AbE033c;
//         _tokenId = 1233;
//         _borrowToken = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
//         _borrowAmount = 10000;
//         _paybackAmount = 11000;
//         _startDeadline = block.timestamp;
//         _returnDeadline = block.timestamp + 300000;

//         console.log(unicode"🧪 Testing DebtToken.sol...");
//         cheats = CheatCodes(HEVM_ADDRESS);
//         cheats.prank(DEBT_TOKEN_DEPLOYER);
//         debtToken = new DebtToken("Test Debt Token", "TDT");
//     }

//     function testNameAndSymbol() public {
//         assertEq(debtToken.name(), "Test Debt Token");
//         assertEq(debtToken.symbol(), "TDT");
//         console.log(unicode"✅ name() and symbol() test passed");
//     }

//     function testOwner() public {
//         assertEq(debtToken.owner(), DEBT_TOKEN_DEPLOYER);
//         console.log(unicode"✅ owner() test passed");
//     }

//     function testMint() public {
//         uint256 count = debtToken.currentTokenId();

//         cheats.prank(DEBT_TOKEN_DEPLOYER);
//         uint256 debtTokenId = debtToken.mint(createDebtInfoFor(DEBT_TOKEN_OWNER));
        
//         assertEq(debtTokenId, count + 1);
//         assertEq(debtToken.ownerOf(debtTokenId), DEBT_TOKEN_OWNER);
//         assertEq(debtToken.debtInfoOf(debtTokenId).nft, _nft);
//         assertEq(debtToken.debtInfoOf(debtTokenId).borrowToken, _borrowToken);
//         assertEq(debtToken.debtInfoOf(debtTokenId).borrower, DEBT_TOKEN_OWNER);
//         assertEq(debtToken.debtInfoOf(debtTokenId).borrowAmount, _borrowAmount);
//         assertEq(debtToken.debtInfoOf(debtTokenId).paybackAmount, _paybackAmount);
//         assertEq(debtToken.debtInfoOf(debtTokenId).startDeadline, _startDeadline);
//         assertEq(debtToken.debtInfoOf(debtTokenId).returnDeadline, _returnDeadline);
//         console.log(unicode"✅ mint() test passed");
//     }

//     function testMintAsNotOwner() public {
//         cheats.expectRevert(
//             bytes("Ownable: caller is not the owner")
//         );
//         cheats.prank(OTHER_ADDRESS);
//         debtToken.mint(createDebtInfoFor(DEBT_TOKEN_OWNER));
//     }

//     function testBurn() public {
//         cheats.prank(DEBT_TOKEN_DEPLOYER);
//         uint256 debtTokenId = debtToken.mint(createDebtInfoFor(DEBT_TOKEN_OWNER));
//         assertEq(debtToken.ownerOf(debtTokenId), DEBT_TOKEN_OWNER);

//         cheats.prank(DEBT_TOKEN_DEPLOYER);
//         debtToken.burn(debtTokenId);
//         console.log(unicode"✅ burn() test passed");
//     }

//     function testBurnAsNotOwner() public {
//         cheats.prank(DEBT_TOKEN_DEPLOYER);
//         uint256 debtTokenId = debtToken.mint(createDebtInfoFor(DEBT_TOKEN_OWNER));
//         assertEq(debtToken.ownerOf(debtTokenId), DEBT_TOKEN_OWNER);

//         cheats.expectRevert(
//             bytes("Ownable: caller is not the owner")
//         );
//         cheats.prank(OTHER_ADDRESS);
//         debtToken.burn(debtTokenId);
//     }

//     function createDebtInfoFor(address _borrower) private view returns (DebtInfo memory debtInfo) {
//         debtInfo = DebtInfo({
//             nft: _nft,
//             tokenId: _tokenId,
//             borrower: _borrower,
//             borrowToken: _borrowToken,
//             borrowAmount: _borrowAmount,
//             paybackAmount: _paybackAmount,
//             startDeadline: _startDeadline,
//             returnDeadline: _returnDeadline
//         });
//         return debtInfo;
//     }
// }
