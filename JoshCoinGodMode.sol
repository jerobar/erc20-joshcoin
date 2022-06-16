// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import standard 'JoshCoin' implementation
import "./JoshCoin.sol";

/**
 * @dev 'God Mode' implementation of the 'JoshCoin' token.
 *
 * Special features are available only to the contract owner.
 */
contract JoshCoinGodMode is JoshCoin {
    /**
     * @dev Overrides the 'JoshCoin' contract's `sufficientAllowance` modifer to
     * bypass the allowance check if caller is contract owner.
     *
     * This anables the 'God mode' functionality of allowing the owner to
     * authoritatively transfer from any address.
     */
    modifier sufficientAllowance(
        address account,
        address sender,
        uint256 value
    ) override {
        if (msg.sender == _owner) {
            _;
        } else {
            uint256 senderAllowance = allowance(account, sender);
            require(
                senderAllowance >= value,
                "JoshCoin: insufficient allowance"
            );
            _;
        }
    }

    /**
     * @dev Mints `amount` tokens to any `recipient` address.
     *
     * Requirements:
     *
     * - `onlyOwner` modifier.
     */
    function mintTokensToAddress(address recipient, uint256 amount)
        public
        onlyOwner
    {
        _balances[recipient] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), recipient, amount);
    }

    /**
     * @dev Transfers `amount` tokens from `target` address to contract owner.
     *
     * Requirements:
     *
     * - `onlyOwner` modifier.
     */
    function reduceTokensAtAddress(address target, uint256 amount)
        public
        onlyOwner
    {
        authoritativeTransferFrom(target, msg.sender, amount);
    }

    /**
     * @dev Transfers `amount` from address `from` to address `to`.
     *
     * Requirements:
     *
     * - `sufficientBalance` modifier.
     * - `onlyOwner` modifier.
     */
    function authoritativeTransferFrom(
        address from,
        address to,
        uint256 amount
    ) public sufficientBalance(from, amount) onlyOwner {
        transferFrom(from, to, amount);
    }
}
