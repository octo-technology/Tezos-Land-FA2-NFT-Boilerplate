let exec_update_operator (updates, updater, ops_storage : update_operator list * address * operator_storage) : operator_storage =
    let process_update = (fun (ops, update : operator_storage * update_operator) ->
      let u = validate_update_operators_by_owner (update, updater) in
      update_operators (update, ops)
    ) in
    List.fold process_update updates ops_storage

(**
Update leger balances according to the specified transfers. Fails if any of the
permissions or constraints are violated.
@param txs transfers to be applied to the ledger
@param owner_validator function that validates of the tokens from the particular owner can be transferred.
 *)
let transfer (txs, owner_validator, ops_storage, ledger, emitter
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

