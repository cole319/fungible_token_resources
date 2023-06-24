//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface IERC20 {

    //Function Definitions
    function totalSupply() external view returns (uint256);
    
    function balanceOf(address account) external view returns (uint256);
    
    function transfer(address recipient, uint256 amount) external returns (bool);
    
    function allowance(address owner, address spender) external view returns (uint256);
    
    function approve(address spender, uint256 amount) external returns (bool);
    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function transferOwnership(address newOwner) external returns(bool);
    
    //Events
    event Transfer(address indexed from, address indexed to, uint256 value);
    
    event Approval(address indexed owner, address indexed spender, uint256 value);

    event OwnershipTransferred(address indexed newOwner);
}


contract ERC20 is IERC20 {
    //State variables
    address payable private _owner;

    uint256 immutable private _cap;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    

    modifier onlyOwner {
        require(_owner == msg.sender, "Only Owner can call this function");
        _;
    }
    
    constructor (string memory name_, string memory symbol_, uint256 cap_) {
        require(cap_ > 0, "Cap cannot be 0");

        _owner = payable(msg.sender); 
        _name = name_;
        _symbol = symbol_;
        _cap = convertEth(cap_);
    }

   
    function name() public view virtual returns (string memory) {
        return _name;
    }


    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }


    function cap() public view virtual returns (uint256) {
        return _cap;
    }

  
    function decimals() public view virtual returns (uint8) {
        return 18;
    }


    function convertEth(uint256 amount) internal view returns(uint256) {
        uint256 convertedAmount = amount*(10**decimals());
        return convertedAmount;
    }

   
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

   
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

   
    function transfer(address recipient, uint256 amount) public virtual override onlyOwner returns (bool) {
        uint256 amountConverted = amount*(10**decimals());
        _transfer(msg.sender, recipient, amountConverted);
        return true;
    }

   
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

   
    function approve(address spender, uint256 amount) public virtual override onlyOwner returns (bool) {
        uint256 amountConverted = convertEth(amount);

        _approve(msg.sender, spender, amountConverted);

        return true;
    }

   
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][msg.sender];

        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");

        _approve(sender, msg.sender, currentAllowance - amount);

        return true;
    }


    function transferOwnership(address newOwner) external virtual onlyOwner returns(bool) {
        require(newOwner != address(0));

        _transferOwnership(newOwner);

        return true;
    }


    function mint(uint256 amount) external onlyOwner {
        uint256 amountConverted = convertEth(amount);

        require(ERC20.totalSupply() + amountConverted <= cap(), "ERC20Capped: cap exceeded");

        _mint(msg.sender, amountConverted);
    }


    function burn(uint256 amount) external onlyOwner {
        uint256 amountConverted = convertEth(amount);
        uint256 accountBalance = _balances[msg.sender];

        // require(ERC20.totalSupply() + amountConverted <= cap(), "ERC20Capped: cap exceeded");
        require(accountBalance >= amountConverted, "ERC20: burn amount exceeds balance");

        _burn(msg.sender, amountConverted, accountBalance);
    }


   
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        
        require(sender != address(0), "ERC20: transfer from the zero address");

        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    
    function _mint(address account, uint256 amount) internal virtual {
        
        _beforeTokenTransfer(address(0), account, amount);
        
        _totalSupply += amount;
        _balances[account] += amount;

        emit Transfer(address(0), account, amount);
    }

   
    function _burn(address account, uint256 amount, uint balance) internal virtual {
        

        // require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);
        
         _balances[account] = balance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    
    function _approve(address account, address spender, uint256 amount) internal virtual {

        require(account != address(0), "Approve from the zero address");

        require(spender != address(0), "Approve to the zero address");

        _allowances[account][spender] = amount;
        emit Approval(account, spender, amount);
    }


    function _transferOwnership(address newOwner) internal virtual {
        //Assigned to state variable
        _owner = payable(newOwner);
        
        emit OwnershipTransferred(newOwner);
    }

    //Hook
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}