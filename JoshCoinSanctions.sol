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

    modifier onlyGovernment() {
        require(
            _government[msg.sender],
            "JoshCoinSanctions: Feature only available to government addresses"
        );
        _;
    }

    modifier notBlacklisted(address account) {
        require(
            !_blacklist[account],
            "JoshCoinSanctions: Transfer to account has been blacklisted"
        );
        _;
    }

    function addGovernmentAddress(address government) public onlyOwner {
        _government[government] = true;
    }

    function updateBlacklist(address account, bool blacklist)
        public
        onlyGovernment
    {
        _blacklist[account] = blacklist;
    }

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
