let fa2_transfer (txs, storage: transfer list * nft_token_storage): (operation  list) * nft_token_storage =
    let validator = default_operator_validator in
    let new_ledger = transfer (txs, validator, storage.operators, storage.ledger, Some(Tezos.sender)) in
    let new_storage = { storage with ledger = new_ledger; }
    in
    ([] : operation list), new_storage