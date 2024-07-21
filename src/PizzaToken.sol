// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.24;

import { ERC20 } from '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

/// @title PizzaToken
/// @author Dustin Stacy
/// @notice Basic implementation of the ERC20 token for use in Merkle Airdrop Contract.
contract PizzaToken is ERC20, Ownable {
    /// @dev Emitted when attempting to perform an action with an amount that must be more than zero.
    error PizzaToken__AmountMustBeMoreThanZero();

    /// @dev Emitted when attempting to perform an action with a zero address.
    error PizzaToken__AddressCannotBeZero();

    /// @notice The newest version of Open Zeppelin's Ownable contract require's an `initialOwner` to be passed to the
    /// Ownable constructor.
    /// @notice If using an older version, no `initialOwner` will be required.
    /// @notice This contract sets the `initialOwner` to the deployer.
    constructor() ERC20('Pizza Token', 'PZA') Ownable(msg.sender) {}

    /// @param to Address to mint tokens to.
    /// @param amount Amount of tokens to mint.
    /// @return A boolean that indicates if the operation was successful.
    function mint(address to, uint256 amount) external onlyOwner returns (bool) {
        if (to == address(0)) {
            revert PizzaToken__AddressCannotBeZero();
        }
        if (amount == 0) {
            revert PizzaToken__AmountMustBeMoreThanZero();
        }
        _mint(to, amount);
        return true;
    }
}
