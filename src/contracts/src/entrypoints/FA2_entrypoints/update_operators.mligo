let fa2_update_operators (updates, storage: update_operator list * nft_token_storage): (operation  list) * nft_token_storage =
    let updater = Tezos.sender in
    let new_ops = exec_update_operator(updates, updater, storage.operators) in
    ([] : operation list), { storage with operators = new_ops; }