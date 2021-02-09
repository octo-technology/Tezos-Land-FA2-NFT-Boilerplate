type ownership = {
    owner: address;
    token_id: token_id;
}

let is_owner (token_id, address_to_check, ledger: token_id * address * ledger) : bool =
        match Big_map.find_opt token_id ledger with
        | None -> (failwith(fa2_token_undefined) : bool)
        | Some o -> o = address_to_check


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