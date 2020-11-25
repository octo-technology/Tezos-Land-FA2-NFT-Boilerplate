type withdraw_param = sale

(**
Withdraw the land on sale from the "on_sale" list and removes this contract as an operator for this tokenœ
@return storage with modified operators and on_sale lists
*)
let withdraw_from_sale (withdraw_param, storage : withdraw_param * nft_token_storage) : (operation  list) * nft_token_storage =
    if not is_owner(withdraw_param.token_id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can withdraw it from sale") : (operation  list) * nft_token_storage)
    else
        let token_on_sale : bool = Set.mem withdraw_param storage.market.sales in
        if token_on_sale then
            let operators_without_token_operator = exec_update_operator([Remove_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=withdraw_param.token_id})], Tezos.sender, storage.operators) in
            let sales_without_removed_land = Set.remove withdraw_param storage.market.sales in
            let land_on_sale : land = match Big_map.find_opt withdraw_param.token_id storage.market.lands with
                | Some(land) -> land
                | None -> (failwith("This land does not exist") : land)
            in
            let updated_land : land = {land_on_sale with onSale = false} in
            let lands_with_updated_land: lands = Big_map.update withdraw_param.token_id (Some(updated_land)) storage.market.lands in
            ([] : operation list),  { storage with market = { storage.market with sales = sales_without_removed_land; lands = lands_with_updated_land }; operators = operators_without_token_operator }
        else
            (failwith("This land is not on sale"): (operation  list) * nft_token_storage)

