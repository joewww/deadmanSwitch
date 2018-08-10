## Avoiding common attacks (contract security)


### Predictable State Variables

I am using `block.timestamp` which can technically be manipulated by miners up to a certain amount. However, this contract does not require any precision operations with the block time, so any potential miner manipulation of the block timestamp is mitigated.


### Integer Overflows

I am using `SafeMath.sol` for `balance`, and `min_time` to guard against integer overflows.


### Tools / Analysis

I used mythril for security analysis, to see if there were any edge cases I wasn't aware of.
