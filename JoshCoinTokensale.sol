// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// Import standard 'JoshCoin' implementation
import "./JoshCoin.sol";

/**
 * @dev 'Tokensale' implementation of the 'JoshCoin' token.
 *
 * Users may mint 1000 tokens per ether until the supply cap of 1,000,000 has been
 * reached. The contract owner may withdraw funds into their own address.
 */
contract JoshCoinTokensale is JoshCoin {
    uint256 internal oneThousandTokens = 1_000 ether;
    uint256 internal oneMillionTokens = 1_000_000 ether;

    /**
     * @dev Withdraws `amount` of contract ether into owner address.
     */
    function withdraw(uint256 amount) public onlyOwner {
        payable(msg.sender).transfer(amount);
    }

    /**
     * @dev `receive` fallback function, if called with >= 1 ether, mints 1,000
     * tokens per ether to the caller's address and returns any change.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - Function called with >= 1 ether.
     * - < 1,000,000 tokens have been minted.
     */
    receive() external payable virtual {
        require(
            msg.value >= 1 ether,
            "JoshCoinTokensale: Send at least 1 ether to mint 1,000 tokens"
        );

        uint256 batchesLeftToMint = (oneMillionTokens - _totalSupply) /
            oneThousandTokens;

        require(
            (batchesLeftToMint > 0),
            "JoshCoinTokensale: Token sale has ended"
        );

        uint256 batchesToMint = msg.value / 1 ether;

        // If requested batches exceed supply, mint as many as possible
        if (batchesToMint > batchesLeftToMint) {
            batchesToMint = batchesLeftToMint;
        }

        // Mint tokens to user address
        uint256 amount = batchesToMint * oneThousandTokens;
        _balances[msg.sender] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), msg.sender, amount);

        // Calculate transaction change
        uint256 batchesMinted = batchesToMint;
        uint256 change = msg.value - (batchesMinted * 1 ether);

        if (change > 0) {
            // Send user change
            payable(msg.sender).transfer(change);
        }
    }
}
