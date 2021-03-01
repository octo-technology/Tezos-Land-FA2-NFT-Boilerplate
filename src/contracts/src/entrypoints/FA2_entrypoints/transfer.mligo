(**
FA2 transfer
A list of transfer is carried out.
@return callback operation
*)

let fa2_transfer (transfers_list, storage: transfer list * nft_token_storage): (operation  list) * nft_token_storage =
    let validator = default_operator_validator in
    let (new_ledger, new_owners, new_lands)  = transfer (transfers_list, validator, storage.operators, storage.ledger, storage.market.owners, storage.market.lands, Some(Tezos.sender)) in
    let new_storage = { storage with ledger = new_ledger; market = { storage.market with owners = new_owners; lands=new_lands}; }
    in
    ([] : operation list), new_storage