type change_land_description_param = {
    token_id: token_id;
    new_land_description: string;
}

let changeLandDescription (parameters , storage : change_land_description_param * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_owner(parameters.token_id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can change its description") : (operation  list) * nft_token_storage)
    else
    match Big_map.find_opt parameters.token_id storage.market.lands with
        | None -> (failwith "This land does not exist" : (operation list) * nft_token_storage)
        | Some landToBeChanged ->
            let landChanged : land = { landToBeChanged with description = Some(parameters.new_land_description) } in
            let new_lands : lands = Big_map.update parameters.token_id (Some(landChanged)) storage.market.lands  in
            let newStorage : nft_token_storage = { storage with market={ storage.market with lands = new_lands } } in
            ([] : operation list), newStorage