#if !FA2_TLD_DEF_TOKEN
#define FA2_TLD_DEF_TOKEN

#include "land_definition.mligo"
#include "token_definition.mligo"
#include "marketplace_definition.mligo"
#include "../tzip-12/lib/fa2_operator_lib.mligo"

type marketplace_storage = {
  admin: address;
  height: nat;
  width: nat;
  sales: sale set;
  lands: lands;
  landIds: token_id set;
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