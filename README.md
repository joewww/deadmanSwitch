# deadmanSwitch Contract

This project is a lab to explore a basic implementation of a *dead mans switch wallet* on the Rinkeby Ethereum test net.

A *dead mans switch* is a mechanism which is activated after the owner becomes unavailable, such as through death, illness, incarceration, etc. The owner will need to check in periodically by calling the `checkin()` function. If this function isn't called within a certain timeframe, the funds stored in the contract will become available to a designated beneficiary.

This could be viewed as the opposite of a *Proof of Existence DApp*. The owner can attest that they are not available, and allow funds to be transferred to next of kin without the need for an executor of the will, or a 3rd party arbiter.

You will need the [Metamask](https://metamask.io/) browser plugin installed, and javascript enabled:

https://joewww.github.io/deadmanSwitch


#### This contract will:

1. Designate an owner, and a primary beneficiary
2. Lock funds up for at least `min_time` (unix epoch time), which can be extended by the owner for 1 year increments by calling the `checkin()` function
3. Allow the transfer of ownership, and beneficiary
4. Only allow funds to be withdrawn by the beneficiary when `min_time` is reached
5. Store an IPFS hash (`ipfsHash`) in the contract, which is a notarized image from the owner

---

- [Introduction](#deadmanswitch-contract)
- [Local Development Environment](#local-development-environment)
  - [VirtualBox](#virtualbox)
  - [Docker](#docker)
- [Interacting with the contract](#interacting-with-the-contract)
  - [Key Functions](#key-functions)
    - [checkin()](#checkin)
    - [checkAlive()](#checkalive)
    - [withdraw()](#withdraw)
- [Tools used](#tools-used)

## Local Development Environment

Support for VirtualBox and Docker is provided.

### VirtualBox

Clone repository:

`$ git clone https://github.com/joewww/deadmanSwitch.git`

`$ cd deadmanSwitch/`

Start local blockchain for testing (in separate terminal):

`$ ganache-cli`

Install dependencies, compile contract and run unit tests:

`$ truffle install && truffle compile && truffle test`

**Note: you may want to update the beneficiary & contract addresses in these files if you are deploying your own contract for testing:**

 - test/TestDeadmanSwitch.js
 - contracts/DeadmanSwitch.sol
 - js/deadmanSwitch.js

If you are deploying a local contract and want to test it:

`$ npm install http-server`

`$ http-server -p 8080`

Then, visit local site: http://127.0.0.1:8080


### Docker

Download the latest image from Dockerhub:
[![](https://images.microbadger.com/badges/version/joew/deadmanswitch.svg)](https://microbadger.com/images/joew/deadmanswitch "Get your own version badge on microbadger.com")

`$ docker pull joew/deadmanswitch`

To run:

`$ docker run -d -p 8080:8080 -it --entrypoint "http-server" joew/deadmanswitch`

Then, visit local site: http://127.0.0.1:8080

-or- For shell access, so you can run truffle locally:

`$ docker run -it --entrypoint /bin/bash joew/deadmanswitch`


## Interacting with the contract

Modifying this contracts state is restricted to the owner and beneficiary. If you want to interact with this contract, you will need to deploy it to your own test net, with your own beneficiary.

### Key Functions

##### checkin()

This is intended to be executed ~once a year by the owner (or beneficiary if they want), and will extend the minimum allowed withdraw time by 1 year.

```javascript
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
```

##### checkAlive()

This should be called to set `alive` to false after `min_time` is reached, to allow `withdraw()` function to run successfully.

```javascript
/** @dev Need to set alive status before withdrawing funds */
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
```

##### withdraw()

This function is intended to be called by the `beneficiary`, after `alive` is set to false via the `checkAlive()` function. The contracts balance will be sent to the function caller.

```javascript
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
```

## Tools used

* [remix](https://remix.ethereum.org/) - To test, deploy, and interact with the contract
* [metamask](https://metamask.io/) - Wallet, and to interact via the browser
* [truffle](https://truffleframework.com/) - To compile, test and deploy the contract.
* [ganache-cli](https://github.com/trufflesuite/ganache-cli) - To run a local blockchain for testing/development
* [ethpm](https://www.ethpm.com/) - To manage smart contract library dependencies
* [docker](https://www.docker.com) - To run the web front end in development
* [ipfs](https://ipfs.io) - To display a notarized message by the wallet owner
