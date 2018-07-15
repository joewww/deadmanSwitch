var DeadmanSwitch = artifacts.require("DeadmanSwitch");

// taken from OpenZeppelin for now.
async function expectThrow(promise) {
  try {
    await promise;
  } catch (error) {
    const revert = error.message.search('revert') >= 1;
    const invalidOpcode = error.message.search('invalid opcode') >= 0;
    const outOfGas = error.message.search('out of gas') >= 0;
    assert(
      invalidOpcode || outOfGas || revert,
      'Expected throw, got \'' + error + '\' instead',
    );
    return;
  }
  assert.fail('Expected throw not received');
};

contract('DeadmanSwitch', function (accounts) {

  it("should return the owner", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.owner.call();
    }).then(function (owner) {
      assert.equal(owner, accounts[0]);
    });
  });

  it("should return the beneficary", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.beneficiary.call();
      }).then(function (beneficiary) {
        assert.equal(beneficiary, 0x0c93D3f8532c0A811f011949E4666D30A675D1dD);
      });
  });

  it("check seconds in min_time is equal to 1545739200", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.min_time.call();
      }).then(function (min_time) {
        assert.equal(min_time, 1545739200);
      });
  });

  it("check seconds in year is equal to 31556926", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.year.call();
      }).then(function (year) {
        assert.equal(year, 31556926);
      });
  });

  it("ensure that transferring the beneficary to null is rejected", function () {
    // The owner is actually accounts[1] at this point because we set it in the test above.
    // TODO: isolate these tests somehow.
    return DeadmanSwitch.deployed().then(function (instance) {
      return expectThrow(instance.transferBeneficiary(0, { from: accounts[0] }));
    });
  });

  it("should allow withdrawal only from owner", function () {
    // The owner is actually accounts[1] at this point because we set it in the test above.
    return DeadmanSwitch.deployed().then(function (instance) {
      return expectThrow(instance.withdraw({ from: accounts[0] }));
    });
  });

/*
  it("should set the owner", function () {
    var contractInstance;

    return DeadmanSwitch.deployed().then(function (instance) {
      contractInstance = instance;
      return instance.setOwner(accounts[0]);
    }).then(function () {
      return contractInstance.owner.call();
    }).then(function (owner) {
      assert.equal(owner, accounts[0]);
    });
  });

  it("should allow withdrawal", function () {
    // The owner is actually accounts[1] at this point because we set it in the test above.
    var ownerStartingBalance = web3.eth.getBalance(accounts[0]);
    var contractStartingBalance;
    var contractInstance;

    return DeadmanSwitch.deployed().then(function (instance) {
      contractInstance = instance;
      contractStartingBalance = web3.eth.getBalance(instance.address);
      return contractInstance.withdraw({ from: accounts[0] });
    }).then(function (tx) {
      var gasUsed = tx.receipt.gasUsed * 100000000000;
      var ownerEndingBalance = ownerStartingBalance.plus(contractStartingBalance).minus(gasUsed);

      assert.equal(web3.eth.getBalance(accounts[0]).toNumber(), ownerEndingBalance.toNumber(), "Amount was not sent to owner");
      assert.equal(web3.eth.getBalance(contractInstance.address).toNumber(), 0, "Amount was not withdrawn from contract");
    });
  });

  it("dont allow checkin from non owner/beneficary", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return expectThrow(instance.checkin({ from: "0x000" }));
    });
  });
*/
});
