## Design pattern decisions

### Mortal functionality

Allows `destroyAndSend()` so that funds can be recovered if there's a bug, or if the owner doesn't want to wait until `min_time`

### Restricting Access

Operations such as transferring the ownership or beneficiary are restricted to the owner of the contract.

Also, updating the IPFS hash is only allowed by the owner

### Circuit Breaker

I have implemented a circuit breaker by allowing the contract to be Pausable, using OpenZeppelin's `Pausable.sol`.

The `pause()` and `unpause()`` functions inherit `onlyOwner`, and so this contract and only be paused by the owner of the contract. All functions which can modify the contract state inherit the `whenNotPaused` modifier.

### Speed bump

Funds can only be withdrawn after `min_time` is reached. Additional time can be added to the allowed withdraw time by calling `checkin()`
