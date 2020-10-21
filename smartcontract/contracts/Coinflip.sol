pragma solidity 0.5.12;
import "./provableAPI_05.sol";
import "./Ownable.sol";


contract Coinflip is  Ownable, usingProvable{

    //Variables
    uint public contractBalance;
    uint256 public generatedNumber;
    uint256 constant NUM_RANDOM_BYTES_REQUESTED = 1; //256 options combinations (random bytes), configuration parameter

    //Sctructs
    struct Bet {
      address payable user;
      uint256 headsOrTails;
      uint256 betAmount;
    }

    struct Result {
      uint256 reward;
      bool win;
    }


    //Mappings
    mapping (address => Result ) public results;
    mapping (bytes32 => Bet)     public waiting;
    mapping (address => uint)    public balances;
    mapping (address => bool)    public waitingStatus;

    //Constructor
    constructor() public payable {
        contractBalance = 0.5 ether;
        //provable_setProof(proofType_Ledger);
    }

    //Modifiers
    modifier minimumBet(uint256 betValue) {
        require(betValue >= 0.001 ether, "Minimum to play is 001 eth");
        _;
    }

    //Logs
    event logFlipResult(address user, bool result, uint reward);
    event logQueryId(bytes32 queryId);
    event logNewProvableQuery(string description);
    event logWarnNetworkResponse(string error);
    event logGeneratedRandomNumber(uint256 randomNumber);
    event logCallbackResult(bytes32 queryId,string res,bytes _proof);
    event logWithdrawlAll(address owner, uint amount, uint contractBalance);
    event logGetPrize(address indexed  player, uint amount);



    //function only for testing to avoid testnet delays
    function testRandom() public returns(bytes32) {
        bytes32 queryId = bytes32(keccak256(abi.encodePacked(msg.sender)));
        __callback(queryId, "1", bytes("test"));
        return queryId;
    }


    function tossCoin(uint _headsOrTails) public payable minimumBet(msg.value){
      require(waitingStatus[msg.sender] == false, "You are Already Playing!" );
      require(contractBalance != 0 ,"Balance Contract Empty");
      require((msg.value * 2) <= (address(this).balance), "Bet amount exceed the available Balance in the game!");

      //oracle call
      uint256 QUERY_EXECUTION_DELAY = 0;
      uint256 GAS_FOR_CALLBACK = 200000;

      // Random function for testing off-chain
      bytes32 _queryId = testRandom();
      /*
      bytes32 _queryId = provable_newRandomDSQuery(
        QUERY_EXECUTION_DELAY,
        NUM_RANDOM_BYTES_REQUESTED,
        GAS_FOR_CALLBACK
      );
      */

      //set player waiting to true
      waitingStatus[msg.sender] = true;


      //New Bet
      Bet memory newBet;
      newBet.user = msg.sender;
      newBet.headsOrTails = _headsOrTails;
      newBet.betAmount = msg.value;
      waiting[_queryId] = newBet;


      emit logQueryId(_queryId);
      emit logNewProvableQuery("Query sent... Standig by for the anwser");

      /*
      uint256 randomNumber = playerResult[_queryId].randomResult;


      //require(betType == 1 || betType == 0, "Bet must be heads or tails!"); //Heads will be 0 and Tails will be 1
      //require(msg.value <= balances[player], "You can only bet as much as your balance, deposit more please!");
      if((randomNumber == 0 && betType == 0) ||  (randomNumber == 1 && betType == 1)){
        //wins
        betwon = msg.value * 2;
        playerResult[msg.sender] += betwon;
        contractBalance -= betwon;
        winner = true;
      }else{
        //players[msg.sender] -= msg.value;
        contractBalance += msg.value;

      }
      emit flipResult(msg.sender, winner);
      return winner;
      */
    }


    function __callback(bytes32 _queryId, string memory _result, bytes memory _proof) public {
      //require(msg.sender == provable_cbAddress());
      emit logCallbackResult(_queryId,_result, _proof);

      /*
      if(provable_randomDS_proofVerify__returnCode( _queryId, _result, _proof) != 0) {
        emit logWarnNetworkResponse("The proof verification has failed! Network Problem");
      }else{
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
        emit logGeneratedRandomNumber(randomNumber);
        playerResult[_queryId].randomResult = randomNumber;
        playerResult[_queryId].waiting = false;
      }
      */

      uint256 randomNumber = uint256(keccak256(abi.encodePacked(_result))) % 2;
      emit logGeneratedRandomNumber(randomNumber);

      if((randomNumber == 0 && waiting[_queryId].headsOrTails == 0) ||  (randomNumber == 1 && waiting[_queryId].headsOrTails == 1)){

          //new result
          Result memory newResult;
          newResult.win = true;
          newResult.reward = waiting[_queryId].betAmount * 2;
          results[waiting[_queryId].user] = newResult;

          // add reward to user balance
          balances[waiting[_queryId].user] +=  newResult.reward;

          //set waiting status to sender
          waitingStatus[waiting[_queryId].user] = false;

          emit logFlipResult(waiting[_queryId].user, newResult.win, newResult.reward);

          //reset mapping
          delete waiting[_queryId];

      }else{

          //new result
          Result memory newResult;
          newResult.win = false;
          newResult.reward = 0;
          results[waiting[_queryId].user] = newResult;

          //add bet amount to contractBalance
          contractBalance += waiting[_queryId].betAmount;

          //set waiting status to sender
          waitingStatus[waiting[_queryId].user] = false;

          emit logFlipResult(waiting[_queryId].user, newResult.win, newResult.reward);

          //reset mapping
          delete waiting[_queryId];

      }

    }

    function addContractBalance()public payable {
      contractBalance += msg.value;
    }

    function addUserBalance()public payable{
        balances[msg.sender] += msg.value;
    }

    function getUserBalance(address user1)public view returns(uint){
       return balances[user1];
    }


    function getPrize(address payable _player, uint _amount) public returns(uint){
      require (balances[msg.sender] >= _amount, "Not enough funds to withdraw");
      balances[msg.sender] -= _amount;
      _player.transfer( _amount);
      emit logGetPrize( _player, _amount);
      return _amount;
    }


    function withdrawlAll() public onlyOwner {
      uint  toTransfer = address(this).balance;
      contractBalance = contractBalance - toTransfer;
      msg.sender.transfer(toTransfer);
      emit logWithdrawlAll(msg.sender, toTransfer, contractBalance);
    }


}
