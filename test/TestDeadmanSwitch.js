var DeadmanSwitch = artifacts.require("DeadmanSwitch");

/* taken from OpenZeppelin for now. */
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

    function assertJump(error) {
          if(error.toString().indexOf("invalid JUMP") == -1) {
            console.log("We were expecting a Solidity throw (aka an invalid JUMP)," + 
                        "we got one. Test succeeded.");
        } else {
            assert(false, error.toString());
        }
    }

  it("should return the owner", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.owner.call();
    }).then(function (owner) {
      assert.equal(owner, accounts[0]);
    });
  });

  it("should return 0xf46...308 as the beneficary", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return instance.beneficiary.call();
      }).then(function (beneficiary) {
        assert.equal(beneficiary, 0xf46a36B1EAfDa5F7597395EEAB4c89992F851308);
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
    return DeadmanSwitch.deployed().then(function (instance) {
      return expectThrow(instance.transferBeneficiary(0x0, { from: accounts[0] }));
    });
  });

  it("should allow withdrawal from owner", function () {
    return DeadmanSwitch.deployed().then(function (instance) {
      return expectThrow(instance.withdraw({ from: accounts[0] }));
    });
  });

    // Test pause()
    it("dont allow withdraws if contract is paused.", async() => {
        const deadmanSwitch = await DeadmanSwitch.deployed();
        await deadmanSwitch.pause(); //from defaultAccount -> the owner

        try {
            await deadmanSwitch.withdraw("Qmm..", {from: accounts[0], value: price});
            assert.fail('should have thrown before');
        } catch(error) {              
            assertJump(error);
        }    
    })
});
