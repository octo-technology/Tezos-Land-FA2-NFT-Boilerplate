type sell_param = sale
(**
Put the land on sale in the "on_sale" list and add this contract as an operator for this token
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
        let token_already_on_sale : bool = Set.mem sell_params storage.market.sales in
            if token_already_on_sale then
                (failwith("This land is already on sale"): (operation  list) * nft_token_storage)
            else
                let update : update_operator = Add_operator_p({ owner = seller; operator = Tezos.self_address; token_id = sell_params.token_id; }) in
                let operators_with_contract_as_operator = exec_update_operator([update], Tezos.sender, storage.operators) in
                let new_sale : sale = ( sell_params : sale) in
                 let land_on_sale : land = match Big_map.find_opt sell_params.token_id storage.market.lands with
                    | Some(land) -> land
                    | None -> (failwith("This land does not exist") : land)
                in
                let updated_land : land = {land_on_sale with onSale = true} in
                let lands_with_updated_land: lands = Big_map.update sell_params.token_id (Some(updated_land)) storage.market.lands in
                let sales_with_new_sale: sale set = Set.add new_sale storage.market.sales in
                ([] : operation list), { storage with market = { storage.market with sales = sales_with_new_sale; lands = lands_with_updated_land }; operators = operators_with_contract_as_operator }