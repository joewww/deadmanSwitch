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

/** @title DeadmanSwitch
  * @dev Time locked wallet, allow Ether to be withdrawn if owner doesn't call checkin() by min_time
  */
contract DeadmanSwitch is Ownable, Pausable, Destructible {
    address public owner = msg.sender;

    // @dev Defined variables
    using SafeMath for uint;

    // @dev designated beneficiary for the funds within the contract
    // @dev account 3
    address public beneficiary = 0xf46a36B1EAfDa5F7597395EEAB4c89992F851308;

    // @dev Seconds in year
    uint public constant year = 31556926;

    // @dev UNIX Epoch time. Tuesday, December 25, 2018 7:00:00 AM GMT-05:00
    uint public min_time = 1545739200;

    // @dev set to true on initial deploy
    bool public alive = true;
    uint public balance = 0;
    string public ipfsHash;

    // @dev Confirm alive. Should be once a year, but owner can extend indefinitely
    uint public checkins = 0;

    // @dev Log CheckIns
    event CheckIn(address who);
    // @dev Log Queries for alive status
    event CheckAlive(address who);
    // @dev update the ipfs hash of written agreement
    event UpdateIPFS(string hash);

    /** @dev update IPFS image hash */
    function updateIPFS(string _ipfsHash)
      onlyOwner()
      whenNotPaused()
      public
    {
      ipfsHash = _ipfsHash;
      emit UpdateIPFS(ipfsHash);
    }

    /** @return true if the sender is the owner or the beneficary */
    function checkin()
      whenNotPaused()
      public returns (bool)
    {
      if (msg.sender == owner || msg.sender == beneficiary) {
        alive = true;
        // @dev Add 1 year to min withdraw time
        min_time = year.add(min_time);
        checkins++;
        // @dev logging event
        emit CheckIn(msg.sender);
        return true;
      }
      return false;
    }

    /** @dev Need to set alive status before withdrawing funds
      * @return true ### REMOVE return status???
      */
    function checkAlive()
      whenNotPaused()
      public returns (bool)
    {
      emit CheckAlive(msg.sender);
      if (block.timestamp > min_time) {
        // @dev RIP
        alive = false;
        return true;
      }
    return true;
    }

    /** @dev Allow owner to set new beneficiary */
    function transferBeneficiary(address newBeneficiary)
      whenNotPaused()
      public
    {
      require(newBeneficiary != address(0) && owner == msg.sender);
      beneficiary = newBeneficiary;
    }

    // @dev conditions to allow withdraw of funds
    modifier allowedWithdraw() {
      require(block.timestamp > min_time);
      require(alive != true);
      require(msg.sender == owner || msg.sender == beneficiary);
      _;
    }

    /** @dev Beneficiary can withdraw funds if owner doesn't check in (checked out) */
    function withdraw()
      whenNotPaused()
      allowedWithdraw()
      public
    {
      msg.sender.transfer(balance);
      balance = 0;
    }

    /** @dev allow funds to be received */
    function () public payable {
      balance =  balance.add(msg.value);
    }
  }
