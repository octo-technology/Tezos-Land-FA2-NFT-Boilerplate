### FA2 Transfer Permission Policies and Configuration

Most token standards specify logic such as who can perform a transfer, the amount
of a transfer, and who can receive tokens. This standard calls such logic
_transfer permission policy_ and defines a framework to compose such permission
policies from the [standard permission behaviors](#permission-behaviors).

FA2 allows the contract developer to choose and customize from a variety of permissions
behaviors, easily enabling non-transferrable tokens or centrally-administrated
tokens without operators. The particular implementation may be static
(the permissions configuration cannot be changed after the contract is deployed)
or dynamic (the FA2 contract may be upgradable and allow to change the permissions
configuration). However, the FA2 token contract MUST expose consistent and
non-self-contradictory permissions configuration (unlike ERC-777 that exposes two
flavors of the transfer at the same time).

#### A Taxonomy of Transfer Permission Policies

##### Permission Behaviors

Transfer permission policy is composed from several orthogonal permission behaviors.
Each permission behavior defines a set of possible behavior configurations (one
of those configuration is default). The concrete policy is expressed as a combination
of concrete configuration values for each permission behavior. An FA2 contract
developer MAY chose to implement one or more permission behaviors configuration
that are different from the default ones depending on their business use case.

The FA2 defines the following standard permission behaviors, which configuration
can be chosen independently, when an FA2 contract is implemented:

###### `Operator` Permission Behavior

This permission behavior specifies who is permitted to transfer tokens.

Depending on the configuration, token transfers can be performed by the token owner
or by an operator permitted to transfer specific tokens on behalf of the token owner.
An operator can transfer permitted tokens in any amount on behalf of the owner.

Standard configurations of the operator permission behavior:

```ocaml
type operator_transfer_policy =
  | No_transfer
  | Owner_transfer
  | Owner_or_operator_transfer (* default *)
```

- `No_transfer` - neither owner nor operator can transfer tokens. This permission
  configuration can be used for non-transferable tokens or for the FA2 implementation
  when a transfer can be performed only by some privileged and/or administrative
  account. The transfer operation MUST fail with the error mnemonic `"FA2_TX_DENIED"`.

- `Owner_transfer` - If `SENDER` is not the token owner, the transfer operation
  MUST fail with the error mnemonic `"FA2_NOT_OWNER"`.

- `Owner_or_operator_transfer` - allows transfer for the token owner or an operator
  permitted to manage specific tokens on behalf of the owner. If `SENDER` is not
  the token owner and not an operator permitted to manage tokens to be transferred
  on behalf of the token owner, the transfer operation MUST fail with the error
  mnemonic `"FA2_NOT_OPERATOR"`.
  The FA2 standard defines the entrypoint to manage operators associated with
  the token owner address and specific token IDs (token types)
  ([`update_operators`](#update_operators)). Once an operator is added, it can
  manage permitted token types of the associated owner.

The operation permission behavior also affects [`update_operators`](#update_operators)
entrypoint:

- If an operator transfer is denied (`No_transfer` or `Owner_transfer`),
  [`update_operators`](#update_operators) entrypoint MUST fail if invoked with the
  error mnemonic `"FA2_OPERATORS_UNSUPPORTED"`.

###### `Token Owner Hook` Permission Behavior

Each transfer operation accepts a batch that defines token owners that send tokens
(senders) and token owners that receive tokens (receivers). Token owner contracts
MAY implement `fa2_token_sender` and/or `fa2_token_receiver` interfaces.
Those interfaces define a hook entrypoint that accepts transfer description and
invoked by the FA2 contract in the context of transfer, mint and burn operations.

Standard configurations of the token owner hook permission behavior:

```ocaml
type owner_hook_policy =
  | Owner_no_hook (* default *)
  | Optional_owner_hook
  | Required_owner_hook
```

- `Owner_no_hook` - ignore the owner hook interface.

- `Optional_owner_hook` - treat the owner hook interface as optional. If a token
  owner contract implements a corresponding hook interface, it MUST be invoked. If
  the hook interface is not implemented, it gets ignored.

- `Required_owner_hook` - treat the owner hook interface as required. If a token
  owner contract implements a corresponding hook interface, it MUST be invoked. If
  the hook interface is not implemented, the entire transfer transaction MUST fail.

Token owner hook implementation and semantics:

- Sender and/or receiver hooks can approve the transaction or reject it
  by failing. If such a hook is invoked and failed, the whole transfer operation
  MUST fail.

- This policy can be applied to both token senders and token receivers. There are
  two owner hook interfaces, `fa2_token_receiver` and `fa2_token_sender`, that need
  to be implemented by token owner contracts to expose the token owner's hooks
  to the FA2 token contract.

- If a transfer failed because of the token owner hook permission behavior, the
  operation MUST fail with the one of the following error mnemonics:

| Error Mnemonic                  | Description                                                                                         |
| :------------------------------ | :-------------------------------------------------------------------------------------------------- |
| `"FA2_RECEIVER_HOOK_FAILED"`    | Receiver hook is invoked and failed. This error MUST be raised by the hook implementation           |
| `"FA2_SENDER_HOOK_FAILED"`      | Sender hook is invoked and failed. This error MUST be raised by the hook implementation             |
| `"FA2_RECEIVER_HOOK_UNDEFINED"` | Receiver hook is required by the permission behavior, but is not implemented by a receiver contract |
| `"FA2_SENDER_HOOK_UNDEFINED"`   | Sender hook is required by the permission behavior, but is not implemented by a sender contract     |

- `transfer_descriptor` type defined below can represent regular transfer, mint and
  burn operations.

| operation | `from_`                       | `to_`                           |
| :-------- | :---------------------------- | :------------------------------ |
| transfer  | MUST be `Some sender_address` | MUST be `Some receiver_address` |
| mint      | MUST be `None`                | MUST be `Some receiver_address` |
| burn      | MUST be `Some burner_address` | MUST be `None`                  |

- If all of the following conditions are met, the FA2 contract MUST invoke both
  `fa2_token_sender` and `fa2_token_receiver` entrypoints:

  - the token owner implements both `fa2_token_sender` and `fa2_token_receiver`
    interfaces
  - the token owner receives and sends some tokens in the same transfer operation
  - both sender and receiver hooks are enabled by the FA2 permissions policy

- If the token owner participates in multiple transfers within the transfer operation
  batch and hook invocation is required by the permissions policy, the hook MUST
  be invoked only once.

- The hooks MUST NOT be invoked in the context of the operation other than transfer,
  mint and burn.

- `transfer_descriptor_param.operator` MUST be initialized with the address that
  invoked the FA2 contract (`SENDER`).

A special consideration is required if FA2 implementation supports sender and/or
receiver hooks. It is possible that one of the token owner hooks will fail because
of the hook implementation defects or other circumstances out of control of the
FA2 contract. This situation may cause tokens to be permanently locked on the token
owner's account. One of the possible solutions could be the implementation of a
special administrative version of the mint and burn operations that bypasses owner's
hooks otherwise required by the FA2 contract permissions policy.

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

type transfer_descriptor_param =
[@layout:comb]
{
  batch : transfer_descriptor list;
  operator : address;
}

type fa2_token_receiver =
  | Tokens_received of transfer_descriptor_param

type fa2_token_sender =
  | Tokens_sent of transfer_descriptor_param
```

Michelson definition:

```
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
```

##### Transfer Permission Policy Formulae

Each concrete implementation of the transfer permission policy can be described
by a formula which combines permission behaviors in the following form:

```
Operator(operator_config) * Receiver(receiver_config) * Sender(sender_config)
```

For instance, `Operator(Owner_transfer) * Receiver(Owner_no_hook) * Sender(Owner_no_hook)`
formula describes the policy which allows only token owners to transfer their own
tokens.

`Operator(No_transfer) * Receiver(Owner_no_hook) * Sender(Owner_no_hook)` formula
represents non-transferable token (neither token owner, nor operators can transfer
tokens.

Transfer permission policy formula is expressed by the `permissions_descriptor` type.

```ocaml
type operator_transfer_policy =
  | No_transfer
  | Owner_transfer
  | Owner_or_operator_transfer

type owner_hook_policy =
  | Owner_no_hook
  | Optional_owner_hook
  | Required_owner_hook

type custom_permission_policy =
{
  tag : string;
  config_api: address option;
}

type permissions_descriptor =
{
  operator : operator_transfer_policy;
  receiver : owner_hook_policy;
  sender : owner_hook_policy;
  custom : custom_permission_policy option;
}
```

It is possible to extend transfer permission policy with a `custom` behavior,
which does not overlap with already existing standard policies. This standard
does not specify exact types for custom config entrypoints. FA2 token contract
clients that support custom config entrypoints must know their types a priori
and/or use a `tag` hint of `custom_permission_policy`.

##### Customizing Transfer Permission Policy

The FA2 contract MUST always implement the
[core transfer behavior](#core-transfer-behavior).
However, FA2 contract developer MAY chose to implement either the
[default transfer permission policy](#default-transfer-permission-policy) or a
custom policy.
The FA2 contract implementation MAY customize one or more of the standard permission
behaviors (`operator`, `receiver`, `sender` as specified in `permissions_descriptor`
type), by choosing one of the available options for those permission behaviors.

The composition of the described behaviors can be described as
`Core_Transfer_Behavior AND (Default_transfer_permission_policy OR Custom_Transfer_Permission_Policy)`

##### Exposing Permissions Descriptor

In order to advertise its permissions, an FA2 should fill the `"permissions"`
field in its contract metadata.

The field is an object with 4 fields corresponding to the Ligo types defined in
the previous sections:

- `"operator"` is `"no-transfer"`, `"owner-transfer"`, or
  `"owner-or-operator-transfer"`.
- `"receiver"` is`"owner-no-hook"`, `"optional-owner-hook"`, or
  `"required-owner-hook"`.
- `"sender"` is `"owner-no-hook"`, `"optional-owner-hook"`, or
  `"required-owner-hook"`.
- `"custom"` is an optional object `{ "tag": <string>, "config-api": <string> }`
  where `"config-api"` is an optional contract adddress.

The implicit value of the field corresponding to the
[default `transfer` permission policy](#default-transfer-permission-policy) is
the following:

```json
{
  "operator": "owner-or-operator-transfer",
  "receiver": "owner-no-hook",
  "sender": "owner-no-hook"
}
```

### Error Handling

This specification defines the set of standard errors to make it easier to integrate
FA2 contracts with wallets, DApps and other generic software, and enable
localization of user-visible error messages.

Each error code is a short abbreviated string mnemonic. An FA2 contract client
(like another contract or a wallet) could use on-the-chain or off-the-chain registry
to map the error code mnemonic to a user-readable, localized message. A particular
implementation of the FA2 contract MAY extend the standard set of errors with custom
mnemonics for additional constraints.

Standard error mnemonics:

| Error mnemonic                  | Description                                                                                                                                              |
| :------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `"FA2_TOKEN_UNDEFINED"`         | One of the specified `token_id`s is not defined within the FA2 contract                                                                                  |
| `"FA2_INSUFFICIENT_BALANCE"`    | A token owner does not have sufficient balance to transfer tokens from owner's account                                                                   |
| `"FA2_TX_DENIED"`               | A transfer failed because of `operator_transfer_policy == No_transfer`                                                                                   |
| `"FA2_NOT_OWNER"`               | A transfer failed because `operator_transfer_policy == Owner_transfer` and it is invoked not by the token owner                                          |
| `"FA2_NOT_OPERATOR"`            | A transfer failed because `operator_transfer_policy == Owner_or_operator_transfer` and it is invoked neither by the token owner nor a permitted operator |
| `"FA2_OPERATORS_UNSUPPORTED"`   | `update_operators` entrypoint is invoked and `operator_transfer_policy` is `No_transfer` or `Owner_transfer`                                             |
| `"FA2_RECEIVER_HOOK_FAILED"`    | The receiver hook failed. This error MUST be raised by the hook implementation                                                                           |
| `"FA2_SENDER_HOOK_FAILED"`      | The sender failed. This error MUST be raised by the hook implementation                                                                                  |
| `"FA2_RECEIVER_HOOK_UNDEFINED"` | Receiver hook is required by the permission behavior, but is not implemented by a receiver contract                                                      |
| `"FA2_SENDER_HOOK_UNDEFINED"`   | Sender hook is required by the permission behavior, but is not implemented by a sender contract                                                          |

If more than one error conditions are met, the entrypoint MAY fail with any applicable
error.

When an error occurs, any FA2 contract entrypoint MUST fail with one of the following
types:

1. `string` value which represents an error code mnemonic.
2. a Michelson `pair`, where the first element is a `string` representing error code
   mnemonic and the second element is a custom error data.

Some FA2 implementations MAY introduce their custom errors that MUST follow the
same pattern as standard ones: define custom error mnemonics and fail with one
of the error types defined above.
