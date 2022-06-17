// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import standard 'JoshCoin' implementation
import "./JoshCoin.sol";

/**
 * @dev 'Tokensale' implementation of the 'JoshCoin' token.
 *
 * Users may mint 1000 tokens per ether until the supply cap of 1,000,000 has been
 * reached. The contract owner may withdraw funds into their own address.
 */
contract JoshCoinTokensale is JoshCoin {
    /**
     * @dev Withdraws `amount` of contract ether into owner address.
     */
    function withdraw(uint256 amount) public onlyOwner {
        address payable ownerAddress = payable(msg.sender);
        ownerAddress.transfer(amount);
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

        uint256 tokensLeftToMint = (10**18 *
            1_000_000 -
            (_totalSupply / 10**18));

        require(
            (tokensLeftToMint - 1_000 >= 0),
            "JoshCoinTokensale: Token sale has ended"
        );

        uint256 thousandsOfTokensToMint = msg.value / 1 ether;

        // If requested amount exceeds supply, how many batches of 1,000 can be minted?
        if ((thousandsOfTokensToMint * 1_000) > tokensLeftToMint) {
            thousandsOfTokensToMint = tokensLeftToMint / 1_000;
        }

        // Mint tokens to user address
        uint256 amount = thousandsOfTokensToMint * (1_000 * 10**18);
        _balances[msg.sender] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), msg.sender, amount);

        // Calculate transaction change
        uint256 thousandsOfTokensMinted = thousandsOfTokensToMint;
        uint256 change = msg.value - (thousandsOfTokensMinted * 1 ether);

        if (change > 0) {
            // Send user change
            address payable userAddress = payable(msg.sender);
            userAddress.transfer(change);
        }
    }
}
