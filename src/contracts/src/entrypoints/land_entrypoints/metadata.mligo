(** Finds a definition of the token type (token_id range) associated with the provided token id *)
let find_token_def (tid, token_defs : token_id * (token_def set)) : token_def =
  let tdef = Set.fold (fun (res, d : (token_def option) * token_def) ->
    match res with
    | Some r -> res
    | None ->
      if tid >= d.from_ && tid < d.to_
      then  Some d
      else (None : token_def option)
  ) token_defs (None : token_def option)
  in
  match tdef with
  | None -> (failwith fa2_token_undefined : token_def)
  | Some d -> d

let get_metadata (tokens, meta : (token_id list) * token_storage )
    : token_metadata list =
  List.map (fun (tid: token_id) ->
    let tdef = find_token_def (tid, meta.token_defs) in
    let meta = Big_map.find_opt tdef meta.metadata in
    match meta with
    | Some m -> { m with token_id = tid; }
    | None -> (failwith "NO_DATA" : token_metadata)
  ) tokens


let get_metadata_entrypoint (m, storage : fa2_token_metadata * nft_token_storage) =
      ( match m with
      | Token_metadata pm ->
        let p : token_metadata_param = Layout.convert_from_right_comb pm in
        let metas = get_metadata (p.token_ids, storage.metadata) in
        let metas_michelson = token_metas_to_michelson metas in
        let u = p.handler metas_michelson in
        ([] : operation list), storage )