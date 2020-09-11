
// Contract Name: Coinflip
const CoinFlip = artifacts.require("Coinflip");

module.exports = function(deployer,network,accounts) {
  deployer.deploy(CoinFlip).then(function(instance){
    instance.addContractBalance({value: web3.utils.toWei('20', 'ether')})
    console.log("Success");
  }).catch(function(err){
    console.log("Deploy failed "+ err);
  });

};
