let fa2_token_metadata_registry (callback, storage: address contract * nft_token_storage): (operation  list) * nft_token_storage =
    (* the contract stores its own token metadata and exposes `token_metadata` entry point *)
    let callback_op = Operation.transaction Tezos.self_address 0mutez callback in
    [callback_op], storage