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
     * @dev Withdraw `amount` of contract ether into owner address.
     */
    function withdraw(uint256 amount) public onlyOwner {
        address payable to = payable(msg.sender);
        to.transfer(amount);
    }

    /**
     * @dev Receive fallback function, if called with 1 ether, mints 1,000 tokens
     * to the caller's address. Function also requires the total supply of tokens
     * will not exceed 1,000,000.
     */
    receive() external payable {
        uint256 amount = 10**18 * 1_000;

        require(
            msg.value == 1 ether,
            "JoshCoinTokensale: Send 1 ether to mint 1,000 tokens"
        );
        require(
            _totalSupply <= (10**18 * 1_000_000) + amount,
            "JoshCoinTokensale: Token sale has ended"
        );

        _balances[msg.sender] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), msg.sender, amount);
    }
}
