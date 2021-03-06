// SPDX-License-Identifier: MIT

pragma solidity 0.8.7;

// Import 'JoshCoinTokensale' implementation of 'JoshCoin'
import "./JoshCoinTokensale.sol";

/**
 * @dev 'Token Transfer' implementation of the 'JoshCoin' token.
 */
contract JoshCoinTokenTransfer is JoshCoinTokensale {
    /**
     * @dev Allows users to sell batches of 1,000 tokens for 0.5 ether.
     *
     * Requirements:
     *
     * - `sufficientAllowance` modifier.
     * - `sufficientBalance` modifier.
     * - Function called with `amount` of >= 1,000 tokens
     * - Contract contains at least 0.5 ether to pay `msg.sender`
     */
    function sellTokens(uint256 amount)
        public
        sufficientAllowance(msg.sender, address(this), amount)
        sufficientBalance(msg.sender, amount)
    {
        require(
            amount >= oneThousandTokens,
            "JoshCoinTokenTransfer: Send at least 1,000 tokens to receive 0.5 ether"
        );

        uint256 contractEtherBalance = address(this).balance;

        require(
            contractEtherBalance >= 0.5 ether,
            "JoshCoinTokenTransfer: Insufficient contract ether balance"
        );

        uint256 batchesToSell = amount / 1_000;

        // If requested amount exceeds contract ether, how many batches of 1,000 can be sold?
        if ((batchesToSell * 0.5 ether) > contractEtherBalance) {
            batchesToSell = contractEtherBalance / 0.5 ether;
        }

        // Sell tokens from user address
        uint256 tokenAmount = batchesToSell * oneThousandTokens;
        _balances[msg.sender] -= tokenAmount;
        _balances[address(this)] += tokenAmount;

        payable(msg.sender).transfer(batchesToSell * 0.5 ether);
    }

    /**
     * @dev Mints as many batches as possible <= `batchesToPurchase` to `msg.sender` account.
     *
     * Emits a {Transfer} event and returns `batchesToMint` (batches successfully minted).
     */
    function mintTokenBatches(
        uint256 batchesLeftToMint,
        uint256 batchesToPurchase
    ) private returns (uint256) {
        uint256 batchesToMint;

        if (batchesLeftToMint >= batchesToPurchase) {
            batchesToMint = batchesToPurchase;
        } else {
            batchesToMint = batchesLeftToMint;
        }

        // Mint tokens to user address
        uint256 tokensToMint = batchesToMint * oneThousandTokens;
        _balances[msg.sender] += tokensToMint;
        _totalSupply += tokensToMint;

        emit Transfer(address(0), msg.sender, tokensToMint);

        return batchesToMint;
    }

    /**
     * @dev Sells as many batches held by contract as possible <= `batchesToPurchase`
     * to `msg.sender`.
     *
     * Emits a {Transfer} event and returns true.
     */
    function sellBatchesHeldByContract(
        uint256 batchesHeldByContract,
        uint256 batchesToPurchase
    ) private returns (uint256) {
        uint256 batchesToSellFromContract;

        if (batchesHeldByContract >= batchesToPurchase) {
            batchesToSellFromContract = batchesToPurchase;
        } else {
            batchesToSellFromContract = batchesHeldByContract;
        }

        // Sell tokens held by contract to user
        uint256 tokensToSell = batchesToSellFromContract * oneThousandTokens;
        _balances[address(this)] -= tokensToSell;
        _balances[msg.sender] += tokensToSell;

        emit Transfer(address(this), msg.sender, tokensToSell);

        return batchesToSellFromContract;
    }

    /**
     * @dev Overrides parent contract's `receive` function to allow users to
     * purchase batches of tokens held by contract at a price of 1 ether per 1,000 if
     * tokensale (minting) has ended.
     *
     * May emit a {Transfer} event.
     *
     * Requirements:
     *
     * - Function called with >= 1 ether.
     * - If tokens can't be minted, contract must hold >= 1,000 tokens
     */
    receive() external payable override {
        require(
            msg.value >= 1 ether,
            "JoshCoinTokensale: Send at least 1 ether to mint 1,000 tokens"
        );

        uint256 batchesLeftToMint = (oneMillionTokens - _totalSupply) /
            oneThousandTokens;
        uint256 batchesToPurchase = msg.value / 1 ether;
        uint256 batchesPurchased;

        // If at least one batch of 1,000 tokens can be minted
        if (batchesLeftToMint > 0) {
            batchesPurchased = mintTokenBatches(
                batchesLeftToMint,
                batchesToPurchase
            );
        }

        // If token batches still need to be purchased (could not be minted)
        if (batchesPurchased != batchesToPurchase) {
            uint256 batchesHeldByContract = _balances[address(this)] /
                oneThousandTokens;

            if (batchesHeldByContract > 0) {
                batchesPurchased = sellBatchesHeldByContract(
                    batchesHeldByContract,
                    batchesToPurchase - batchesPurchased
                );
            }
        }

        // If no tokens were successfully purchased
        if (batchesPurchased == 0) {
            revert(
                "JoshCoinTokensale: Tokensale ended and insufficient tokens held by contract"
            );
        }

        // Calculate user change
        uint256 change = msg.value - (batchesPurchased * 1 ether);

        if (change > 0) {
            // Send user change
            payable(msg.sender).transfer(change);
        }
    }
}
