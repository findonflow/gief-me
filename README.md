# GiefMe

This repository contains the cadence source code files and tests for the GiefMe Contract and the FindRegistry Contract.
The tests are written in Cadence and use the Cadence testing framework.

## GiefMe Contract

The GiefMe Contract is a contract that allows users to create a Gieft by wrapping one or multiple NFTs in a Gieft resource.
The Gieft is wrapped along with a password that is later used to unlock the Gieft and claim the NFTs. An optional registery capability can be set for each individual Gieft that ensures that a single user can only claim a Gieft once per certain block height TTL.

## FindRegistry Contract

This contract is used to store a dictionary of registry entries mapped to a certain uuid, each registry entry contains a block height and a user address. The contract is mainly used to ensure that a user can only claim a Gieft once per certain block height TTL, but the registry functionality can be used for other purposes as well.
Registry entries can be added, removed and updated. The contract also contains a function to check if a certain registry entry exists. Registry resources should be stored at a custom path in account storage.

## Tests

The tests are written in Cadence and use the Cadence testing framework and can be found in the `test` folder. The tests can be run using the following command:

```
./test.sh
```
