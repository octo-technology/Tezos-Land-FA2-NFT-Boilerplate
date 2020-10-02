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

type cancelsell_param = {
  id : token_id;
}

type validate_param = {
  id : token_id;
}

type cancelbuyer_param = {
  id : token_id;
}

let buy(p, s : buy_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let priceLand : price = match Big_map.find_opt p.id s.market.to_sell with
    | None -> (failwith("Land is not on sale"): price)
    | Some pl -> pl
    in
    let existingBuyer : unit = match Big_map.find_opt p.id s.market.buyers with
    | None -> unit
    | Some pl -> failwith("this land has already a buyer")
    in
    // verify amount is equal land price in tz
    if not (priceLand = Tezos.amount) then
       (failwith("The amount sent is not equal to the price of the land") : (operation  list) * nft_token_storage)
    else
      let new_fundsByOwner = match Big_map.find_opt Tezos.sender s.market.fundsByOwner with
      | None -> Big_map.add Tezos.sender Tezos.amount s.market.fundsByOwner
      | Some v -> Big_map.update Tezos.sender (Some(v + Tezos.amount)) s.market.fundsByOwner
      in 
      //let new_to_sell = Map.remove p.id s.market.to_sell in
      let new_buyers : (token_id, address) big_map = match Big_map.find_opt p.id s.market.buyers with
      | None -> Big_map.add p.id Tezos.sender s.market.buyers
      | Some add -> if add = Tezos.sender then 
        (failwith("You are the buyer , wait for validation") : (token_id, address) big_map)
      else 
        (failwith("already have a buyer, sorry too late") : (token_id, address) big_map)
      in
      ([] : operation list), { s with market={ s.market with fundsByOwner=new_fundsByOwner; buyers=new_buyers } }


// mark the land as "to_sell" and add an operator for this token
let sell (p, s : sell_param * nft_token_storage) : (operation  list) * nft_token_storage =
  if not is_owner(p.id, Tezos.sender, s.ledger)
    then (failwith("only owner can sell land") : (operation  list) * nft_token_storage)
    else
        // add admin as operator for this token
        //let new_operators = exec_update_operator([Add_operator_p({owner=Tezos.sender; operator=s.market.admin; token_id=p.id})], Tezos.sender, s.operators) in 
        // add contract as operator for this token
        //let new_operators = exec_update_operator([Add_operator_p({owner=Tezos.sender; operator=Tezos.self_address; token_id=p.id})], Tezos.sender, s.operators) in 
        let new_to_sell = Map.add p.id p.price s.market.to_sell in
        ([] : operation list), { s with market = { s.market with to_sell = new_to_sell } }


let validateDeal (p, s : validate_param * nft_token_storage) : (operation  list) * nft_token_storage =
    let buyer : address = match Big_map.find_opt p.id s.market.buyers with
    | None -> (failwith("no buyers") : address)
    | Some b -> b
    in
    // let pognon : tez = match Big_map.find_opt buyer s.market.fundsByOwner with
    // | None -> (failwith("no funds !! ") : tez)
    // | Some v -> v
    // in 
    let priceLand : price = match Big_map.find_opt p.id s.market.to_sell with
    | None -> (failwith("Land is not on sale"): price)
    | Some pl -> pl
    in
    let new_fundsByOwner : (address, tez) big_map = match Big_map.find_opt buyer s.market.fundsByOwner with
    | None -> (failwith("buyer has no fund") : (address, tez) big_map)
    | Some v -> if v >= priceLand then 
      Big_map.update buyer (Some(v - priceLand)) s.market.fundsByOwner
    else
      (failwith("buyer has not enough funds") : (address, tez) big_map)
    in 
    let new_buyers : (token_id, address) big_map = match Big_map.find_opt p.id s.market.buyers with
    | Some add -> Big_map.remove p.id s.market.buyers
    | None -> (failwith("You are the buyer , wait for validation") : (token_id, address) big_map)
    in
    let receiver : unit contract = match (Tezos.get_contract_opt Tezos.sender: unit contract option) with
    | Some (contract) -> contract
    | None -> (failwith ("Not a contract") : unit contract)
    in
    let withdrawTransaction : operation = Tezos.transaction unit priceLand receiver in
    let new_to_sell = Map.remove p.id s.market.to_sell in
    let txs = [{from_=Tezos.sender; txs=[{to_=buyer; token_id=p.id; amount=1n}]}] in
    let validator = default_operator_validator in
    let new_ledger = transfer (txs, validator, s.operators, s.ledger) in
    [ withdrawTransaction ], { s with ledger = new_ledger; market={ s.market with fundsByOwner=new_fundsByOwner; buyers=new_buyers; to_sell=new_to_sell } }


let cancelBuyer (p, s : cancelbuyer_param * nft_token_storage) : (operation  list) * nft_token_storage =
  match Big_map.find_opt p.id s.market.buyers with 
  | None -> (failwith ("No buyer for this token") : (operation  list) * nft_token_storage)
  | Some buyer -> if buyer = Tezos.sender then
      let priceLand : price = match Big_map.find_opt p.id s.market.to_sell with
      | None -> (failwith("Land is not on sale"): price)
      | Some pl -> pl
      in
      let new_buyers = Big_map.remove p.id s.market.buyers in
      let new_fundsByOwner : (address, tez) big_map = match Big_map.find_opt buyer s.market.fundsByOwner with
      | None -> (failwith("Should not be possible:buyer has no fund") : (address, tez) big_map)
      | Some v -> if v >= priceLand then 
          Big_map.update buyer (Some(v - priceLand)) s.market.fundsByOwner
        else
          (failwith("Should not be possible: buyer has not enough balance to refund for this sell") : (address, tez) big_map)
      in 
      let receiver : unit contract = match (Tezos.get_contract_opt buyer: unit contract option) with
      | Some (contract) -> contract
      | None -> (failwith ("Not a contract") : unit contract)
      in
      let refundTransaction : operation = Tezos.transaction unit priceLand receiver in
      // transfer back
      [ refundTransaction ], { s with market={ s.market with fundsByOwner=new_fundsByOwner; buyers=new_buyers } }
    else
      (failwith ("Only buyer of this token can cancel the deal") : (operation  list) * nft_token_storage)


let cancelSell (p, s : cancelsell_param * nft_token_storage) : (operation  list) * nft_token_storage =
  match Big_map.find_opt p.id s.ledger with 
  | None ->  (failwith(fa2_token_undefined) : (operation  list) * nft_token_storage)
  | Some ow -> if Tezos.sender = ow then
      match Big_map.find_opt p.id s.market.buyers with 
      | None -> 
        let new_to_sell = Map.remove p.id s.market.to_sell in
        ([]: operation list), { s with market={ s.market with to_sell=new_to_sell } }
      | Some buyer -> 
        let priceLand : price = match Big_map.find_opt p.id s.market.to_sell with
        | None -> (failwith("Land is not on sale"): price)
        | Some pl -> pl
        in
        let new_fundsByOwner : (address, tez) big_map = match Big_map.find_opt buyer s.market.fundsByOwner with
        | None -> (failwith("Should not be possible:buyer has no fund") : (address, tez) big_map)
        | Some v -> if v >= priceLand then 
          Big_map.update buyer (Some(v - priceLand)) s.market.fundsByOwner
        else
          (failwith("Should not be possible: buyer has not enough balance to refund for this sell") : (address, tez) big_map)
        in
        let new_to_sell = Map.remove p.id s.market.to_sell in
        let new_buyers = Big_map.remove p.id s.market.buyers in
        let receiver : unit contract = match (Tezos.get_contract_opt buyer: unit contract option) with
        | Some (contract) -> contract
        | None -> (failwith ("Not a contract") : unit contract)
        in
        let refundTransaction : operation = Tezos.transaction unit priceLand receiver in
        [ refundTransaction ], { s with market={ s.market with fundsByOwner=new_fundsByOwner; buyers=new_buyers; to_sell=new_to_sell } }
    else 
      (failwith("") : (operation  list) * nft_token_storage)


// Create a land, and a token (they both have the same id), associate token to given owner, (and optionnaly setup an operator for this newly minted token)
let mint (param, store : mint_param * nft_token_storage) : (operation  list) * nft_token_storage =
    // if not is_admin(Tezos.sender, store.market) 
    // then (failwith("need admin privilege") : (operation  list) * nft_token_storage)
    // else
    
    let really_mint (p,s : mint_param * nft_token_storage) : (operation  list) * nft_token_storage = 
       // TODO: default price .. payment to
       if (Tezos.amount = 200mutez) then 
        // mint in ledger
        let new_ledger = Big_map.add p.token_id p.owner s.ledger in
        // let new_ledger = match Big_map.find_opt p.token_id s.ledger with 
        // | None ->  Big_map.add p.token_id p.owner s.ledger 
        // | Some ownr -> (failwith("token already exist") : ledger)
        // in
        let new_land = ({ name=""; description=(None:string option); position=convert_index_to_position(p.token_id, s.market); isOwned=true; onSale=false; price=200mutez; id=p.token_id }:land) in
        let new_lands = Big_map.add p.token_id new_land s.market.lands in
        let opaddrOpt = param.operator in
        match opaddrOpt with
        | None -> ([] : operation list),  { s with ledger = new_ledger; market = { s.market with lands=new_lands; } }
        | Some(op) -> 
            // add operator
            let update : update_operator = Add_operator_p({ owner = p.owner; operator = op; token_id = p.token_id; }) in
            let new_operators = update_operators (update, s.operators) in 
            ([] : operation list),  { s with ledger = new_ledger; operators = new_operators; market = { s.market with lands=new_lands; } }
      else
        (failwith("Default mint price is 200mutez") : (operation  list) * nft_token_storage)
    in
    // ensure token-id is not owned
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
  | ChangeLandDescription of (nat * name)
  | SellLand of sell_param
  | BuyLand of buy_param
  | ValidateDeal of validate_param
  | CancelBuyer of cancelbuyer_param
  | CancelSell of cancelsell_param

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
    | ChangeLandDescription p -> changeLandDescription(p.0, p.1, storage)
    | SellLand p -> sell(p, storage)
    | BuyLand p -> buy(p, storage)
    | ValidateDeal p -> validateDeal(p, storage)
    | CancelBuyer p -> cancelBuyer(p, storage)
    | CancelSell p -> cancelSell(p, storage)


#endif




// ligo compile-contract land.mligo nft_token_main

//ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = (Big_map.empty : (token_id, address) big_map); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// ADD OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Add_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// TRANSFER BY OPERATOR
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))'
// ligo dry-run --sender=tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU land.mligo nft_token_main 'Fa2 (Transfer( [ transfer_to_michelson ({from_=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); txs=[{to_=("tz1gjaF81ZRRvdzjobyfVNsAeSC6PScjfQwN": address); token_id=1n; amount=1n}]}) ]))' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// REMOVE OPERATOR
//ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)])  }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Fa2 (Update_operators([ operator_update_to_michelson (Remove_operator_p({owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address);operator=("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address);token_id=1n})) ]))' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1faswCTDciRzE4oJ9jn2Vm2dvjeyA9fUzU":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=0n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// METADATA
//ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))'
//ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (l : token_metadata_michelson list) -> unit }: token_metadata_param))))' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = (Big_map.empty : (nat, land) big_map); admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

//ligo compile-parameter land.mligo nft_token_main 'Metadata (Token_metadata(Layout.convert_to_right_comb(({ token_ids=[1n]; handler=fun (tmml : token_metadata_michelson list) -> list.map  (fun (tmm: token_metadata_michelson) -> let tm = Layout.convert_from_right_comb(tmm) in if tm.decimals <> 0n then failwith("not a NFT") else unit) tmml }: token_metadata_param))))'

// CREATE LAND
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 2n } )'
// ligo dry-run land.mligo nft_token_main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 2n } )' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// MINT
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'Mint( { token_id=10n; owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); operator=(None: address option) } )'
// ligo dry-run --amount=0.0002 --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'Mint( { token_id=2n; owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); operator=(None: address option) } )' '{ market = { availables=(Set.add 2n (Set.empty : token_id set)); fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// CHANGE LAND NAME
// ligo compile-parameter land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))'
// ligo dry-run land.mligo nft_token_main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// SELL LAND
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})'
// ligo dry-run land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo dry-run --sender="tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv" land.mligo nft_token_main 'SellLand({id=1n; price=100mutez})' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty: (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = (Big_map.empty : ((address * (address * nat)), unit) big_map); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// BUY LAND (not working due to "FA2_NOT_OPERATOR")
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter land.mligo nft_token_main 'BuyLand({id=1n})'
// (echoue sur le montant) ligo dry-run --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo dry-run --amount=0.0001 --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// (echoue sur le montant) // ligo dry-run --amount=0.0002 --sender="tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v" land.mligo nft_token_main 'BuyLand({id=1n})' '{ market = { fundsByOwner=(Big_map.empty : (address, tez) big_map); buyers=(Big_map.empty : (token_id, address) big_map); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'

// VALIDATE DEAL (SELLER)
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty : (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'ValidateDeal({id=1n})'
// ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'ValidateDeal({id=1n})' '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// CANCEL BUYER
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty : (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'CancelBuyer({id=1n})'
// ligo dry-run --sender=tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v land.mligo nft_token_main 'CancelBuyer({id=1n})' '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'


// CANCEL SELLER
// ligo compile-storage land.mligo nft_token_main '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=(Big_map.empty : (token_id, price) big_map) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
// ligo compile-parameter --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'CancelSell({id=1n})'
// ligo dry-run --sender=tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv land.mligo nft_token_main 'CancelSell({id=1n})' '{ market = { fundsByOwner=Big_map.literal([(("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address),100mutez)]); buyers=Big_map.literal([(1n,("tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v":address))]); lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (0n, 0n); isOwned = true; onSale = false; price = 200mutez; id = 1n })]; admin = ("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address); height=10n; width=10n; to_sell=Big_map.literal ([(1n, 100mutez)]) }; ledger = Big_map.literal([(1n,("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address))]); operators = Big_map.literal([ ((("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv": address), (("tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z":address), 1n)), unit) ]); metadata = { token_defs = Set.add {from_=1n; to_=100n} (Set.empty : token_def set); last_used_id = 1n; metadata = Big_map.literal([ ({from_=1n;to_=100n},{token_id=1n; symbol="TLD"; name="TezosLand"; decimals=0n; extras=(Map.empty :(string, string) map)}) ]) }}'
