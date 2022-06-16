// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Token Standard.
 */
interface IERC20 {
    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);

    function transfer(address _to, uint256 _value)
        public
        returns (bool success);

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success);

    function approve(address _spender, uint256 _value)
        public
        returns (bool success);

    function allowance(address _owner, address _spender)
        public
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
    uint256 private totalSupply;
    mapping(address => uint256) private balances;
    mapping(address => mapping(address => uint256)) private allowances;

    string private name;
    string private symbol;
    uint8 private decimals;

    address private owner;

    /**
     * @dev Sets values for {name}, {symbol}, {decimals}, and {owner}.
     */
    constructor() {
        name = "JoshCoin";
        symbol = "JOSH";
        decimals = 18;

        owner = msg.sender;
    }

    /**
     * @dev Returns the token name.
     */
    function name() public view returns (string memory) {
        return name;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public view returns (string memory) {
        return symbol;
    }

    /**
     * @dev Returns the number of decimals used when representing token values.
     */
    function decimals() public view returns (uint8) {
        return decimals;
    }

    /**
     * @dev Returns the total token supply.
     */
    function totalSupply() public view returns (uint) {
        return totalSupply;
    }

    /**
     * @dev Returns the token balance of the provided address.
     */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

    /**
     * @dev Transfers {_value} amount of tokens to address {_to} and emits a {Transfer} event.
     */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(
            balances[msg.sender] >= _value,
            "ERC20: insufficient token balance"
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);

        return true;
    }

    /**
     * @dev Transfers {_value} amount of tokens from address {_from} to address {_to} and emits a {Transfer} event.
     */
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool) {
        uint256 senderAllowance = allowance(_from, msg.sender);
        require(senderAllowance >= _value, "ERC20: insufficient allowance")

        require(balances[_from] >= _value, "ERC20: insufficient token balance");

        balances[_from] -= _value;
        balances[_to] += _value;

        emit Transfer(_from, _to, value);

        return true;
    }

    /**
     * @dev Allows {_spender} to withdraw from msg.sender's account multiple times, up to the {_value} amount.
     * If this function is called again it overwrites the current allowance with {_value}. Emits an {Approve} 
     * event and returns true.
     */
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowances[msg.sender][_spender] = _value;

        emit Approve(msg.sender, _spender, _value);

        return true;
    }

    /**
     * @dev Returns the remaining amount {_spender} is allowed to withdraw from {_owner}.
     */
    function allowance(address _owner, address _spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowances[_owner][_spender];
    }

    // function mint(uint amount) external { // not part of ERC20 standard
    //     balanceOf[msg.sender] += amount;
    //     totalSupply += amount;

    //     emit Transfer(address(0), msg.sender, amount);
    // }

    // function burn(uint amount) external { // not part of ERC20 standard
    //     balanceOf[msg.sender] -= amount;
    //     totalSupply -= amount;

    //     emit Transfer(msg.sender, address(0), amount);
    // }
}
