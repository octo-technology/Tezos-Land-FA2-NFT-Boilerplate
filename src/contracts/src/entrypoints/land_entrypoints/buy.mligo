type buy_param = sale

(**
Buy a land from the on_sale list, and transfer it to the buyer.
Several checks are carried out: the land must be on sale, owned by someone and must exist. The amount sent must match the land price
@return storage with modified operators and on_sale lists
*)
let buy(buy_parameters, storage : buy_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let buyer: address = Tezos.sender in
    let token_is_on_sale : bool = Set.mem buy_parameters storage.market.sales in
    if token_is_on_sale then
        if not (buy_parameters.price = Tezos.amount) then
           (failwith("The amount sent is not equal to the price of the land") : (operation  list) * nft_token_storage)
        else
          let land_owner_before_sale : address =  match Big_map.find_opt buy_parameters.token_id storage.ledger with
          | Some owner -> if (buyer = owner) then
                              (failwith("The buyer is already the owner of this land"): address)
                          else
                              owner
          | None -> (failwith("This land is not owned by anyone") : address)
           in

          let (ledger_with_token_transferred, owners_with_updated_buyer_and_seller, lands_with_updated_land ) : ledger * owners * lands = transfer_bought_token (buy_parameters.token_id, land_owner_before_sale, buyer, storage.operators, storage.ledger, storage.market.owners, storage.market.lands, Some(Tezos.self_address)) in
          let ledger_and_owners_are_consistent : bool = check_ownership_is_consistent_in_ledger_and_owners (({owner=buyer; token_id=buy_parameters.token_id} : ownership), ledger_with_token_transferred, owners_with_updated_buyer_and_seller) in

            if ledger_and_owners_are_consistent then
              let lands_with_updated_land: lands =  set_land_sale_flag_and_new_owner(buy_parameters.token_id, false, buyer, storage.market.lands) in
              let sales_without_token_bought: sale set = Set.remove buy_parameters storage.market.sales in
              let operators_without_token_bought_operator: operator_storage = exec_update_operator([Remove_operator({owner=land_owner_before_sale; operator=Tezos.self_address; token_id=buy_parameters.token_id})], land_owner_before_sale, storage.operators) in

              let seller : unit contract = match (Tezos.get_contract_opt land_owner_before_sale: unit contract option) with
              | Some (contract) -> contract
              | None -> (failwith ("Not a contract") : unit contract)
              in
              let withdrawTransaction : operation = Tezos.transaction unit buy_parameters.price seller in
              [withdrawTransaction], { storage with market={ storage.market with sales=sales_without_token_bought; owners=owners_with_updated_buyer_and_seller; lands = lands_with_updated_land }; ledger=ledger_with_token_transferred; operators=operators_without_token_bought_operator }
            else
                (failwith("Error: cannot transfer token"): (operation  list) * nft_token_storage)
    else
        (failwith("This land is not on sale"): (operation  list) * nft_token_storage)
