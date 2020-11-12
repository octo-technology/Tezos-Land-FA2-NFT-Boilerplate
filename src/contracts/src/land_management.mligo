#include "storage_definition.mligo"

type change_land_name_param = {
    token_id: token_id;
    new_land_name: string;
}
let is_admin(u,s: address * marketplace_storage) : bool =
  u = s.admin

let is_owner (token_id, address_to_check, ledger: token_id * address * ledger) : bool =
  match Big_map.find_opt token_id ledger with
  | None -> (failwith(fa2_token_undefined) : bool)
  | Some o -> o = address_to_check

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

let convert_position_to_index(x,y, s: nat * nat * marketplace_storage) : nat =
  y * s.width + x + 1n

let convert_index_to_position(i, s: nat * marketplace_storage) : (nat * nat) =
  let fixed : nat = abs(i - 1n) in
  if i = 0n then (failwith("token 0 does not exist") : (nat * nat))
  else
  if s.width <> 0n then 
  (fixed mod s.width, fixed / s.width)
  else
  (failwith("wrong Dimension") : (nat * nat))