# tezos-land

This repository contains sources for a boilerplate-NFT-game for Tezos blockchain called TezosLand. It is a gamified NFT  like Decentraland for Ethereum.

### Tezos Node install

Go to https://tezos.gitlab.io/introduction/howtoget.html and follow instructions in section "Build from sources".

### Launching Sandbox

Go to https://tezos.gitlab.io/user/sandbox.html and follow instructions

### Taquito install

Go to https://tezostaquito.io/docs/quick_start

### Ligo install

Go to https://ligolang.org/docs/intro/installation


### Typescript Install

```
npm install -g typescript
```

### Launching Tezos Node with cors

```
./src/bin_node/tezos-sandboxed-node.sh 1 --connections 1 --cors-header='content-type' --cors-origin='*'
```

# Smart contract management

## By command line (tezos-client)

### deploy contract 

```
tezos-client originate contract counter transferring 1 from bootstrap5 running './counter.tz' --init "0" --burn-cap 0.351
```

### invoke contract 

```
tezos-client transfer 0 from bootstrap4 to counter --arg "(Right 5)" --dry-run
```


### retrieve storage of contract 

```
tezos-client get contract storage for counter
```

### Generate identity
```
tezos-client gen keys bob
```

### Show identity
```
tezos-client show address bootstrap1 -S
```

## With Truffle

### Compile contract 
In project folder, run:
```
$ truffle compile
```

### Deploy contract 
In project folder, run:
```
$ truffle migrate --network <development, carthagenet, mainnet, zeronet>
```

# Run tests
In project folder, run in this order: 
```
$ ligo compile-contract src/entrypoints_for_helpers.mligo main > test/helpers.tz 
$ ligo compile-contract src/land.mligo main > test/land.tz 
$ python -m unittest
```