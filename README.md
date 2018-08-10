# deadmanSwitch Contract

This project is a lab to explore a basic implementation of a 'dead mans switch wallet' on the Rinkeby Ethereum test net.

A 'dead mans switch' is a mechanism which is activated after the owner becomes unavailable, such as through death, illness, incarceration, etc. The owner will need to check in periodically by calling the checkin() function. If this function isn't called within a certain timeframe, the funds stored in the contract will become available to a designated beneficiary.

You will need the [Metamask](https://metamask.io/) browser plugin installed, and javascript enabled:

https://joewww.github.io/deadmanSwitch


#### This contract will:

1. Designate an owner, and a primary beneficiary
2. Lock funds up for at least min_time (unix epoch time), which can be extended by the owner for 1 year increments
3. Allow the transfer of ownership, and beneficiary
4. Only allow funds to be withdrawn when min_time is reached


## Local Development Environment

Support for VirtualBox and Docker is provided.

### VirtualBox

Clone repository:

`$ git clone https://github.com/joewww/deadmanSwitch.git`

`$ cd deadmanSwitch/`

Start local blockchain for testing:

`$ ganache-cli`

Install dependencies, compile contract and run unit tests:

`$ truffle install && truffle compile && truffle test`

**Note: you may want to update the beneficiary & contract addresses in these files if you are deploying your own contract for testing:**

 - test/TestDeadmanSwitch.js
 - contracts/DeadmanSwitch.sol
 - js/deadmanSwitch.js

If you are deploying a local contract and want to test it:

`$ npm install http-server`

`http-server -p 8080`

Then, visit local site: http://127.0.0.1:8080


### Docker

NOTE: Publish to dockerhub?
 - So I can do: `$ docker pull`

Clone repository:

`$ git clone https://github.com/joewww/deadmanSwitch.git`

`$ docker build -t deadmanswitch deadmanSwitch`

`$ docker run -d -p 8080:8080 -it --entrypoint "http-server" deadmanswitch`

Then, visit local site: http://127.0.0.1:8080


## Key Functions

#### checkin()

This is intended to be executed ~once a year, and will extend the minimum allowed withdraw time by 1 year.

```javascript
function checkin() public returns (bool) {
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
```

#### checkAlive()

This should be executed to set alive status to false, to allow withdraw function to run successfully.

```javascript
// @dev Need to set alive status before withdrawing funds
function checkAlive() public returns (bool) {
  if (block.timestamp > min_time) {
    alive = false; // RIP
    emit CheckAlive(msg.sender);
    return true;
  }
return true;
}
```

## Tools used

* [remix](https://remix.ethereum.org/) - To test, deploy, and interact with the contract
* [metamask](https://metamask.io/) - Wallet, and to interact via the browser
* [truffle](https://truffleframework.com/) - To compile, test and deploy the contract.
* [ganache-cli](https://github.com/trufflesuite/ganache-cli) - To run a local blockchain for testing/development
* [ethpm](https://www.ethpm.com/) - To manage smart contract library dependencies
* [docker](https://www.docker.com) - To run the web front end in development
* [ipfs](https://ipfs.io) - To display a notarized message by the wallet owner
