(** Helper contract to query FA2 `Balance_of` entry point and metadata *)
#include "tzip-12/lib/fa2_convertors.mligo"

type storage =
  | State of balance_of_response list
  | Empty



type query_param = {
  fa2 : address;
  requests : balance_of_request_michelson list;
}

type query_metadata_param = {
  fa2 : address;
  ids : token_id list;
}

type param =
  | Query of query_param
  | Response of balance_of_response_michelson list
  | Verify_not_fungible of query_metadata_param
  | Default of unit

let main (p, s : param * storage) : (operation list) * storage =
  match p with

  | Query q ->
    (* preparing balance_of request and invoking FA2 *)
    let aux : balance_of_param_aux = {
      requests = q.requests;
      callback =
        (Operation.get_entrypoint "%response" Current.self_address :
          (balance_of_response_michelson list) contract);
    } in
    let bpm = Layout.convert_to_right_comb (aux : balance_of_param_aux) in
    let fa2 : balance_of_param_michelson contract = 
      Operation.get_entrypoint "%balance_of" q.fa2 in
    let q_op = Operation.transaction bpm 0mutez fa2 in
    [q_op], s

  | Response responses_michelson ->
    (* 
    getting FA2 balance_of_response and putting it into storage
    for off-chain inspection
    *)
    let responses = List.map
      (fun (rm : balance_of_response_michelson) ->
        balance_of_response_from_michelson rm
      )
      responses_michelson
    in
    ([] : operation list), State responses

  | Verify_not_fungible qmp -> 
  // to rework
    let pmm = Layout.convert_to_right_comb ({ token_ids=qmp.ids; handler=fun(l: token_metadata_michelson list)-> let verify = (fun(tmm: token_metadata_michelson)-> let tm : token_metadata = Layout.convert_from_right_comb(tmm) in if tm.decimals <> 0n then failwith("not a NFT") else unit) in List.iter verify l } : token_metadata_param) in
    let ci : token_metadata_param_michelson contract option = Tezos.get_entrypoint_opt "%token_metadata" qmp.fa2 in
    let c : token_metadata_param_michelson contract = match ci with
    | None -> (failwith("token_metadata not implemented") : token_metadata_param_michelson contract)
    | Some ep -> ep
    in
    let op : operation = Tezos.transaction pmm 0mutez c in 
    [op], s

  | Default u -> ([] : operation list), s


// ligo compile-contract inspector.mligo main

// ligo compile-storage inspector.mligo main 'Empty'
// ligo compile-parameter inspector.mligo main 'Query({fa2=("KT1N1pKhoswiMLYNGgQ5pWnhQXevLVSvvxTD": address); requests=[ Layout.convert_to_right_comb(({ owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); token_id=1n }: balance_of_request))]})'
// ligo dry-run inspector.mligo main 'Query({fa2=("KT1N1pKhoswiMLYNGgQ5pWnhQXevLVSvvxTD": address); requests=[ Layout.convert_to_right_comb(({ owner=("tz1b7tUupMgCNw2cCLpKTkSD1NZzB5TkP2sv":address); token_id=1n }: balance_of_request))]})' 'Empty'


//ligo dry-run inspector.mligo main 'Verify_not_fungible({fa2=("KT1N1pKhoswiMLYNGgQ5pWnhQXevLVSvvxTD": address); ids=[1n]})' 'Empty'