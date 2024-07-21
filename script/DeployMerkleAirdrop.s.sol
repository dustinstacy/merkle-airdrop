// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { Script } from 'forge-std/Script.sol';
import { PizzaToken } from 'src/PizzaToken.sol';
import { MerkleAirdrop } from 'src/MerkleAirdrop.sol';
import { IERC20 } from '@openzeppelin/contracts/token/ERC20/IERC20.sol';

contract DeployMerkleAirdrop is Script {
    bytes32 private merkleRoot = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 private amountToMint = 25e18 * 4;

    function deployMerkleAirdrop() public returns (MerkleAirdrop airdrop, PizzaToken pizza) {
        vm.startBroadcast();
        pizza = new PizzaToken();
        airdrop = new MerkleAirdrop(merkleRoot, IERC20(address(pizza)));
        pizza.mint(pizza.owner(), amountToMint);
        pizza.transfer(address(airdrop), amountToMint);
        vm.stopBroadcast();
    }

    function run() external returns (MerkleAirdrop, PizzaToken) {
        return deployMerkleAirdrop();
    }
}
