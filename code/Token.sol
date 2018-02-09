pragma solidity ^0.4.16;

contract Token {
    /* This creates an array with all balances */
    string public name;
    uint256 public initialSupply;
    uint256 public supply; // keeps track of current supply
    uint256 public maxSupply = 500; //set limit
    uint256 public challenge; 

    mapping (address => uint256) public balanceOf;

    function Token(
        uint256 initSupply,
        string tokenName
    )   public { 
        balanceOf[msg.sender] = initialSupply;              // Give the creator all initial tokens
        name = tokenName;
        initialSupply = initSupply; 
        supply = initSupply;
        challenge = 4;
    }
    
    function transfer(address recipient, uint256 value) public {
        _transfer(recipient, value);
    }

    /* Send coins */
    function _transfer(address recipient, uint256 value) internal {
        require(balanceOf[msg.sender] >= value);        
        require(balanceOf[recipient] + value >= balanceOf[recipient]); // Check for overflows
        balanceOf[msg.sender] -= value;                    
        balanceOf[recipient] += value;                           
    }
    
    function _mine() internal { 
        require(supply < maxSupply);
        uint8 increment = 10;
        if(supply + increment > maxSupply) {
            increment = (uint8)(maxSupply - supply);   
        }
        balanceOf[msg.sender] += increment;
        supply += increment;
    }
    
    // Simple POW concept - 
    // find x and y such that x * y == challenge
    function minePow(uint256 x, uint256 y) {
        require(x * y == challenge);
        _mine();
        challenge += 2;
    }
}