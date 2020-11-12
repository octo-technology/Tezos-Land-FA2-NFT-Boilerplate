#include "../../domain_storage/storage_definition.mligo"
#include "../helpers/fa2_transfer_helpers.mligo"

type withdraw_param = {
  id : token_id;
}
(**
Withdraw the land on sale from the "on_sale" list and removes this contract as an operator for this token
@return storage with modified operators and on_sale lists
*)
let withdraw_from_sale (withdraw_param, storage : withdraw_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let land_price : price = match Big_map.find_opt withdraw_param.id storage.market.on_sale with
        | None -> (failwith("This land is not on sale"): price)
        | Some price -> price
      in
    if not is_owner(withdraw_param.id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can withdraw it from sale") : (operation  list) * nft_token_storage)
    else
        let operators_without_token_operator = exec_update_operator([Remove_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=withdraw_param.id})], Tezos.sender, storage.operators) in
        let on_sale_without_removed_land = Map.remove withdraw_param.id storage.market.on_sale in
        ([] : operation list),  { storage with market = { storage.market with on_sale = on_sale_without_removed_land }; operators = operators_without_token_operator }
