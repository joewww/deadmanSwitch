var DeadmanSwitch = artifacts.require("./DeadmanSwitch.sol");

module.exports = function(deployer) {
  deployer.deploy(DeadmanSwitch);
};
