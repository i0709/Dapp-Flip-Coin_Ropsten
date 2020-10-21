pragma solidity 0.5.12;

contract Ownable {

    address internal owner;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _; // Continue execution;
    }

    // needs to be public
    // run only once, when is created
    //
    constructor () public {
        owner = msg.sender;
    }

}
