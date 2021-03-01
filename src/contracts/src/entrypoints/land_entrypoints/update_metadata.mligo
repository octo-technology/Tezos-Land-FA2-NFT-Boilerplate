(**
Update the contract metadata
@return storage with modified metadata 
*)

let updateMetadata (new_url , storage : string * nft_token_storage) : (operation list) * nft_token_storage =
    let newMetadata = Big_map.update "" (Some(Bytes.pack new_url)) storage.metadata  in
    let newStorage : nft_token_storage = { storage with metadata=newMetadata } in
    ([] : operation list), newStorage