//source code: https://github.com/sasukeourad/OTA
//source paper: A. Z. Ourad, B. Belgacem, and K. Salah, “Using blockchain for iot access con- trol and authentication management,” Proceedings of international conference on internet of things, 2018
pragma solidity 0.6.0;

contract Login2 {
  
    event LoginAttempt(address sender, bytes32 token);
    address owner;
    bytes32 public hash;
    string token_raw;
    bytes32 random_number;

    constructor() public {
        owner = msg.sender;
    }
    
    function rand(uint min, uint max) onlyOwner public returns (bytes32){ // min and max are not needed now, some future work idea
        // @audit Just use keccak256(block.timestamp);
        uint256 lastBlockNumber = block.number - 1;
        bytes32 hashVal = bytes32(blockhash(lastBlockNumber));
        return bytes32(hashVal);
    }
    
    function login_admin() onlyOwner public { 
        random_number = rand(1,100);
        hash = keccak256(abi.encode(msg.sender,now,random_number));
        emit LoginAttempt(msg.sender, hash);
    }
    
    modifier onlyOwner {
       require(msg.sender == owner);
        _;
    }
}