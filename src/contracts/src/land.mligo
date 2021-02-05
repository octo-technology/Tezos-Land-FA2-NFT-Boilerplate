(**
Implementation of the FA2 interface for the TLD contract supporting multiple
types of NFTs. Each NFT type is represented by the range of token IDs - `token_def`.
 *)
#if !FA2_TLD_TOKEN
#define FA2_TLD_TOKEN

#include "tzip-12/fa2_interface.mligo"
#include "tzip-12/fa2_errors.mligo"
#include "tzip-12/lib/fa2_operator_lib.mligo"

#include "domain_storage/storage_definition.mligo"
#include "entrypoints/entrypoints.mligo"


type nft_entry_points =
    | Fa2 of fa2_entry_points
    | Metadata of fa2_token_metadata
    | Mint of mint_param
    | ChangeLandName of change_land_name_param
    | ChangeLandDescription of change_land_description_param
    | SellLand of sell_param
    | BuyLand of buy_param
    | WithdrawFromSale of withdraw_param

let fa2_main (param, storage : fa2_entry_points * nft_token_storage)
    : (operation  list) * nft_token_storage =
    match param with
    | Transfer txs_michelson -> fa2_transfer (txs_michelson, storage)
    | Balance_of pm -> fa2_balance (pm, storage)
    | Update_operators updates_michelson -> fa2_update_operators (updates_michelson, storage)
    | Token_metadata_registry callback -> fa2_token_metadata_registry (callback, storage)

let main (param, storage : nft_entry_points * nft_token_storage)
      : (operation  list) * nft_token_storage =
    match param with
    | Fa2 fa2 -> fa2_main (fa2, storage)
    | Metadata m -> get_metadata_entrypoint(m, storage)
    | Mint p -> mint(p,storage)
    | ChangeLandName p -> change_land_name(p, storage)
    | ChangeLandDescription p -> changeLandDescription(p, storage)
    | SellLand p -> sell(p, storage)
    | BuyLand p -> buy(p, storage)
    | WithdrawFromSale p -> withdraw_from_sale(p, storage)


#endif
