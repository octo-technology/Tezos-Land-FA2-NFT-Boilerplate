#include "land_def.mligo"

let createLand ( land, storage : land * nft_token_storage) : (operation list) * nft_token_storage =
    let newLand : land = land in
    let landsWithNewLand : lands = Big_map.add land.id newLand storage.lands in
    let newStorage : nft_token_storage = { storage with lands = landsWithNewLand } in
    ([] : operation list), newStorage

let changeLandName (landId, name, storage : nat * name * nft_token_storage) : (operation list) * nft_token_storage =
    let landToBeChangedOption : land option = Big_map.find_opt landId storage.lands in
    match landToBeChangedOption with
        | None -> (failwith "Failure." : (operation list) * nft_token_storage)
        | Some landToBeChanged ->
            let landChanged : land = { landToBeChanged with name = name } in
            let landsWithGivenLandNameChanged : lands = Big_map.update landId (Some(landChanged)) storage.lands  in
            let newStorage : nft_token_storage = { storage with lands = landsWithGivenLandNameChanged } in
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