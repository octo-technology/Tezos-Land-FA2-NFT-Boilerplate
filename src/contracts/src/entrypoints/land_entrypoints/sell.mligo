type sell_param = sale
(**
Put the land on sale in the "on_sale" list and add this contract as an operator for this token
@return storage with modified operators and on_sale lists
*)
let sell (sell_params, storage : sell_param * nft_token_storage) : (operation  list) * nft_token_storage =
    if not is_owner(sell_params.token_id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can sell it") : (operation  list) * nft_token_storage)
    else
        let token_already_on_sale : bool = Set.mem sell_params storage.market.sales in
            if token_already_on_sale then
                (failwith("This land is already on sale"): (operation  list) * nft_token_storage)
            else
                let operators_with_token_operator = exec_update_operator([Remove_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=sell_params.token_id})], Tezos.sender, storage.operators) in
                let new_sale : sale = ( sell_params : sale) in
                let sales_with_new_sale = Set.add new_sale storage.market.sales in
                ([] : operation list), { storage with market = { storage.market with sales = sales_with_new_sale }; operators = operators_with_token_operator }