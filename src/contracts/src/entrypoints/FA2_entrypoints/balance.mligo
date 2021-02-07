(**
Retrieve the balances for the specified tokens and owners
@return callback operation
*)
let get_balance (p, ledger : balance_of_param * ledger) : operation =
  let to_balance = fun (r : balance_of_request) ->
    let owner = Big_map.find_opt r.token_id ledger in
    let response = match owner with
    | None -> (failwith fa2_token_undefined : balance_of_response)
    | Some o ->
      let bal = if o = r.owner then 1n else 0n in
      { request = r; balance = bal; }
    in
    response
  in
  let responses = List.map to_balance p.requests in
  Tezos.transaction responses 0mutez p.callback


let fa2_balance (pm, storage: balance_of_param * nft_token_storage): (operation  list) * nft_token_storage =
    let op = get_balance (pm, storage.ledger) in
    [op], storage