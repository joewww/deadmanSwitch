pragma solidity ^0.4.23;


import "../installed_contracts/zeppelin/contracts/ownership/Ownable.sol";
import "../installed_contracts/zeppelin/contracts/math/SafeMath.sol";
import "../installed_contracts/zeppelin/contracts/lifecycle/Destructible.sol";
import "../installed_contracts/zeppelin/contracts/lifecycle/Pausable.sol";

/* for remix:
import "./Ownable.sol";
import "./SafeMath.sol";
import "./Destructible.sol";
import "./Pausable.sol";
*/

// Deadman Switch Trustfund: Allow withdraw of funds if checkin function not executed within timeframe

// @title DeadmanSwitch

contract DeadmanSwitch is Ownable, Pausable, Destructible {
    address public owner = msg.sender;

    /*
     @dev Defined variables
    */
    using SafeMath for uint;

    // @dev designated beneficiary for the funds within the contract
    // account 3
    address public beneficiary = 0x0c93D3f8532c0A811f011949E4666D30A675D1dD;

    // @dev Seconds in year
    uint public constant year = 31556926;

    // @dev Tuesday, December 25, 2018 7:00:00 AM GMT-05:00
    uint public min_time = 1545739200;

    // @dev set to true on initial deploy
    bool public alive = true;
    uint public balance = 0;
    string public ipfsHash;

    // @dev Confirm alive (should be once a year, but owner can extend indefinitely)
    uint public checkins = 0;

    // @dev Log CheckIns
    event CheckIn(address who);
    // @dev Log Queries for alive status
    event CheckAlive(address who);
    // @dev update the ipfs hash of written agreement
    event UpdateIPFS(string hash);

    function updateIPFS(string _ipfsHash)
      onlyOwner()
      whenNotPaused()
      public
    {
      ipfsHash = _ipfsHash;
      emit UpdateIPFS(ipfsHash);
    }


    function checkin()
      whenNotPaused()
      public returns (bool)
    {
      if (msg.sender == owner || msg.sender == beneficiary) {
        alive = true;
        // @dev Add 1 year to min withdraw time
        min_time = year.add(min_time);  // Add 1 year to min withdraw time
        checkins++;
        // @dev logging event
        emit CheckIn(msg.sender);
        return true;
      }
      return false;
    }

    // @dev Need to set alive status before withdrawing funds
    function checkAlive()
      whenNotPaused()
      public returns (bool)
    {
      if (block.timestamp > min_time) {
        alive = false; // RIP
        emit CheckAlive(msg.sender);
        return true;
      }
    return true;
    }

    // @dev Allow owner to set new beneficiary
    function transferBeneficiary(address newBeneficiary)
      whenNotPaused()
      public
    {
      require(newBeneficiary != address(0) && owner == msg.sender);
      beneficiary = newBeneficiary;
    }

    // @dev Beneficiary can withdraw funds if owner doesn't check in (checked out)
    function withdraw()
      whenNotPaused()
      public
    {
      require (block.timestamp > min_time && alive != true);
      require (msg.sender == owner || msg.sender == beneficiary);
      msg.sender.transfer(balance);
    }

    function () public payable {
      balance = msg.value;
    }
  }
