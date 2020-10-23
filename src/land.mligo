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
#include "land_management.mligo"


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

let exec_update_operator (updates, updater, ops_storage : update_operator list * address * operator_storage) : operator_storage =
    let process_update = (fun (ops, update : operator_storage * update_operator) ->
      let u = validate_update_operators_by_owner (update, updater) in
      update_operators (update, ops)
    ) in
    List.fold process_update updates ops_storage

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
    let validator = default_operator_validator in
    let new_ledger = transfer (txs, validator, storage.operators, storage.ledger, Some(Tezos.sender)) in
    let new_storage = { storage with ledger = new_ledger; }
    in ([] : operation list), new_storage

  | Balance_of pm ->
    let p = balance_of_param_from_michelson pm in
    let op = get_balance (p, storage.ledger) in
    [op], storage

  | Update_operators updates_michelson ->
    let updates = operator_updates_from_michelson updates_michelson in
    let updater = Tezos.sender in
    let new_ops = exec_update_operator(updates, updater, storage.operators) in
    ([] : operation list), { storage with operators = new_ops; }


  | Token_metadata_registry callback ->
    (* the contract stores its own token metadata and exposes `token_metadata` entry point *)
    let callback_op = Operation.transaction Tezos.self_address 0mutez callback in
    [callback_op], storage

type mint_param = {
    token_id: token_id;
    owner: address;
    operator: address option;
}

type sell_param = {
  id : token_id;
  price : price;
}

type buy_param = {
  id : token_id;
}


let buy(buy_parameters, storage : buy_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let land_price : price = match Big_map.find_opt buy_parameters.id storage.market.to_sell with
    | None -> (failwith("This land is not on sale"): price)
    | Some price -> price
    in
    if not (land_price = Tezos.amount) then
       (failwith("The amount sent is not equal to the price of the land") : (operation  list) * nft_token_storage)
    else
      let land_owner_before_sale : address =  match Big_map.find_opt buy_parameters.id storage.ledger with
      | Some owner -> if (Tezos.sender = owner) then
      (failwith("The buyer is already the owner of this land"): address)
      else
      owner
      | None -> (failwith("This land is not owned by anyone") : address)
       in

      let token_transfer_transaction = [{from_=land_owner_before_sale; txs=[{to_=Tezos.sender; token_id=buy_parameters.id; amount=1n}]}] in
      let transfer_validator = default_operator_validator in
      let ledger_with_token_transferred = transfer (token_transfer_transaction, transfer_validator, storage.operators, storage.ledger, Some(Tezos.self_address)) in
      let to_sell_without_token_bought = Map.remove buy_parameters.id storage.market.to_sell in
      let operators_without_token_bought_operator = exec_update_operator([Remove_operator_p({owner=land_owner_before_sale; operator=Tezos.self_address; token_id=buy_parameters.id})], land_owner_before_sale, storage.operators) in

      let seller : unit contract = match (Tezos.get_contract_opt land_owner_before_sale: unit contract option) with
      | Some (contract) -> contract
      | None -> (failwith ("Not a contract") : unit contract)
      in
      let withdrawTransaction : operation = Tezos.transaction unit land_price seller in
      [withdrawTransaction], { storage with market={ storage.market with to_sell=to_sell_without_token_bought }; ledger=ledger_with_token_transferred; operators=operators_without_token_bought_operator }
(**
Put the land on sale in the "to_sell" list and add this contract as an operator for this token
@return storage with modified operators and to_sell lists
*)
let sell (sell_params, storage : sell_param * nft_token_storage) : (operation  list) * nft_token_storage =
  let land_price : price = match Big_map.find_opt sell_params.id storage.market.to_sell with
    | None -> (0mutez : price)
    | Some price -> (failwith("This land is already on sale"): price)
  in
  if not is_owner(sell_params.id, Tezos.sender, storage.ledger)
    then (failwith("Only the owner of a land can sell it") : (operation  list) * nft_token_storage)
    else
        let operators_with_token_operator = exec_update_operator([Add_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=sell_params.id})], Tezos.sender, storage.operators) in
        let to_sell_with_new_land_on_sale = Map.add sell_params.id sell_params.price storage.market.to_sell in
        ([] : operation list), { storage with market = { storage.market with to_sell = to_sell_with_new_land_on_sale }; operators = operators_with_token_operator }


// Create a land, and a token (they both have the same id), associate token to given owner, (and optionnaly setup an operator for this newly minted token)
let mint (mint_param, store : mint_param * nft_token_storage) : (operation  list) * nft_token_storage =
    // if not is_admin(Tezos.sender, store.market)
    // then (failwith("need admin privilege") : (operation  list) * nft_token_storage)
    // else

    let create_token_with_operator (p,s : mint_param * nft_token_storage) : (operation  list) * nft_token_storage =
       // TODO: default price .. payment to
       if (Tezos.amount = 200mutez) then
        let ledgder_with_minted_token = Big_map.add p.token_id p.owner s.ledger in
        let new_land = ({ name=""; description=(None:string option); position=convert_index_to_position(p.token_id, s.market); isOwned=true; onSale=false; price=200mutez; id=p.token_id }:land) in
        let lands_with_new_land = Big_map.add p.token_id new_land s.market.lands in
        match mint_param.operator with
        | None -> ([] : operation list),  { s with ledger = ledgder_with_minted_token; market = { s.market with lands=lands_with_new_land; } }
        | Some(operator_address) ->
            let update : update_operator = Add_operator_p({ owner = p.owner; operator = operator_address; token_id = p.token_id; }) in
            let operators_with_minted_token_operator = update_operators (update, s.operators) in
            ([] : operation list),  { s with ledger = ledgder_with_minted_token; operators = operators_with_minted_token_operator; market = { s.market with lands=lands_with_new_land; } }
      else
        (failwith("Default mint price is 200mutez") : (operation  list) * nft_token_storage)
    in

    let token_owner_option : address option = Big_map.find_opt mint_param.token_id store.ledger in
    match token_owner_option with
    | Some(ownr) -> (failwith("This non-fungible token already exists"): (operation  list) * nft_token_storage)
    | None -> create_token_with_operator (mint_param, store)


  type nft_entry_points =
  | Fa2 of fa2_entry_points
  | Metadata of fa2_token_metadata
  | Mint of mint_param
  | ChangeLandName of change_land_name_param
  | ChangeLandDescription of (nat * name)
  | SellLand of sell_param
  | BuyLand of buy_param


  let main (param, storage : nft_entry_points * nft_token_storage)
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
    | ChangeLandName p -> change_land_name(p, storage)
    | ChangeLandDescription p -> changeLandDescription(p.0, p.1, storage)
    | SellLand p -> sell(p, storage)
    | BuyLand p -> buy(p, storage)


#endif




// ligo compile-contract land.mligo nft_token_main

//ligo compile-storage land.mligo nft_token_main '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = (Big_map.empty : (token_id, address) big_map); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// ADD OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// TRANSFER BY OPERATOR
// ligo compile-storage land.mligo nft_token_main '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))'
// ligo dry-run --sender=tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))' '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// REMOVE OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)])  }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// METADATA
//ligo compile-storage land.mligo nft_token_main '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))' '{ market = { lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (tmml : token_metadata_michelson list) -> list.map  (fun (tmm: token_metadata_michelson) -> let tm = Layout.convert_from_right_comb(tmm) in if tm.decimals <> 0n then failwith("not a NFT") else unit) tmml }: token_metadata_param))))'

// CREATE LAND
// ligo compile-storage land.mligo nft_token_main '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 2n } )'
// ligo dry-run land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 2n } )' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// MINT
// ligo compile-storage land.mligo nft_token_main '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'Mint( { token_id=10n; owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); operator=(None: address option) } )'
// ligo dry-run --amount=0.0002 --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Mint( { token_id=2n; owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); operator=(None: address option) } )' '{ market = { availables=(Set.add 2n (Set.empty : token_id set)); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// CHANGE LAND NAME
// ligo compile-parameter land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))'
// ligo dry-run land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// SELL LAND
// ligo compile-storage land.mligo nft_token_main '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})'
// ligo dry-run land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo dry-run --sender="tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv" land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// BUY LAND (not working due to "FA2_NOT_OPERATOR")
// ligo compile-storage land.mligo nft_token_main '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'BuyLand({id=1n})'
// (echoue sur le montant) ligo dry-run --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo dry-run --amount=0.0001 --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// (echoue sur le montant) // ligo dry-run --amount=0.0002 --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
