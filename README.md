# TEZOSLAND

The Tezos FA2 NFT Marketplace Boilerplate

Demo on [TezosLand.io](https://TezosLand.io) 

## How to

goto https://faucet.tzalpha.net/

```
$ cd src/contracts
$ npm install -g truffle@tezos
$ truffle compile
$ truffle migrate --network carthagenet (TODO with Delphi)
// copy > contract address:    KT1SS5CMP6wfqt63jtwzisb22QgpRq13b77W
// paste address to TEZOSLAND_ADDRESS in dapp/defaults.ts (TODO move to .env)
$ cd ../frontend
$ npm install
$ npm start
```