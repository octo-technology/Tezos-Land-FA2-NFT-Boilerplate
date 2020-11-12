#include "../../domain_storage/storage_definition.mligo"
#include "../helpers/fa2_transfer_helpers.mligo"

type sell_param = {
  id : token_id;
  price : price;
}
(**
Put the land on sale in the "on_sale" list and add this contract as an operator for this token
@return storage with modified operators and on_sale lists
*)
let sell (sell_params, storage : sell_param * nft_token_storage) : (operation  list) * nft_token_storage =
  let land_price : price = match Big_map.find_opt sell_params.id storage.market.on_sale with
    | None -> (0mutez : price)
    | Some price -> (failwith("This land is already on sale"): price)
  in
  if not is_owner(sell_params.id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can sell it") : (operation  list) * nft_token_storage)
    else
        let operators_with_token_operator = exec_update_operator([Remove_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=sell_params.id})], Tezos.sender, storage.operators) in
        let on_sale_with_new_land_on_sale = Map.add sell_params.id sell_params.price storage.market.on_sale in
        ([] : operation list), { storage with market = { storage.market with on_sale = on_sale_with_new_land_on_sale }; operators = operators_with_token_operator }