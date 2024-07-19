// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

///@title MerkleAirdrop
///@author Dustin Stacy
///@notice This is a sample contract demonstrating the use of Merkle Proofs in Airdrops.
contract MerkleAirdrop is EIP712 {
    /// Type Declarations ///

    using SafeERC20 for IERC20;

    struct AirdropClaim {
        address account;
        uint256 amount;
    }

    /// Errors ///

    /// @dev Emitted if an account attempts to claim ERC20 tokens with an invalid proof.
    error MerkleAirdrop__InvalidProof();

    /// @dev Emittedd if an account tries to claim ERC20 tokens after having already claimed them.
    error MerkleAirdrop__AlreadyClaimed();

    /// @dev Emitted if an account tries to claim ERC20tokens with an invalid signature.
    error MerkleAirdrop__InvalidSignature();

    /// Events ///

    /// @dev Emitted when an account successfully claimed ERC20 tokens.
    /// @param account The account address that claimed the tokens.
    /// @param amount The amound of tokens claimed.
    event Claimed(address indexed account, uint256 indexed amount);

    /// State Variables ///

    /// @dev Merkle root hash to check all proofs.
    bytes32 private immutable i_merkleRoot;

    /// @dev ERC20 token to be airdropped.
    IERC20 private immutable i_airdropToken;

    bytes32 private constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account, uint256 amount)");

    /// @dev List of addresses with allowance to claim ERC20 tokens.
    address[] claimers;

    /// @dev Maps an account address to a boolean indicating whether or not they have claimed ERC20 tokens.
    mapping(address account => bool claimed) private hasClaimed;

    /// Constructor ///

    /// @param merkleRoot Merkle root hash to check all proofs.
    /// @param airdropToken ERC20 token to be airdropped.
    constructor(bytes32 merkleRoot, IERC20 airdropToken) EIP712("MerkleAirdrop", "1") {
        i_merkleRoot = merkleRoot;
        i_airdropToken = airdropToken;
    }

    /// Functions ///

    /// @param account Address attempting to claim the ERC20 tokens.
    /// @param amount Amount of tokens attempting to be claimed.
    /// @param merkleProof Proof used to verify the accounts allowance to claim tokens.
    function claim(
        address account,
        uint256 amount,
        bytes32[] calldata merkleProof,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        external
    {
        if (hasClaimed[account]) {
            revert MerkleAirdrop__AlreadyClaimed();
        }
        if (!_isValidSignature(account, getMessageHash(account, amount), v, r, s)) {
            revert MerkleAirdrop__InvalidSignature();
        }
        bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(account, amount))));
        if (!MerkleProof.verify(merkleProof, i_merkleRoot, leaf)) {
            revert MerkleAirdrop__InvalidProof();
        }
        hasClaimed[account] = true;
        emit Claimed(account, amount);
        i_airdropToken.safeTransfer(account, amount);
    }

    function getMessageHash(address account, uint256 amount) public view returns (bytes32) {
        return _hashTypedDataV4(
            keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({ account: account, amount: amount })))
        );
    }

    function _isValidSignature(
        address account,
        bytes32 digest,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
        pure
        returns (bool)
    {
        (address actualSigner,,) = ECDSA.tryRecover(digest, v, r, s);
        return actualSigner == account;
    }

    function getMerkleRoot() external view returns (bytes32) {
        return i_merkleRoot;
    }

    function getAirdropToken() external view returns (IERC20) {
        return i_airdropToken;
    }
}
