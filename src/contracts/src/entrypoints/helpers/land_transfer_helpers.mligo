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
    if (x < s.width && y < s.height) then
        y * s.width + x + 1n
    else
        (failwith("Coordinates out of range") : nat)

let convert_index_to_position(i, s: nat * marketplace_storage) : (nat * nat) =
  let fixed : nat = abs(i - 1n) in
  if i = 0n then (failwith("token 0 does not exist") : (nat * nat))
  else
  if s.width <> 0n then
  (fixed mod s.width, fixed / s.width)
  else
  (failwith("wrong Dimension") : (nat * nat))


let transfer_token_in_ledger (token_id, token_owner, buyer, operators, ledger, emitter : token_id * address * address * operator_storage * ledger * address option ) : ledger =
    let token_transfer_transaction = [{from_=token_owner; txs=[{to_=buyer; token_id=token_id; amount=1n}]}] in
    let transfer_validator: operator_validator = default_operator_validator in
    let ledger_with_token_transferred: ledger = transfer (token_transfer_transaction, transfer_validator, operators, ledger, emitter) in
    ledger_with_token_transferred

let transfer_token_in_owners (token_id, seller, buyer, owners : token_id * address * address * owners) : owners =
    let owners_with_updated_seller: owners = remove_token_from_owner (token_id, seller, owners) in
    let owners_with_updated_buyer_and_seller: owners = add_token_to_owner (token_id, buyer, owners_with_updated_seller) in
    owners_with_updated_buyer_and_seller



type ownership = {
    owner: address;
    token_id: token_id;
}

let check_token_id_is_owned_by_given_owner (ownership, ledger: ownership * ledger) : bool =
    match Big_map.find_opt ownership.token_id ledger with
        | Some(owner) -> if (owner = ownership.owner) then
                            true
                         else
                            false
        | None -> false

let check_owner_owns_a_given_token_id (ownership, owners: ownership * owners) : bool =
    match Big_map.find_opt ownership.owner owners with
        | Some (tokens) -> Set.mem ownership.token_id tokens
        | None -> false

let check_ownership_is_consistent_in_ledger_and_owners (ownership, ledger, owners : ownership * ledger * owners ) : bool =
    let token_id_is_owned_by_owner_in_ledger: bool = check_token_id_is_owned_by_given_owner (ownership, ledger) in
    let owner_owns_a_given_token_id_in_owners: bool = check_owner_owns_a_given_token_id (ownership, owners) in
    if (token_id_is_owned_by_owner_in_ledger && owner_owns_a_given_token_id_in_owners) then
        true
    else
        false

let get_land_from_lands(token_id, lands: token_id * lands): land =
    let land : land = match Big_map.find_opt token_id lands with
        | Some(found_land) -> found_land
        | None -> (failwith("This land does not exist") : land)
    in
    land

let set_land_on_sale_flag(token_id, isOnSale, lands: token_id * bool * lands ) : lands =
    let land : land = get_land_from_lands(token_id, lands) in
    let updated_land : land = {land with onSale = isOnSale} in
    let lands_with_updated_land: lands = Big_map.update token_id (Some(updated_land)) lands in
    lands_with_updated_land

let update_price_on_sale_flag_for_a_land (token_id, isOnSale, price, lands: token_id * bool * price * lands ) : lands =
    let land : land =  get_land_from_lands(token_id, lands) in
    let updated_land : land = {land with onSale = isOnSale; price = Some(price)} in
    let lands_with_updated_land: lands = Big_map.update token_id (Some(updated_land)) lands in
    lands_with_updated_land