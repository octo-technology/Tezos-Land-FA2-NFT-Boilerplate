let fa2_update_operators (updates_michelson, storage: update_operator_michelson list * nft_token_storage): (operation  list) * nft_token_storage =
    let updates = operator_updates_from_michelson updates_michelson in
    let updater = Tezos.sender in
    let new_ops = exec_update_operator(updates, updater, storage.operators) in
    ([] : operation list), { storage with operators = new_ops; }