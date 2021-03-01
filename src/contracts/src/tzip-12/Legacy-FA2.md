 - [Legacy Interface](#legacy-interface)
  - [Token Metadata Entrypoints](#token-metadata-entrypoints)
  - [Permissions Descriptor Entrypoint](#permissions-descriptor-entrypoint)


## Legacy Interface

Contracts which for historical reasons do not implement [TZIP-16 Contract
Metadata](#tzip-16-contract-metadata) are expected to have implemented the
interface in this section (now deprecated).

### Token Metadata

Each FA2 `token_id` has associated metadata of the following type:

```ocaml
type token_id = nat

type token_metadata =
{
  token_id : token_id;
  symbol : string;
  name : string;
  decimals : nat;
  extras : (string, bytes) map;
}
```

- FA2 token amounts are represented by natural numbers (`nat`), and their
  **granularity** (the smallest amount of tokens which may be minted, burned, or
  transferred) is always 1.
- `decimals` is the number of digits to use after the decimal point when displaying
  the token amounts. If 0, the asset is not divisible. Decimals are used for display
  purposes only and MUST NOT affect transfer operation.

Examples:

| Decimals | Amount | Display |
| -------- | ------ | ------- |
| 0        | 123    | 123     |
| 1        | 123    | 12.3    |
| 3        | 123000 | 123     |



- The Legacy-FA2 contract MUST implement `token_metadata_registry` view
  entrypoint that returns an address of the contract holding tokens
  metadata. Token metadata can be held either by the FA2 token contract itself
  (then `token_metadata_registry` returns `SELF` address) or by a separate token
  registry contract.
- Token registry contract MUST implement one of two ways to expose token
  metadata for off-chain clients:
   - Contract storage MUST have a `big_map` that maps `token_id ->
     token_metadata` and annotated `%token_metadata`
   - Contract MUST implement entrypoint `token_metadata`
   
All entry-points rely on the Michelson type of the token metadata:

```
(pair
  (nat %token_id)
  (pair
    (string %symbol)
    (pair
      (string %name)
      (pair
        (nat %decimals)
        (map %extras string bytes)
  ))))
```

A previous version of this specification used a `(map %extras string string)`,
the `string` was changed to `bytes` to allow arbitrary values, and not be
limited by Michelson's allowed characters.

###### `token_metadata_registry`

LIGO definition:

```ocaml
| Token_metadata_registry of address contract
```

Michelson definition:

```
(contract %token_metadata_registry address)
```

Returns address of the contract that holds tokens metadata. If the FA2 contract
holds its own tokens metadata, the entrypoint returns `SELF` address. The entry
point parameter is some contract entrypoint to be called with the address of the
token metadata registry.

###### `token_metadata` `big_map`

LIGO definition:

```ocaml
type <contract_storage> = {
  ...
  token_metadata : (token_id, token_metadata) big_map;
  ...
}
```

Michelson definition:

```
(big_map %token_metadata
  nat
  (pair
  (nat %token_id)
  (pair
    (string %symbol)
    (pair
      (string %name)
      (pair
        (nat %decimals)
        (map %extras string bytes)
  ))))
)
```

The FA2 contract storage MUST have a `big_map` with a key type `token_id` and
value type `token_metadata`. This `big_map` MUST be annotated as `%token_metadata`
and can be at any position within the storage.

###### `token_metadata` Entrypoint

LIGO definition:

```ocaml
type token_metadata_param =
[@layout:comb]
{
  token_ids : token_id list;
  handler : (token_metadata list) -> unit;
}

| Token_metadata of token_metadata_param
```

Michelson definition:

```
(pair %token_metadata
  (list %token_ids nat)
  (lambda %handler
      (list
        (pair
          (nat %token_id)
          (pair
            (string %symbol)
            (pair
              (string %name)
              (pair
                (nat %decimals)
                (map %extras string bytes)
        ))))
      )
      unit
  )
)
```

</details>

Get the metadata for multiple token types. Accepts a list of `token_id`s and a
a lambda `handler`, which accepts a list of `token_metadata` records. The `handler`
lambda may assert certain assumptions about the metadata and/or fail with the
obtained metadata implementing a view entrypoint pattern to extract tokens metadata
off-chain.

- As with `balance_of`, the input `token_id`'s should not be deduplicated nor
  reordered.

- If one of the specified `token_id`s is not defined within the FA2 contract, the
  entrypoint MUST fail with the error mnemonic `"FA2_TOKEN_UNDEFINED"`.

### Permissions Descriptor Entrypoint

To advertise the permissions policy, a contract SHOULD have a
`%permissions_descriptor` “callback-view” entrypoint with the following
interface.

Michelson definition:

```
(contract %permissions_descriptor
  (pair
    (or %operator
      (unit %no_transfer)
      (or
        (unit %owner_transfer)
        (unit %owner_or_operator_transfer)
      )
    )
    (pair
      (or %receiver
        (unit %owner_no_hook)
        (or
          (unit %optional_owner_hook)
          (unit %required_owner_hook)
        )
      )
      (pair
        (or %sender
          (unit %owner_no_hook)
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
