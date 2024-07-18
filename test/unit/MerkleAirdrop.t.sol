// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { Test, console } from "forge-std/Test.sol";
import { PizzaToken } from "src/PizzaToken.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";

contract MerkleAirdropTest is Test {
    PizzaToken pizza;
    MerkleAirdrop airdrop;

    address public owner = makeAddr("owner");
    address user;
    uint256 userKey;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25e18;
    uint256 public AMOUNT_TO_MINT = AMOUNT_TO_CLAIM * 4;
    bytes32 proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 proofTwo = 0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public PROOF = [proofOne, proofTwo];

    function setUp() public {
        pizza = new PizzaToken(owner);
        airdrop = new MerkleAirdrop(ROOT, pizza);
        (user, userKey) = makeAddrAndKey("user");

        vm.startPrank(owner);
        pizza.mint(pizza.owner(), AMOUNT_TO_MINT);
        pizza.transfer(address(airdrop), AMOUNT_TO_MINT);
        vm.stopPrank();
    }

    function test_UsersCanClaim() public {
        uint256 startingBalance = pizza.balanceOf(user);

        vm.prank(user);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF);

        uint256 endingBalance = pizza.balanceOf(user);
        console.log("Ending balance:", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }
}
