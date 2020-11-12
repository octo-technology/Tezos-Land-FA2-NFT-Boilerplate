#include "../../domain_storage/storage_definition.mligo"

let changeLandDescription (landId, desc, storage : nat * string * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_owner(landId, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can change its description") : (operation  list) * nft_token_storage)
    else
    match Big_map.find_opt landId storage.market.lands with
        | None -> (failwith "Failure." : (operation list) * nft_token_storage)
        | Some ld ->
            let new_lands : lands = Big_map.update landId (Some({ ld with description = Some(desc) })) storage.market.lands  in
            let newStorage : nft_token_storage = { storage with market={ storage.market with lands = new_lands } } in
            ([] : operation list), newStorage