#include "../../domain_storage/storage_definition.mligo"

let is_admin(u,s: address * marketplace_storage) : bool =
        u = s.admin

let is_owner (token_id, address_to_check, ledger: token_id * address * ledger) : bool =
        match Big_map.find_opt token_id ledger with
        | None -> (failwith(fa2_token_undefined) : bool)
        | Some o -> o = address_to_check

let add_token_to_owner (token_id, new_owner, owners: token_id * address * owners) : owners =
        let owned_tokens_by_owner : token_id set = match Big_map.find_opt new_owner owners with
        | Some(ownr) -> ownr
        | None -> (Set.empty: token_id set) in
        let owned_tokens_by_owner_with_new_token : token_id set =  Set.add token_id owned_tokens_by_owner in
        let new_owners: owners = Big_map.update new_owner (Some owned_tokens_by_owner_with_new_token) owners in
        new_owners

let remove_token_from_owner (token_id, new_owner, owners: token_id * address * owners) : owners =
        let owned_tokens_by_owner : token_id set = match Big_map.find_opt new_owner owners with
        | Some(ownr) -> ownr
        | None -> (Set.empty: token_id set) in
        let number_of_owned_lands : nat = Set.size owned_tokens_by_owner in
        if (number_of_owned_lands > 0n) then
            let owned_tokens_by_owner_with_new_token : token_id set =  Set.remove token_id owned_tokens_by_owner in
            let new_owners: owners = Big_map.update new_owner (Some owned_tokens_by_owner_with_new_token) owners in
            new_owners
        else
            owners

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