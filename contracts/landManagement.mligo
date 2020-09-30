#include "land_def.mligo"

let is_admin(u,s: address * marketplace_storage) : bool =
  u = s.admin

let is_owner (id, addr, l: token_id * address * ledger) : bool =
  match Big_map.find_opt id l with
  | None -> (failwith(fa2_token_undefined) : bool)
  | Some o -> o = addr

let createLand ( land, storage : land * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_admin(Tezos.sender, storage.market) 
    then (failwith("need admin privilege") : (operation  list) * nft_token_storage)
    else
        let newLand : land = land in
        let landsWithNewLand : lands = Big_map.add land.id newLand storage.market.lands in
        let newStorage : nft_token_storage = { storage with market= { storage.market with lands = landsWithNewLand } } in
        ([] : operation list), newStorage

let changeLandName (landId, name, storage : nat * name * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_owner(landId, Tezos.sender, storage.ledger)
    then (failwith("only owner can change land name") : (operation  list) * nft_token_storage)
    else
        let landToBeChangedOption : land option = Big_map.find_opt landId storage.market.lands in
        match landToBeChangedOption with
            | None -> (failwith "Failure." : (operation list) * nft_token_storage)
            | Some landToBeChanged ->
                let landChanged : land = { landToBeChanged with name = name } in
                let landsWithGivenLandNameChanged : lands = Big_map.update landId (Some(landChanged)) storage.market.lands  in
                let newStorage : nft_token_storage = { storage with market={ storage.market with lands = landsWithGivenLandNameChanged } } in
                ([] : operation list), newStorage

let changeLandDescription (landId, desc, storage : nat * string * nft_token_storage) : (operation list) * nft_token_storage =
    if not is_owner(landId, Tezos.sender, storage.ledger)
    then (failwith("only owner can change land description") : (operation  list) * nft_token_storage)
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

  // ??????
// let getOwner(x,y,ep, addr, s : nat * nat * string * address * nft_token_storage) : operation list =
//   let ciopt : (address option) contract option = Tezos.get_entrypoint_opt ("%"^ep) addr in
//   match ciopt with
//   | None -> (failwith("not a correct contract") : operation list)
//   | Some (ci) -> 
//     let i: nat = convert_position_to_index(x, y, s.market) in
//     let owner = Big_map.find_opt i s.ledger in 
//     let op : operation = Tezos.transaction owner 0mutez ci in 
//     [op]