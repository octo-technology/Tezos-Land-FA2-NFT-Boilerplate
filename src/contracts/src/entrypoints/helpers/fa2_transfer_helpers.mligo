let exec_update_operator (updates, updater, ops_storage : update_operator list * address * operator_storage) : operator_storage =
    let process_update = (fun (ops, update : operator_storage * update_operator) ->
      let u = validate_update_operators_by_owner (update, updater) in
      update_operators (update, ops)
    ) in
    List.fold process_update updates ops_storage

let add_token_to_owner_2 (token_id, new_owner, owners: token_id * address * owners) : owners =
        let owned_tokens_by_owner : token_id set = match Big_map.find_opt new_owner owners with
        | Some(ownr) -> ownr
        | None -> (Set.empty: token_id set) in
        let owned_tokens_by_owner_with_new_token : token_id set =  Set.add token_id owned_tokens_by_owner in
        let new_owners: owners = Big_map.update new_owner (Some owned_tokens_by_owner_with_new_token) owners in
        new_owners

let remove_token_from_owner_2 (token_id, new_owner, owners: token_id * address * owners) : owners =
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

let transfer_token_in_owners_2 (token_id, seller, buyer, owners : token_id * address * address * owners) : owners =
    let owners_with_updated_seller: owners = remove_token_from_owner_2 (token_id, seller, owners) in
    let owners_with_updated_buyer_and_seller: owners = add_token_to_owner_2 (token_id, buyer, owners_with_updated_seller) in
    owners_with_updated_buyer_and_seller


(**
Update leger balances according to the specified transfers. Fails if any of the
permissions or constraints are violated.
@param txs transfers to be applied to the ledger
@param owner_validator function that validates of the tokens from the particular owner can be transferred.
 *)
let transfer (txs, owner_validator, ops_storage, ledger, owners, emitter
          : (transfer list) * operator_validator * operator_storage * ledger * owners * address option) : ledger * owners =
  let make_transfer = (fun (l, tx : (ledger * owners) * transfer) ->
    List.fold
      (fun (ll, dst : (ledger * owners) * transfer_destination) ->
        if dst.amount = 0n
        then ll
        else if dst.amount <> 1n
        then (failwith fa2_insufficient_balance : (ledger * owners))
        else
          let owner = Big_map.find_opt dst.token_id ll.0 in
          match owner with
          | None -> (failwith fa2_token_undefined : (ledger * owners))
          | Some o ->
            if o <> tx.from_
            then (failwith fa2_insufficient_balance : (ledger * owners))
            else
            let emmitter : address = match emitter with
            | Some e -> e
            | None -> Tezos.sender
            in
            let u = owner_validator (o, emmitter, dst.token_id, ops_storage) in
            let ledger_with_transferred_token: ledger = Big_map.update dst.token_id (Some dst.to_) ll.0 in
            let new_owners: owners = transfer_token_in_owners_2 (dst.token_id, o, dst.to_, ll.1) in
            (ledger_with_transferred_token, new_owners)
      ) tx.txs l
  )
  in
  let ledger_and_owner = (ledger, owners) in
  List.fold make_transfer txs ledger_and_owner

let transfer_in_ledger (txs, owner_validator, ops_storage, ledger, emitter
    : (transfer list) * operator_validator * operator_storage * ledger * address option) : ledger =
  let make_transfer = (fun (l, tx : ledger * transfer) ->
    List.fold
      (fun (ll, dst : ledger * transfer_destination) ->
        if dst.amount = 0n
        then ll
        else if dst.amount <> 1n
        then (failwith fa2_insufficient_balance : ledger)
        else
          let owner = Big_map.find_opt dst.token_id ll in
          match owner with
          | None -> (failwith fa2_token_undefined : ledger)
          | Some o ->
            if o <> tx.from_
            then (failwith fa2_insufficient_balance : ledger)
            else
            let emmitter : address = match emitter with
            | Some e -> e
            | None -> Tezos.sender
            in
            let u = owner_validator (o, emmitter, dst.token_id, ops_storage) in
            Big_map.update dst.token_id (Some dst.to_) ll
      ) tx.txs l
  )
  in
  List.fold make_transfer txs ledger