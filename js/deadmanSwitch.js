function log(message) {
  $('#log').append($('<p>').text(message));
  $('#log').scrollTop($('#log').prop('scrollHeight'));
}

function error(message) {
  $('#log').append($('<p>').addClass('dark-red').text(message));
  $('#log').scrollTop($('#log').prop('scrollHeight'));
}

function waitForReceipt(hash, cb) {
  web3.eth.getTransactionReceipt(hash, function (err, receipt) {
    if (err) {
      error(err);
    }

    if (receipt !== null) {
      // Transaction went through
      if (cb) {
        cb(receipt);
      }
    } else {
      // Try again in 1 second
      window.setTimeout(function () {
        waitForReceipt(hash, cb);
      }, 1000);
    }
  });
}

// Contract address on Rinkeby testnet
// https://rinkeby.etherscan.io/address/0xD2c4d7c23c73b64b3E266A1c097686F7B8436c42
var address = "0xD2c4d7c23c73b64b3E266A1c097686F7B8436c42";

var abi = [ { "constant": false, "inputs": [], "name": "checkAlive", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [], "name": "checkin", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "newBeneficiary", "type": "address" } ], "name": "transferBeneficiary", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": false, "inputs": [ { "name": "newOwner", "type": "address" } ], "name": "transferOwnership", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "payable": true, "stateMutability": "payable", "type": "fallback" }, { "constant": false, "inputs": [], "name": "withdraw", "outputs": [], "payable": false, "stateMutability": "nonpayable", "type": "function" }, { "constant": true, "inputs": [], "name": "alive", "outputs": [ { "name": "", "type": "bool" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "balance", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "beneficiary", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "checkins", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "min_time", "outputs": [ { "name": "", "type": "uint256" } ], "payable": false, "stateMutability": "view", "type": "function" }, { "constant": true, "inputs": [], "name": "owner", "outputs": [ { "name": "", "type": "address" } ], "payable": false, "stateMutability": "view", "type": "function" } ];

$(function () {
  var deadManSwitchWallet;
// minimum time function
  $('#min_time').click(function (e) {
    e.preventDefault();

    deadManSwitchWallet.min_time.call(function (err, result) {
      if (err) {
        return error(err);
      } else {
        log("min_time call executed successfully.");
      }

      var humanDate = new Date(result * 1000).toUTCString();

      $('#min_time').text(humanDate.toString());
    });
  });
// balance function
  $('#balance').click(function (e) {
    e.preventDefault();

    deadManSwitchWallet.balance.call(function (err, result) {
      if (err) {
        return error(err);
      } else {
        log("balance call executed successfully.");
      }

      $('#balance').text(web3.fromWei(result.toString()));
    });
  });

// withdraw function
  $('#withdraw').click(function (e) {
    e.preventDefault();

    if(web3.eth.defaultAccount === undefined) {
      return error("No accounts found. If you're using MetaMask, " +
                   "please unlock it first and reload the page.");
    }

    log("Calling withdraw...");

    deadManSwitchWallet.withdraw.sendTransaction(function (err, hash) {
      if (err) {
        return error(err);
      }

      waitForReceipt(hash, function () {
        log("Transaction succeeded. " +
            "Withdraw function was called.");
      });
    });
  });

// checkAlive function
  $('#checkAlive').click(function (e) {
    e.preventDefault();

    if(web3.eth.defaultAccount === undefined) {
      return error("No accounts found. If you're using MetaMask, " +
                   "please unlock it first and reload the page.");
    }

    log("Calling checkAlive function...");

    deadManSwitchWallet.checkAlive.sendTransaction(function (err, hash) {
      if (err) {
        return error(err);
      }

      waitForReceipt(hash, function () {
        log("Transaction succeeded. " +
            "checkAlive function was called.");
      });
    });
  });

// alive? function
  $('#alive').click(function (e) {
    e.preventDefault();

    log("Checking if the owner is alive...");

    deadManSwitchWallet.alive.call(function (err, result) {
      if (err) {
        return error(err);
      } else {
        log("alive call executed successfully.");
      }
// check if alive is true
      if(result) {
        $('#alive').text("The owner is still alive!");
      } else {
        $('#alive').text("The owner is ded :( RIP");
      }
    });
  });
// checkin function
  $('#checkin').click(function (e) {
    e.preventDefault();

    if(web3.eth.defaultAccount === undefined) {
      return error("No accounts found. If you're using MetaMask, " +
                   "please unlock it first and reload the page.");
    }

    log("Calling checkin...");

    deadManSwitchWallet.checkin.sendTransaction(function (err, hash) {
      if (err) {
        return error(err);
      }

      waitForReceipt(hash, function () {
        log("Transaction succeeded. " +
            "Check in was called. New min time is set.");
      });
    });
  });

  if (typeof(web3) === "undefined") {
    error("Unable to find web3. " +
          "Please run MetaMask (or something else that injects web3).");
  } else {
    log("Found injected web3.");
    web3 = new Web3(web3.currentProvider);

    // network detection
    web3.version.getNetwork((err, netId) => {
      switch (netId) {
        case "1":
          log('This is mainnet')
          break
        case "2":
          log('This is the deprecated Morden test network.')
          break
        case "3":
          log('This is the ropsten test network.')
          break
        case "4":
          log('This is the Rinkeby test network.')
          connect();
          break
        case "42":
          log('This is the Kovan test network.')
          break
        default:
          log('This is an unknown network.')
      }
    });

    function connect() {
      log("Connected to Rinkeby...");
      deadManSwitchWallet = web3.eth.contract(abi).at(address);
      $('#balance').click();
      $('#min_time').click();
      $('#alive').click();
    }
  }
});