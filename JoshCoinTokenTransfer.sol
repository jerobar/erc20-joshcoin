// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import standard 'JoshCoin' implementation
import "./JoshCoinTokensale.sol";

/**
 * @dev 'Token Transfer' implementation of the 'JoshCoin' token.
 */
contract JoshCoinTokenTransfer is JoshCoinTokensale {
    /**
     * @dev Allows users to sell 1,000 of their tokens for 0.5 ether.
     *
     * Requirements:
     *
     * - `sufficientAllowance` modifier.
     * - `sufficientBalance` modifier.
     * - Function called with `amount` of 1,000 tokens
     * - Contract contains sufficient ether to pay `msg.sender`
     */
    function sellTokens(uint256 amount)
        public
        sufficientAllowance(msg.sender, address(this), amount)
        sufficientBalance(msg.sender, amount)
    {
        require(
            amount == 10**18 * 1_000,
            "JoshCoinTokenTransfer: Send 1,000 tokens to receive 0.5 ether"
        );
        require(
            address(this).balance >= 0.5 ether,
            "JoshCoinTokenTransfer: Insufficient contract ether balance"
        );

        _balances[address(this)] += amount;
        _balances[msg.sender] -= amount;

        address payable to = payable(msg.sender);
        to.transfer(0.5 ether);
    }

    /**
     * @dev Overrides parent contract's `receive` function to allow users to
     * purchase tokens held by contract at a price of 1 ether per 1,000 if
     * token sale has ended.
     *
     * Requirements:
     *
     * - Function called with 1 ether.
     * - If tokens can't be minted, contract must hold >= 1,000 tokens
     */
    receive() external payable override {
        uint256 amount = 10**18 * 1_000;

        require(
            msg.value == 1 ether,
            "JoshCoinTokensale: Send 1 ether to mint 1,000 tokens"
        );

        // If 1,000,000 tokens have already been minted
        if (_totalSupply > (10**18 * 1_000_000) + amount) {
            // If contract holds sufficient tokens
            if (_balances[address(this)] >= amount) {
                // Sell tokens held by contract
                _balances[address(this)] -= amount;
                _balances[msg.sender] += amount;

                emit Transfer(address(this), msg.sender, amount);
            } else {
                revert(
                    "JoshCoinTokensale: Tokensale ended and insufficient tokens held by contract"
                );
            }
        } else {
            // Mint tokens
            _balances[msg.sender] += amount;
            _totalSupply += amount;

            emit Transfer(address(0), msg.sender, amount);
        }
    }
}
