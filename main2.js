var web3 = new Web3(Web3.givenProvider);
var contractInstance;
//var address = "0x7a2b793bc325324CA4B901273A637a6ac4d8fFe1";
//var address = "0x72c930A4B257C7f254748922063EA1be45C7B1d9";
var address = "0xfa73aC8b8462d1a053a6cA980decC5A8c3160850";
var playerAccount = "";

var tailsCount = 0;
var headsCount = 0;

$(document).ready(async function() {
  //console.log(web3);
  await window.ethereum.enable().then(function(accounts){
    playerAccount = accounts[0];
    contractInstance = new web3.eth.Contract(abi,address,{from: playerAccount});
    console.log(contractInstance) ;
  });

  web3.eth.getBalance(address, function(err, result) {
    if (err) {
     console.log(err)
   } else {
     let res = web3.utils.fromWei(result, "ether") + " ETH"
     console.log(web3.utils.fromWei(result, "ether") + " ETH")
     $("#all-balance").text(res)
    }
  });

  updateInfo();

  $("#deposit-button").click(deposit);
  //pass argument 1 as head,0 as tails
  $("#headsFlip").click({bet: "1"}, flipCoin);
  $("#tailsFlip").click({bet: "0"}, flipCoin);
  $("#get-user-balance").click(getUserBalance);
  $("#get-contract-balance").click(getContractBalance);
  $("#get-prize").click(getPrize);
  $("#fund-contract").click(fundContract);
});

function updateInfo() {
  accountInfo();
  getContractBalance();
  getUserBalance();
}

function getUserBalance(){
  // async - don't know how much will take the response
  contractInstance.methods.getUserBalance(playerAccount).call().then(function(res){
    //console.log(res);
    user_balance = web3.utils.fromWei(res, "ether");
    //console.log(newResult1);
    $("#user-balance").text(user_balance + " ETH") ;
  });
}

function getContractBalance(){
  contractInstance.methods.contractBalance().call().then(function(res1){
    contract_balance = web3.utils.fromWei(res1, "ether");
    $("#contract-balance").text(contract_balance + " ETH");
  });
}


async function accountInfo(){

  const accounts = await window.web3.eth.getAccounts();
  //App = accounts[0];
  $('#account-contract').text(playerAccount);
  const balance = await window.web3.eth.getBalance(playerAccount);
  $('#account-balance').text(window.web3.utils.fromWei(balance, "ether") + " ETH");
}

function getPrize(){
  contractInstance.methods.getPrize().send().then(function(result2){
    console.log(result2);
    //result = web3.utils.fromWei(result2, "ether");
    alert("Balance withdraw");
    //console.log(result);
    updateInfo();
  });
}

function fundContract(){
  contractInstance.methods.addContractBalance()
  .send({
    value: web3.utils.toWei("1","ether")
  })
  .on("transactionHash",function (transactionHash){
    console.log(transactionHash);
  })
  .on("confirmation", function(confirmationNr){
    console.log(confirmationNr);
    //$("#result-output").html("Good Luck to you Sir!");
  })
  .on("receipt",function(receipt){
    console.log(JSON.stringify(receipt));
    updateInfo();
  })

}

function deposit(){

  var config = {value: web3.utils.toWei("1","ether")}
                //gas:100000};
  contractInstance.methods.addUserBalance().send(config)
  .on("transactionHash",function (transactionHash){
    console.log(transactionHash);
  })
  .on("confirmation", function(confirmationNr){
    console.log(confirmationNr);
  })
  .on("receipt",function(receipt){
    console.log(JSON.stringify(receipt));
    updateInfo();
  })
}



function deferFn(callback, ms) {
  setTimeout(callback, ms);
}

function processResult(result) {
  if (result === 'heads') {
     headsCount++;
     $("#headsCount").text(headsCount);
     //heads.innerText = headsCount;
   } else {
     tailsCount++;
     $("#tailsCount").text(tailsCount);
     //tails.innerText = tailsCount;
   }
   updateInfo();
}



function flipCoin(betType){
    var betAmount = $("#bet_input").val();
	alert(betAmount);
    coin.setAttribute('class', '');
    //alert(betType.data.bet);
    contractInstance.methods.tossCoin(betType.data.bet)
    .send({
        //value: web3.utils.toWei("1","ether")
        value:web3.utils.toWei(betAmount, "ether")
    })
    .on("transactionHash", function(transactionHash){
        console.log("transactionHash: " + transactionHash); // .on is used to search for listeners
    })
    .on("confirmation", function(confirmationNr){
        console.log("confirmationNr: " + confirmationNr);
        //getOutput();
    })
    .on("receipt", function(receipt){
        console.log("receipt: " + JSON.stringify(receipt));
        if(receipt.events.logFlipResult.returnValues.result){
          deferFn(function() {
            coin.setAttribute('class', 'animate-heads');
            deferFn(processResult.bind(null, 'heads'), 2900);
          }, 100);
        }else{
          deferFn(function() {
            coin.setAttribute('class', 'animate-tails');
            deferFn(processResult.bind(null, 'tails'), 2900);
          }, 100);
          //alert("Lose!  :( ");
        }
    })
}
