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

let transfer_token_in_owners (token_id, seller, buyer, owners : token_id * address * address * owners) : owners =
    let owners_with_updated_seller: owners = remove_token_from_owner (token_id, seller, owners) in
    let owners_with_updated_buyer_and_seller: owners = add_token_to_owner (token_id, buyer, owners_with_updated_seller) in
    owners_with_updated_buyer_and_seller