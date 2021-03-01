type sell_param = sale
(**
Put the land on sale in the "on_sale" list and add this contract as an operator for this token
Several checks are carried out: the token must exist and must not be on sale.
Only the owner of the token can put it on sale
@return storage with modified operators and on_sale lists
*)
let sell (sell_params, storage : sell_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let seller : address = match Big_map.find_opt sell_params.token_id storage.ledger with
        | Some(owner) -> owner
        | None -> (failwith("This token does not exist") : address)
    in
    if not (seller = Tezos.sender)
    then (failwith("Only the owner of a land can sell it") : (operation  list) * nft_token_storage)
    else
        let land : land = get_land_from_lands(sell_params.token_id, storage.market.lands) in
            if land.onSale then
                (failwith("This land is already on sale"): (operation  list) * nft_token_storage)
            else
                let update : update_operator = Add_operator({ owner = seller; operator = Tezos.self_address; token_id = sell_params.token_id; }) in
                let operators_with_contract_as_operator = exec_update_operator([update], Tezos.sender, storage.operators) in
                let new_sale : sale = ( sell_params : sale) in
                let sales_with_new_sale: sale set = Set.add new_sale storage.market.sales in
                let lands_with_updated_land: lands =  update_price_on_sale_flag_for_a_land(sell_params.token_id, true, sell_params.price, storage.market.lands) in
                ([] : operation list), { storage with market = { storage.market with sales = sales_with_new_sale; lands = lands_with_updated_land }; operators = operators_with_contract_as_operator }