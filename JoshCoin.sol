// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Token Standard.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        external
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) external returns (bool success);

    function approve(address _spender, uint256 _value)
        external
        returns (bool success);

    function allowance(address _owner, address _spender)
        external
        view
        returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );
}

/**
 * @dev Implementation of the ERC20 Token Standard for 'JoshCoin'.
 */
contract JoshCoin is IERC20 {
    uint256 internal _totalSupply;
    mapping(address => uint256) internal _balances;
    mapping(address => mapping(address => uint256)) internal _allowances;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    address internal _owner;

    /**
     * @dev Sets values for {_name}, {_symbol}, {_decimals}, and {_owner}.
     */
    constructor() {
        _name = "JoshCoin";
        _symbol = "JOSH";
        _decimals = 18;

        _owner = msg.sender;
    }

    /**
     * @dev Requires `account` balance is >= `value`.
     */
    modifier sufficientBalance(address account, uint256 value) virtual {
        require(
            _balances[account] >= value,
            "JoshCoin: insufficient token balance"
        );
        _;
    }

    /**
     * @dev Requires `sender` address has sufficient allowance to transfer `value`
     * from `account` address.
     */
    modifier sufficientAllowance(
        address account,
        address sender,
        uint256 value
    ) virtual {
        uint256 senderAllowance = allowance(account, sender);
        require(senderAllowance >= value, "JoshCoin: insufficient allowance");
        _;
    }

    /**
     * @dev Requires `msg.sender` is contract `_owner`.
     */
    modifier onlyOwner() virtual {
        require(
            msg.sender == _owner,
            "JoshCoin: Feature only available to contract owner"
        );
        _;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view virtual returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used when representing token values.
     */
    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the total token supply.
     */
    function totalSupply() public view virtual override returns (uint) {
        return _totalSupply;
    }

    /**
     * @dev Returns the token balance of the provided `owner` address.
     */
    function balanceOf(address owner)
        public
        view
        virtual
        override
        returns (uint256)
    {
        return _balances[owner];
    }

    /**
     * @dev Transfers `value` amount of tokens from `msg.sender` address to address
     * `to`.
     *
     * Emits a {Transfer} event and returns true.
     */
    function transfer(address to, uint256 value)
        public
        virtual
        override
        sufficientBalance(msg.sender, value)
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
     * - `msg.sender` must have sufficient allowance for `from` address.
     * - `from` address token balance must be >= `value` of transfer.
     */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        public
        virtual
        override
        sufficientAllowance(from, to, value)
        sufficientBalance(from, value)
        returns (bool)
    {
        _balances[from] -= value;
        _balances[to] += value;

        emit Transfer(from, to, value);

        return true;
    }

    /**
     * @dev Allows `spender` address to withdraw from `msg.sender` address account
     * multiple times, up to the `value` amount.
     *
     * Emits an {Approval} event and returns true.
     *
     * If this function is called again it overwrites the current allowance with
     * `value`.
     */
    function approve(address spender, uint256 value)
        public
        virtual
        override
        returns (bool success)
    {
        _allowances[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;
    }

    /**
     * @dev Returns the remaining amount `spender` address is allowed to withdraw
     * from `owner` address.
     */
    function allowance(address owner, address spender)
        public
        view
        virtual
        override
        returns (uint256 remaining)
    {
        return _allowances[owner][spender];
    }

    /**
     * @dev Increases total supply of tokens by `amount`.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `onlyOwner` modifier.
     */
    function mint(uint amount) public virtual onlyOwner {
        _balances[msg.sender] += amount;
        _totalSupply += amount;

        emit Transfer(address(0), msg.sender, amount);
    }
}
