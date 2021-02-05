# Implementing FA2


- [LIGO implementation](#ligo-implementation)
- [Implementing Different Token Types with FA2](#implementing-different-token-types-with-fa2)
  - [Single Fungible Token](#single-fungible-token)
  - [Multiple Fungible Tokens](#multiple-fungible-tokens)
  - [Non-fungible Tokens](#non-fungible-tokens)
  - [Mixing Fungible and Non-fungible Tokens](#mixing-fungible-and-non-fungible-tokens)
  - [Non-transferable Tokens](#non-transferable-tokens)


## LIGO implementation

`type fa2_entry_points =`

- [`| Transfer of transfer list`](#transfer)
- [`| Balance_of of balance_of_param`](#balance_of)
- [`| Update_operators of update_operator list`](#update_operators)

The full definition of the FA2 entrypoints in LIGO and related types can be found
in [fa2_interface.mligo](./fa2_interface.mligo).

#### `transfer`

LIGO definition:

```ocaml
type token_id = nat

type transfer_destination =
[@layout:comb]
{
  to_ : address;
  token_id : token_id;
  amount : nat;
}

type transfer =
[@layout:comb]
{
  from_ : address;
  txs : transfer_destination list;
}

| Transfer of transfer list
```

Michelson definition:

```
(list %transfer
  (pair
    (address %from_)
    (list %txs
      (pair
        (address %to_)
        (pair
          (nat %token_id)
          (nat %amount)
        )
      )
    )
  )
)
```

#### `balance_of`

LIGO definition:

```ocaml
type token_id = nat

type balance_of_request =
[@layout:comb]
{
  owner : address;
  token_id : token_id;
}

type balance_of_response =
[@layout:comb]
{
  request : balance_of_request;
  balance : nat;
}

type balance_of_param =
[@layout:comb]
{
  requests : balance_of_request list;
  callback : (balance_of_response list) contract;
}

| Balance_of of balance_of_param
```

Michelson definition:

```
(pair %balance_of
  (list %requests
    (pair
      (address %owner)
      (nat %token_id)
    )
  )
  (contract %callback
    (list
      (pair
        (pair %request
          (address %owner)
          (nat %token_id)
        )
        (nat %balance)
      )
    )
  )
)
```

##### `update_operators`

LIGO definition:

```ocaml
type token_id = nat

type operator_param =
[@layout:comb]
{
  owner : address;
  operator : address;
  token_id : token_id;
}

type update_operator =
  [@layout:comb]
  | Add_operator of operator_param
  | Remove_operator of operator_param

| Update_operators of update_operator list
```

Michelson definition:

```
(list %update_operators
  (or
    (pair %add_operator
      (address %owner)
      (pair
        (address %operator)
        (nat %token_id)
      )
    )
    (pair %remove_operator
      (address %owner)
      (pair
        (address %operator)
        (nat %token_id)
      )
    )
  )
)
```

## Implementing Different Token Types With FA2

The FA2 interface is designed to support a wide range of token types and implementations.
This section gives examples of how different types of the FA2 contracts MAY be
implemented and what are the expected properties of such an implementation.

### Single Fungible Token

An FA2 contract represents a single token similar to ERC-20 or FA1.2 standards.

| Property        |   Constrains   |
| :-------------- | :------------: |
| `token_id`      |  Always `0n`   |
| transfer amount | natural number |
| account balance | natural number |
| total supply    | natural number |
| decimals        |     custom     |

### Multiple Fungible Tokens

An FA2 contract may represent multiple tokens similar to ERC-1155 standard.
The implementation can have a fixed predefined set of supported tokens or tokens
can be created dynamically.

| Property        |         Constrains          |
| :-------------- | :-------------------------: |
| `token_id`      |       natural number        |
| transfer amount |       natural number        |
| account balance |       natural number        |
| total supply    |       natural number        |
| decimals        | custom, per each `token_id` |

### Non-fungible Tokens

An FA2 contract may represent non-fungible tokens (NFT) similar to ERC-721 standard.
For each individual non-fungible token the implementation assigns a unique `token_id`.
The implementation MAY support either a single kind of NFTs or multiple kinds.
If multiple kinds of NFT is supported, each kind MAY be assigned a continuous range
of natural number (that does not overlap with other ranges) and have its own associated
metadata.

| Property        |                           Constrains                            |
| :-------------- | :-------------------------------------------------------------: |
| `token_id`      |                         natural number                          |
| transfer amount |                          `0n` or `1n`                           |
| account balance |                          `0n` or `1n`                           |
| total supply    |                          `0n` or `1n`                           |
| decimals        | `0n` or a natural number if a token represents a batch of items |

For any valid `token_id` only one account CAN hold the balance of one token (`1n`).
The rest of the accounts MUST hold zero balance (`0n`) for that `token_id`.

### Mixing Fungible and Non-fungible Tokens

An FA2 contract MAY mix multiple fungible and non-fungible tokens within the same
contract similar to ERC-1155. The implementation MAY chose to select individual
natural numbers to represent `token_id` for fungible tokens and continuous natural
number ranges to represent `token_id`s for NFTs.

| Property        |                         Constrains                          |
| :-------------- | :---------------------------------------------------------: |
| `token_id`      |                       natural number                        |
| transfer amount | `0n` or `1n` for NFT and natural number for fungible tokens |
| account balance | `0n` or `1n` for NFT and natural number for fungible tokens |
| total supply    | `0n` or `1n` for NFT and natural number for fungible tokens |
| decimals        |                           custom                            |

### Non-transferable Tokens

Either fungible and non-fungible tokens can be non-transferable. Non-transferable
tokens can be represented by the FA2 contract which [operator transfer behavior](#operator-transfer-behavior)
is defined as `No_transfer`. Tokens cannot be transferred either by the token owner
or by any operator. Only privileged operations like mint and burn can assign tokens
to owner accounts.

## `assert_balances`

`assert_balances` entrypoint is optional.

LIGO definition:

```ocaml
type token_id = nat

type assert_balance = [@layout:comb] {
  owner : address;
  token_id : token_id;
  balance: nat;
}

| Assert_balances of assert_balance list
```

Michelson definition:

```
(pair %assert_balances
  (list
    (pair
      (address %owner)
      (pair
        (nat %token_id)
        (nat %balance)))))
```

Checks the balances of a list of account/token pairs. If all the balances are
correct, the entrypoint MUST do nothing (output same storage and no operations).
If any of the balances is wrong it MUST interrupt the operation using
`FAILWITH`.


## Transfer Hook

Transfer hook is one recommended design pattern to implement FA2 that enables
separation of the core token transfer logic and a permission policy. Instead of
implementing FA2 as a monolithic contract, a [permission policy]
(#fa2-permission-policies-and-configuration) can be implemented as a separate
contract. Permission policy contract provides an entrypoint invoked by the core
FA2 contract to accept or reject a particular transfer operation (such
an entrypoint is called **transfer hook**).

### Transfer Hook Motivation

Usually, different tokens require different permission policies that define who
can transfer and receive tokens. There is no single permission policy that fits
all scenarios. For instance, some game tokens can be transferred by token owners,
but no one else. In some financial token exchange applications, tokens are to be
transferred by a special exchange operator account, not directly by the token owners
themselves.

Support for different permission policies usually requires customizing existing
contract code. The FA2 standard proposes a different approach in which the on-chain
composition of the core FA2 contract implementation does not change, and a pluggable
permission transfer hook is implemented as a separate contract and registered with
the core FA2. Every time FA2 performs a transfer, it invokes a hook contract that
validates a transaction and either approves it by finishing execution successfully
or rejects it by failing.

The transfer hook makes it possible to model different transfer permission
policies like transfer lists, operator lists, etc. Although this approach introduces
gas consumption overhead (compared to an all-in-one contract) by requiring an extra
inter-contract call, it also offers some other advantages:

- FA2 core implementation can be verified once, and certain properties (not
  related to permission policy) remain unchanged.

- Most likely, the core transfer semantic will remain unchanged. If
  modification of the permission policy is required for an existing contract, it
  can be done by replacing a transfer hook only. No storage migration of the FA2
  ledger is required.

- Transfer hooks could be used for purposes beyond permissioning, such as
  implementing custom logic for a particular token application.

### Transfer Hook Specification

An FA2 token contract has a single entrypoint to set the hook. If a transfer hook
is not set, the FA2 token contract transfer operation MUST fail. Transfer hook is
to be set by the token contract administrator before any transfers can happen.
The concrete token contract implementation MAY impose additional restrictions on
who may set the hook. If the set hook operation is not permitted, it MUST fail
without changing existing hook configuration.

For each transfer operation, a token contract MUST invoke a transfer hook and
return a corresponding operation as part of the transfer entrypoint result.
(For more details see [`set_transfer_hook`](#set_transfer_hook) )

`operator` parameter for the hook invocation MUST be set to `SENDER`.

`from_` parameter for each `hook_transfer` batch entry MUST be set to `Some(transfer.from_)`.

`to_` parameter for each `hook_transfer` batch entry MUST be set to `Some(transfer.to_)`.

A transfer hook MUST be invoked, and operation returned by the hook invocation
MUST be returned by `transfer` entrypoint among other operations it might create.
`SENDER` MUST be passed as an `operator` parameter to any hook invocation. If an
invoked hook fails, the whole transfer transaction MUST fail.

FA2 does NOT specify an interface for mint and burn operations; however, if an
FA2 token contract implements mint and burn operations, these operations MUST
invoke a transfer hook as well.

| Mint                                                    | Burn                                                  |
| :------------------------------------------------------ | :---------------------------------------------------- |
| Invoked if registered. `from_` parameter MUST be `None` | Invoked if registered. `to_` parameter MUST be `None` |

Note that using the transfer hook design pattern with sender/receiver hooks may
potentially be insecure. Sender and/or receiver contract hooks will be called
from the transfer hook contract (not the facade FA2 token contract). If sender/receiver
contracts rely on `SENDER` value for authorization, they must guarantee that the
call is initiated on behalf of the FA2 contract.

### `set_transfer_hook`

FA2 entrypoint with the following signature.

LIGO definition:

```ocaml
type transfer_destination_descriptor =
[@layout:comb]
{
  to_ : address option;
  token_id : token_id;
  amount : nat;
}

type transfer_descriptor =
[@layout:comb]
{
  from_ : address option;
  txs : transfer_destination_descriptor list
}

type set_hook_param =
[@layout:comb]
{
  hook : unit -> transfer_descriptor_param contract;
  permissions_descriptor : permissions_descriptor;
}

| Set_transfer_hook of set_hook_param
```

Michelson definition:

```
(pair %set_transfer_hook
  (lambda %hook
    unit
    (contract
      (pair
        (address %fa2)
        (pair
          (list %batch
            (pair
              (option %from_ address)
              (list %txs
                (pair
                  (option %to_ address)
                  (pair
                    (nat %token_id)
                    (nat %amount)
                  )
                )
              )
            )
          )
          (address %operator)
        )
      )
    )
  )
  (pair %permissions_descriptor
    (or %operator
      (unit %no_transfer)
      (or
        (unit %owner_transfer)
        (unit %owner_or_operator_transfer)
      )
    )
    (pair
      (or %receiver
        (unit %owner_no_op)
        (or
          (unit %optional_owner_hook)
          (unit %required_owner_hook)
        )
      )
      (pair
        (or %sender
          (unit %owner_no_op)
          (or
            (unit %optional_owner_hook)
            (unit %required_owner_hook)
          )
        )
        (option %custom
          (pair
            (string %tag)
            (option %config_api address)
          )
        )
      )
    )
  )
)
```

FA2 implementation MAY restrict access to this operation to a contract administrator
address only.

The parameter is an address plus hook entrypoint of type
`transfer_descriptor_param`.

The transfer hook is always invoked from the `transfer` operation; otherwise, FA2
MUST fail.

`hook` field in `set_hook_param` record is a lambda which returns a hook entry
point of type `transfer_descriptor_param`. It allows a policy contract implementor
to choose a name for the hook entrypoint or even implement several transfer hooks
in the same contract.

### Transfer Hook Examples

#### Default Permission Policy

Only a token owner can initiate a transfer of tokens from their accounts ( `from_`
MUST be equal to `SENDER`).

Any address can be a recipient of the token transfer.

[Hook contract](./examples/fa2_default_hook.mligo)

#### Custom Receiver Hook/Transfer List Permission Policy

This is a sample implementation of the FA2 transfer hook, which supports receiver
transfer list and `fa2_token_receiver` for token receivers. The hook contract also
supports [operators](#operator-transfer-behavior).

Only addresses that on the transfer list or implement the `fa2_token_receiver`
interface can receive tokens. If one or more `to_` addresses in FA2 transfer batch
are not permitted, the whole transfer operation MUST fail.

The following table demonstrates the required actions depending on `to_` address
properties.

| `to_` is on transfer list | `to_` implements `fa2_token_receiver` interface | Action                                         |
| ------------------------- | ----------------------------------------------- | ---------------------------------------------- |
| No                        | No                                              | Transaction MUST fail                          |
| Yes                       | No                                              | Continue transfer                              |
| No                        | Yes                                             | Continue transfer, MUST call `tokens_received` |
| Yes                       | Yes                                             | Continue transfer, MUST call `tokens_received` |

Permission policy formula `S(true) * O(true) * ROH(None) * SOH(Custom)`.

[Hook contract](./examples/fa2_custom_receiver.mligo)
