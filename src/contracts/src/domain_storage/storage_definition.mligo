#if !FA2_TLD_DEF_TOKEN
#define FA2_TLD_DEF_TOKEN

#include "land_definition.mligo"
#include "token_definition.mligo"

type marketplace_storage = {
  admin: address;
  height: nat;
  width: nat;
  on_sale: (token_id, price) big_map;
  lands: lands;
  owners: owners;
}


type token_storage = {
  token_defs : token_def set;
  last_used_id : token_id;
  metadata : nft_meta;
}

type ledger = (token_id, address) big_map

type nft_token_storage = {
  ledger : ledger;
  operators : operator_storage;
  metadata : token_storage;
  market : marketplace_storage;
}

#endif