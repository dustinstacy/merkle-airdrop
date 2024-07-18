// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Test, console } from "forge-std/Test.sol";
import { PizzaToken } from "src/PizzaToken.sol";

contract PizzaTokenTest is Test {
    PizzaToken public pizza;

    address public owner = address(this);
    address public user = makeAddr("user");
    uint256 public mintAmount = 20e18;

    function setUp() public {
        pizza = new PizzaToken();
    }

    ///
    /// Constructor
    ///
    function test_ConstructorSetsNameAndSymbolCorrectly() public view {
        string memory expectedName = "Pizza Token";
        string memory expectedSymbol = "PZA";
        assertEq(pizza.name(), expectedName);
        assertEq(pizza.symbol(), expectedSymbol);
    }

    function test_ConstructorSetsOwnerProperly() public view {
        address expectedOwner = owner;
        assertEq(pizza.owner(), expectedOwner);
    }

    ///
    /// Mint
    ///
    function test_RevertIf_MintCallerIsNotTheOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        pizza.mint(user, mintAmount);
    }

    function test_RevertIf_ToAddressIsZero() public {
        vm.prank(owner);
        vm.expectRevert(PizzaToken.PizzaToken__AddressCannotBeZero.selector);
        pizza.mint(address(0), mintAmount);
    }

    function test_RevertIf_MintAmountIsZero() public {
        vm.prank(owner);
        vm.expectRevert(PizzaToken.PizzaToken__AmountMustBeMoreThanZero.selector);
        pizza.mint(owner, 0);
    }

    function test_MintsTheRightAmountToTheCorrectAddress() public {
        vm.startPrank(owner);
        uint256 startingBalance = pizza.balanceOf(owner);
        pizza.mint(owner, mintAmount);
        vm.stopPrank();

        uint256 endingBalance = pizza.balanceOf(owner);
        assertEq(startingBalance + mintAmount, endingBalance);
    }
}
