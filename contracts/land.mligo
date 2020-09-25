(**
Implementation of the FA2 interface for the TLD contract supporting multiple
types of NFTs. Each NFT type is represented by the range of token IDs - `token_def`.
 *)
#if !FA2_TLD_TOKEN
#define FA2_TLD_TOKEN

#include "tzip-12/fa2_interface.mligo"
#include "tzip-12/fa2_errors.mligo"
#include "tzip-12/lib/fa2_operator_lib.mligo"

#include "land_def.mligo"
#include "landManagement.mligo"


let is_admin(u,s: address * marketplace_storage) : bool =
  u = s.admin



// ??????
// let getOwner(x,y,ep, addr, s : nat * nat * string * address * nft_token_storage) : operation list =
//   let ciopt : (address option) contract option = Tezos.get_entrypoint_opt ("%"^ep) addr in
//   match ciopt with
//   | None -> (failwith("not a correct contract") : operation list)
//   | Some (ci) -> 
//     let i: nat = convert_position_to_index(x, y, s.market) in
//     let owner = Big_map.find_opt i s.ledger in 
//     let op : operation = Tezos.transaction owner 0mutez ci in 
//     [op]
  
  



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
    balance_of_response_to_michelson response
  in
  let responses = List.map to_balance p.requests in
  Operation.transaction responses 0mutez p.callback

(**
Update leger balances according to the specified transfers. Fails if any of the
permissions or constraints are violated.
@param txs transfers to be applied to the ledger
@param owner_validator function that validates of the tokens from the particular owner can be transferred. 
 *)
let transfer (txs, owner_validator, ops_storage, ledger
    : (transfer list) * operator_validator * operator_storage * ledger) : ledger =
  (* process individual transfer *)
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
            let u = owner_validator (o, Tezos.sender, dst.token_id, ops_storage) in
            Big_map.update dst.token_id (Some dst.to_) ll
      ) tx.txs l
  )
  in 
    
  List.fold make_transfer txs ledger

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

let fa2_main (param, storage : fa2_entry_points * nft_token_storage)
    : (operation  list) * nft_token_storage =
  match param with
  | Transfer txs_michelson ->
    let txs = transfers_from_michelson txs_michelson in
    //let validator = make_default_operator_validator Tezos.sender in
    let validator = default_operator_validator in
    let new_ledger = transfer (txs, validator, storage.operators, storage.ledger) in
    let new_storage = { storage with ledger = new_ledger; }
    in ([] : operation list), new_storage

  | Balance_of pm ->
    let p = balance_of_param_from_michelson pm in
    let op = get_balance (p, storage.ledger) in
    [op], storage

  | Update_operators updates_michelson ->
    let updates = operator_updates_from_michelson updates_michelson in
    let updater = Tezos.sender in
    let process_update = (fun (ops, update : operator_storage * update_operator) ->
      let u = validate_update_operators_by_owner (update, updater) in
      update_operators (update, ops)
    ) in
    let new_ops = 
      List.fold process_update updates storage.operators in
    let new_storage = { storage with operators = new_ops; } in
    ([] : operation list), new_storage

  | Token_metadata_registry callback ->
    (* the contract stores its own token metadata and exposes `token_metadata` entry point *)
    let callback_op = Operation.transaction Tezos.self_address 0mutez callback in
    [callback_op], storage

type mint_param = {
    token_id: token_id;
    owner: address;
    operator: address option;
}

let mint (param, store : mint_param * nft_token_storage) : (operation  list) * nft_token_storage =
    if not is_admin(Tezos.sender, store.market) 
    then (failwith("need admin privilege") : (operation  list) * nft_token_storage)
    else
    // ensure token-id is not owned
    let really_mint (p,s : mint_param * nft_token_storage) : (operation  list) * nft_token_storage = 
       // payment ??? 
        // mint in ledger
        let new_ledger = Big_map.update param.token_id (Some(param.owner)) s.ledger in
        let opaddrOpt = param.operator in
        match opaddrOpt with
        | None -> ([] : operation list),  { s with ledger = new_ledger }
        | Some(op) -> 
            // add operator
            let update : update_operator = Add_operator_p({ owner = param.owner; operator = op; token_id = param.token_id; }) in
            let new_operators = update_operators (update, s.operators) in 
            ([] : operation list),  { s with ledger = new_ledger; operators = new_operators }
    in
    let ownrOpt : address option = Big_map.find_opt param.token_id store.ledger in
    match ownrOpt with
    | Some(ownr) -> (failwith(fa2_token_undefined): (operation  list) * nft_token_storage)
    | None -> really_mint (param, store)
 

  type nft_entry_points =
  | Fa2 of fa2_entry_points
  | Metadata of fa2_token_metadata
  | Mint of mint_param
  | CreateLand of land
  | ChangeLandName of (nat * name)

  let nft_token_main (param, storage : nft_entry_points * nft_token_storage)
      : (operation  list) * nft_token_storage =
    match param with
    | Fa2 fa2 -> fa2_main (fa2, storage)
    | Metadata m -> ( match m with
      | Token_metadata pm ->
        let p : token_metadata_param = Layout.convert_from_right_comb pm in
        let metas = get_metadata (p.token_ids, storage.metadata) in
        let metas_michelson = token_metas_to_michelson metas in
        let u = p.handler metas_michelson in
        ([] : operation list), storage
    )
    | Mint p -> mint(p,storage)
    | CreateLand p -> createLand(p, storage)
    | ChangeLandName p -> changeLandName(p.0, p.1, storage)


#endif

// ligo compile-contract land.mligo nft_token_main

//ligo compile-storage land.mligo nft_token_main '{ lands = (Big_map.empty : (nat, land) big_map); market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = (Big_map.empty : (token_id, address) big_map); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// ADD OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ lands = (Big_map.empty : (nat, land) big_map); market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// TRANSFER BY OPERATOR
// ligo compile-storage land.mligo nft_token_main '{ lands = (Big_map.empty : (nat, land) big_map); market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))'
// ligo dry-run --sender=tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))' '{ market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// REMOVE OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ lands = (Big_map.empty : (nat, land) big_map); market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// METADATA
//ligo compile-storage land.mligo nft_token_main '{ lands = (Big_map.empty : (nat, land) big_map); market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))' '{ market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (tmml : token_metadata_michelson list) -> list.map  (fun (tmm: token_metadata_michelson) -> let tm = Layout.convert_from_right_comb(tmm) in if tm.decimals <> 0n then failwith("not a NFT") else unit) tmml }: token_metadata_param))))'

// CREATE LAND
//ligo compile-storage land.mligo nft_token_main '{ lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200n; id = 1n })]; market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200n; id = 2n } )'
// ligo dry-run land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200n; id = 2n } )' '{ lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200n; id = 1n })]; market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// CHANGE LAND NAME
// ligo compile-parameter land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))'
// ligo dry-run land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))' '{ lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200n; id = 1n })]; market = { admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=[1n] }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'