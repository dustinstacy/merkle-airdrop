// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

///@title MerkleAirdrop
///@author Dustin Stacy
///@notice This is a sample contract demonstrating the use of Merkle Proofs in Airdrops.
contract MerkleAirdrop {
    ///
    /// Type Declarations
    ///

    using SafeERC20 for IERC20;

    ///
    /// Errors
    ///

    error MerkleAirdrop__InvalidProof();

    ///
    /// Events
    ///

    event Claimed(address indexed account, uint256 indexed amount);

    ///
    /// State Variables
    ///

    /// @dev Merkle root hash to check all proofs.
    bytes32 private immutable i_merkleRoot;

    /// @dev ERC20 token to be airdropped.
    IERC20 private immutable i_airdropToken;

    /// @dev List of addresses with allowance to claim ERC20 tokens.
    address[] claimers;

    ///
    /// Constructor
    ///

    /// @param merkleRoot Merkle root hash to check all proofs.
    /// @param airdropToken ERC20 token to be airdropped.
    constructor(bytes32 merkleRoot, IERC20 airdropToken) {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /// @param account Address attempting to claim the ERC20 tokens.
    /// @param amount Amount of ERC20 tokens attempting to be claimed.
    /// @param merkleProof Proof used to verify the accounts allowance to claim ERC20 tokens.
    function claim(address account, uint256 amount, bytes32[] calldata merkleProof) external {
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        emit Claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }
}
