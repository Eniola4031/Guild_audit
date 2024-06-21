// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

contract AttackVector {
    mapping(address => uint256) public balances;
    address public owner;
    uint256 public totalSupply;
    bool public paused;
    address[] public users;
    mapping(address => bool) public isAdmin;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Pause();
    event Unpause();

    constructor(uint256 _initialSupply) {
        owner = msg.sender;
        totalSupply = _initialSupply;
        balances[msg.sender] = _initialSupply;
        isAdmin[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    modifier whenNotPaused() {
        require(!paused, "Pausable: paused");
        _;
    }
            //frontrunning
            //cross-contract re-entrancy
    function transfer(address _to, uint256 _value) external whenNotPaused returns (bool success) {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function pause() public onlyOwner {
        paused = true;
        emit Pause();
    }

    function unpause() public onlyOwner {
        paused = false;
        emit Unpause();
    }
            //overflow
            //access control ish
    function mint(address _to, uint256 _value) public {
        require(isAdmin[msg.sender], "Only admin can mint tokens");
        totalSupply += _value;
        balances[_to] += _value;
    }
            //underflow
            //access control ish
    function burn(uint256 _value) public {
        require(balances[msg.sender] >= _value, "Insufficient balance");
        balances[msg.sender] -= _value;
        totalSupply -= _value;
    }
            //access control ish
    function addAdmin(address _admin) public onlyOwner {
        isAdmin[_admin] = true;
    }

    function removeAdmin(address _admin) public onlyOwner {
        isAdmin[_admin] = false;
    }
            //unrestricted array size
            //no access control for admin
    function addUser(address _user) public onlyOwner() {
        users.push(_user);
    }

    function getUserCount() public view returns (uint256) {
        return users.length;
    }
            //re-entrant
            //unchecked external call
            //forced ETH transfer
            //no event emission
    function withdraw(address _to, uint256 _amount) public {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        (bool success, ) = _to.call{value: _amount}("");
        require(success, "Transfer failed");
    }

    receive() external payable {}
}