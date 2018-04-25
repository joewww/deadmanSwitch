# deadmanSwitch Contract

This project is a lab to explore a basic implementation of a 'dead mans switch wallet' on the Rinkeby Ethereum test net.

You will need the [Metamask](https://metamask.io/) browser plugin installed, and javascript enabled:

https://joewww.github.io/deadmanSwitch/


This contract will:

1. Designate an owner, and a primary beneficiary
2. Lock funds up for at least min_time (unix epoch time), which can be extended by the owner for 1 year increments
3. Allow the transfer of ownership, and beneficiary
4. Only allow funds to be withdrawn when min_time is reached

## Functions

#### checkin()

This is intended to be executed ~once a year, and will extend the minimum allowed withdraw time by 1 year.

```javascript
  function checkin() public returns (bool) {
    if (msg.sender == owner || msg.sender == beneficiary) {
      alive = true;
      min_time += year; // Add 1 year to min withdraw time
      checkins++;
      return true;
    }
    return false;
  }
```

#### checkAlive()

This should be executed to set alive status to false, to allow withdraw function to run successfully.

```javascript
// Need to set alive status before withdrawing funds
function checkAlive() public returns (bool) {
  if (block.timestamp > min_time) {
    alive = false; // RIP
    return true;
  }
return true;
}
```

## Tools used

* [remix](https://remix.ethereum.org/) - To test, deploy, and interact with the contract
* [metamask](https://metamask.io/) - Wallet, and to interact via the browser

## Disclaimer
This is a toy. I don't recommend using this on the main net with real Ether. For learning/testing purposes only.
