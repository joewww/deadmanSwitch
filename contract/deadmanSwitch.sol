pragma solidity ^0.4.23;

// Deadman Switch Trustfund: Allow withdraw of funds if checkin function not executed within timeframe

// @title deadmanSwitch
contract deadmanSwitch {
  address public owner = msg.sender;

  // ACCOUNT #2
  address public beneficiary = 0x3f1e38f7c085ca03a5ff35f1c354b4fc16645b32;

  // @dev Seconds in year
  uint constant year = 31556926;

  // @dev Tuesday, December 25, 2018 7:00:00 AM GMT-05:00
  uint public min_time = 1545739200;

  // @dev set to true on initial deploy
  bool public alive = true;
  uint public balance = 0;

  // @dev Confirm alive (should be once a year, but owner can extend indefinitely)
  uint public checkins = 0;

  // @dev Log CheckIns
  event CheckIn(address who);
  // @dev Log Queries for alive status
  event CheckAlive(address who);


  function checkin() public returns (bool) {
    if (msg.sender == owner || msg.sender == beneficiary) {
      alive = true;
      // @dev Add 1 year to min withdraw time
      min_time += year;
      checkins++;
      // @dev logging event
      emit CheckIn(msg.sender);
      return true;
    }
    return false;
  }

  // @dev Need to set alive status before withdrawing funds
  function checkAlive() public returns (bool) {
    if (block.timestamp > min_time) {
      alive = false; // RIP
      emit CheckAlive(msg.sender);
      return true;
    }
  return true;
  }

  // @dev Set new owner
  function transferOwnership(address newOwner) public {
    require(newOwner != address(0) && owner == msg.sender);
    owner = newOwner;
  }

  // @dev Allow owner to set new beneficiary
  function transferBeneficiary(address newBeneficiary) public {
    require(newBeneficiary != address(0) && owner == msg.sender);
    beneficiary = newBeneficiary;
  }

  // @dev Beneficiary can withdraw funds if owner doesn't check in (checked out)
  function withdraw() public {
    require (block.timestamp > min_time && alive != true);
    if (msg.sender == owner || msg.sender == beneficiary) {
      selfdestruct(msg.sender);
    }
  }

  function () public payable {
    balance = msg.value;
  }
}
