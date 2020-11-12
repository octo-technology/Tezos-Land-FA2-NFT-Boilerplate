#include "../../domain_storage/storage_definition.mligo"
#include "../helpers/fa2_transfer_helpers.mligo"
#include "../helpers/land_transfer_helpers.mligo"

type buy_param = {
  id : token_id;
}
(**
Buy a land from the on_sale list, and transfer it to the buyer
@return storage with modified operators and on_sale lists
*)
let buy(buy_parameters, storage : buy_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let land_price : price = match Big_map.find_opt buy_parameters.id storage.market.on_sale with
    | None -> (failwith("This land is not on sale"): price)
    | Some price -> price
    in
    if not (land_price = Tezos.amount) then
       (failwith("The amount sent is not equal to the price of the land") : (operation  list) * nft_token_storage)
    else
      let land_owner_before_sale : address =  match Big_map.find_opt buy_parameters.id storage.ledger with
      | Some owner -> if (Tezos.sender = owner) then
      (failwith("The buyer is already the owner of this land"): address)
      else
      owner
      | None -> (failwith("This land is not owned by anyone") : address)
       in

      let token_transfer_transaction = [{from_=land_owner_before_sale; txs=[{to_=Tezos.sender; token_id=buy_parameters.id; amount=1n}]}] in
      let transfer_validator = default_operator_validator in
      let ledger_with_token_transferred = transfer (token_transfer_transaction, transfer_validator, storage.operators, storage.ledger, Some(Tezos.self_address)) in
      let owners_with_updated_seller = remove_token_from_owner (buy_parameters.id, land_owner_before_sale, storage.market.owners) in
      let owners_with_updated_buyer_and_seller = add_token_to_owner (buy_parameters.id, Tezos.sender, owners_with_updated_seller) in
      let on_sale_without_token_bought = Map.remove buy_parameters.id storage.market.on_sale in
      let operators_without_token_bought_operator = exec_update_operator([Remove_operator_p({owner=land_owner_before_sale; operator=Tezos.self_address; token_id=buy_parameters.id})], land_owner_before_sale, storage.operators) in

      let seller : unit contract = match (Tezos.get_contract_opt land_owner_before_sale: unit contract option) with
      | Some (contract) -> contract
      | None -> (failwith ("Not a contract") : unit contract)
      in
      let withdrawTransaction : operation = Tezos.transaction unit land_price seller in
      [withdrawTransaction], { storage with market={ storage.market with on_sale=on_sale_without_token_bought; owners=owners_with_updated_buyer_and_seller }; ledger=ledger_with_token_transferred; operators=operators_without_token_bought_operator }
