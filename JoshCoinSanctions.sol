// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import standard 'JoshCoin' implementation
import "./JoshCoin.sol";

/**
 * @dev 'Sanctions' implementation of the 'JoshCoin' token.
 *
 * Government addresses may add addresses to a blacklist, preventing transfer of
 * tokens to that blacklisted address.
 */
contract JoshCoinSanctions is JoshCoin {
    mapping(address => bool) private _government;
    mapping(address => bool) private _blacklist;

    /**
     * @dev Adds contract owner to approved `_government` addresses.
     */
    constructor() JoshCoin() {
        _government[msg.sender] = true;
    }

    /**
     * @dev Requires `msg.sender` to be an approved `_government` address.
     */
    modifier onlyGovernment() {
        require(
            _government[msg.sender],
            "JoshCoinSanctions: Feature only available to approved government addresses"
        );
        _;
    }

    /**
     * @dev Requires `account` to not be blacklisted.
     */
    modifier notBlacklisted(address account) {
        require(
            !_blacklist[account],
            "JoshCoinSanctions: Transfer to account has been blacklisted"
        );
        _;
    }

    /**
     * @dev Updates approved `_government` addresses.
     *
     * Requirements:
     *
     * - `onlyGovernment` modifier.
     */
    function updateGovernmentAddresses(address government, bool approved)
        public
        onlyGovernment
    {
        _government[government] = approved;
    }

    /**
     * @dev Updates `account` blacklist status.
     *
     * Requirements:
     *
     * - `onlyGovernment` modifier.
     */
    function updateBlacklist(address account, bool blacklist)
        public
        onlyGovernment
    {
        _blacklist[account] = blacklist;
    }

    /**
     * @dev Transfers `value` amount of tokens from `msg.sender` address to address
     * `to`.
     *
     * Emits a {Transfer} event and returns true.
     *
     * Requirements:
     *
     * - `sufficientBalance` modifier.
     * - `notBlacklisted` modifier.
     */
    function transfer(address to, uint256 value)
        public
        override
        sufficientBalance(msg.sender, value)
        notBlacklisted(to)
        returns (bool)
    {
        _balances[msg.sender] -= value;
        _balances[to] += value;

        emit Transfer(msg.sender, to, value);

        return true;
    }

    /**
     * @dev Transfers `value` amount of tokens from address `from` to address `to`.
     *
     * Emits a {Transfer} event and returns true.
     *
     * Requirements:
     *
     * - `sufficientAllowance` modifier.
     * - `sufficientBalance` modifier.
     * - `notBlacklisted` modifier.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        override
        sufficientAllowance(from, to, value)
        sufficientBalance(from, value)
        notBlacklisted(to)
        returns (bool)
    {
        _balances[from] -= value;
        _balances[to] += value;

        emit Transfer(from, to, value);

        return true;
    }
}
