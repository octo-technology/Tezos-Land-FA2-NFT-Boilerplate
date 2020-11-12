#if !FA2_TLD_DEF_TOKEN
#define FA2_TLD_DEF_TOKEN

#include "tzip-12/fa2_interface.mligo"
#include "tzip-12/fa2_errors.mligo"
#include "tzip-12/lib/fa2_operator_lib.mligo"

(* range of nft tokens *)
type token_def = {
  from_ : nat;
  to_ : nat;
}

type nft_meta = (token_def, token_metadata) big_map

type token_storage = {
  token_defs : token_def set;
  last_used_id : token_id;
  metadata : nft_meta;
}

type ledger = (token_id, address) big_map

type owners = (address, token_id set) big_map

type coordinates = ( nat * nat )

type name = string
type price = tez

type land = {
    name: string;
    description: string option;
    position: coordinates;
    isOwned: bool;
    onSale: bool;
    price: price;
    id: nat
    // owner : address
}

type lands = (nat, land) big_map

type marketplace_storage = {
  admin: address;
  height: nat;
  width: nat;
  on_sale: (token_id, price) big_map;
  lands: lands;
  owners: owners;
}

type nft_token_storage = {
  ledger : ledger;
  operators : operator_storage;
  metadata : token_storage;
  market : marketplace_storage;
}
type change_land_name_param = {
    token_id: token_id;
    new_land_name: string;
}
#endif