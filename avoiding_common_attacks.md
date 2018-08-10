## Avoiding common attacks (contract security)


### Predictable State Variables

I am using `block.timestamp` which can technically be manipulated by miners up to a certain amount. However, this contract does not require any precision operations with the block time, so any potential miner manipulation is mitigated.


### Integer Overflows

I am using `SafeMath.sol` for `balance`, and `min_time`
