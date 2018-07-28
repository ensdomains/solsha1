# solsha1

[![Build Status](https://travis-ci.org/ensdomains/solsha1.svg?branch=master)](https://travis-ci.org/ensdomains/solsha1) [![License](https://img.shields.io/badge/License-BSD--2--Clause-blue.svg)](LICENSE)

Pure-solidity implementation of the SHA1 hash function, heavily optimised using inline-assembly.

Gas consumption is approximately 38,000 gas per 512 bit block.

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes.

### Installing

solsha1 uses npm to manage dependencies, therefore the installation process is kept simple:

```
npm install
```

### Running tests

solsha1 uses truffle for its ethereum development environment. All tests can be run using truffle:

```
truffle test
```

To run linting, use solium:

```
solium --dir ./contracts
```

## Including solsha1 in your project

### Installation

```
npm install buffer --save
```

## Built With
* [Truffle](https://github.com/trufflesuite/truffle) - Ethereum development environment 


## Authors

* **Nick Johnson** - [Arachnid](https://github.com/Arachnid)

See also the list of [contributors](https://github.com/ensdomains/solsha1/contributors) who participated in this project.

## License

This project is licensed under the BSD 2-clause "Simplified" License - see the [LICENSE](LICENSE) file for details
