pragma solidity 0.5.12;


contract Coinflip {
    uint public contractBalance;

    // The keyword "public" makes those variables
    // easily readable from outside.
    //address public owner;


    mapping (address => uint) public players;


    event flipResult(address player, bool result);

    modifier minimumBet(uint256 betValue) {
        require(betValue >= 0.001 ether, "Minimum to play is 001 eth");
        _;
    }

    function getPrize() public returns(uint){
      uint toTransfer = players[msg.sender];
      players[msg.sender] = 0;
      msg.sender.transfer(toTransfer);
      return toTransfer;
    }

    function tossCoin(uint betType) public payable minimumBet(msg.value) returns (bool result){
      bool winner = false;
      uint256 betwon = 0;
      //uint currentContractBalance = getContractBalance();
      require(contractBalance != 0 ,"Balance Contract Empty");
        //uint bet = msg.value;
        //balances[player] += bet;
        //require(betType == 1 || betType == 0, "Bet must be heads or tails!"); //Heads will be 0 and Tails will be 1
      //require(msg.value <= balances[player], "You can only bet as much as your balance, deposit more please!");
      if((random() == 0 && betType == 0) ||  (random() == 1 && betType == 1)){
        //wins
        betwon = msg.value * 2;
        players[msg.sender] += betwon;
        contractBalance -= betwon;
        winner = true;
      }else{
        //players[msg.sender] -= msg.value;
        contractBalance += msg.value;
        
      }
      emit flipResult(msg.sender, winner);
      return winner;
    }

    function addContractBalance()public payable {
      contractBalance += msg.value;
    }

    function addUserBalance()public payable{
        players[msg.sender] += msg.value;
    }

    function getUserBalance(address user1)public view returns(uint){
       return players[user1];
    }

    function random() private view returns(uint){
        return now % 2;
    }
}
