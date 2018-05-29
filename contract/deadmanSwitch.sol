pragma solidity ^0.4.23;

/** Deadman Switch Trustfund: Allow withdraw of funds if checkin function not executed within timeframe
 *
 * @dev Currently testing on Ropsten
 *
 */

/**
 * @title deadmanSwitch
 * @dev ...
 */
contract deadmanSwitch {
  address public owner = msg.sender;
  //ACCOUNT #2
  address public beneficiary = 0xC4d1a08E7F6E6211ffea4B35Aa685a8BE249ECca;
  uint constant year = 31556926;      // Seconds in year
  uint public min_time = 1545739200;  // Tuesday, December 25, 2018 7:00:00 AM GMT-05:00

  /*
   * @dev set to true on initial deploy
   */
  bool public alive = true;
//  uint public balance = 0;

  /*
   * @devConfirm alive (should be once a year, but owner can extend indefinitely)
   */
  uint public checkins = 0;

  // Events
  event CheckIn(address who);     // Log CheckIns
  event CheckAlive(address who);  // Log Queries for alive status


  function checkin() public returns (bool) {
    if (msg.sender == owner || msg.sender == beneficiary) {
      alive = true;
      min_time += year; // Add 1 year to min withdraw time
      checkins++;
      emit CheckIn(msg.sender); // logging event
      return true;
    }
    return false;
  }

  // Need to set alive status before withdrawing funds
  function checkAlive() public returns (bool) {
    if (block.timestamp > min_time) {
      alive = false; // RIP
      emit CheckAlive(msg.sender);
      return true;
    }
  return true;
  }

  // Set new owner
  function transferOwnership(address newOwner) public {
    require(newOwner != address(0) && owner == msg.sender);
    owner = newOwner;
  }

  /* @dev Allow owner to set new beneficiary
   * @params
   */
  function transferBeneficiary(address newBeneficiary) public {
    require(newBeneficiary != address(0) && owner == msg.sender);
    beneficiary = newBeneficiary;
  }

  // Beneficiary can withdraw funds if owner doesn't check in (checked out)
  function withdraw() public {
    require (block.timestamp > min_time && alive != true);
    if (msg.sender == owner || msg.sender == beneficiary) {
      selfdestruct(msg.sender);
    }
  }

  function () public payable {
  //  balance = msg.value;
  }
}
