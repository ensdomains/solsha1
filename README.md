# solsha1
Pure-solidity implementation of the SHA1 hash function, heavily optimised using inline-assembly.

Gas consumption is approximately 56k per 512 bit block.

Due to the need for optimisation, Solidity does not detect the correct ABI for the contract. Once deployed, use the ABI defined by `iSHA1` to interact with the contract.
