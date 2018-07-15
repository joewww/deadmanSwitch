pragma solidity ^0.4.23;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/DeadmanSwitch.sol";

contract TestDeadmanSwitch {

function test_contract_is_initially_unpaused() {
    DeadmanSwitch mycontract = DeadmanSwitch(DeployedAddresses.DeadmanSwitch());
    bool expected = false;
    Assert.equal(mycontract.paused(), expected, "Contract should not be initially paused");
    }
}
