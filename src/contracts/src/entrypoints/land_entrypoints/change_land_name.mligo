#include "../../domain_storage/storage_definition.mligo"

type change_land_name_param = {
    token_id: token_id;
    new_land_name: string;
}
let change_land_name (change_land_name_param, storage : change_land_name_param * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_owner(change_land_name_param.token_id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can change its name") : (operation  list) * nft_token_storage)
    else
        let landToBeChangedOption : land option = Big_map.find_opt change_land_name_param.token_id storage.market.lands in
        match landToBeChangedOption with
            | None -> (failwith "Failure." : (operation list) * nft_token_storage)
            | Some landToBeChanged ->
                let landChanged : land = { landToBeChanged with name = change_land_name_param.new_land_name } in
                let landsWithGivenLandNameChanged : lands = Big_map.update change_land_name_param.token_id (Some(landChanged)) storage.market.lands  in
                let newStorage : nft_token_storage = { storage with market={ storage.market with lands = landsWithGivenLandNameChanged } } in
                ([] : operation list), newStorage