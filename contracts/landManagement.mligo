type coordinates = ( nat * nat )

type land = {
    name: string;
    description: string option;
    position: coordinates;
    isOwned: bool;
    onSale: bool;
    price: nat;
    id: nat
}

type lands = (nat, land) big_map
type storage = {
    lands: lands;
}

type param_action_1 = nat

type params =
| Action_1 of param_action_1
| CreateLand of land

let createLand ( params, storage : land * storage) : (operation list) * storage =
    let newLand : land = params in
    let landsWithNewLand : lands = Big_map.add params.id newLand storage.lands in
    let newStorage : storage = { storage with lands = landsWithNewLand } in
    ([] : operation list), newStorage


let function_action1 ( params, storage : param_action_1 * storage) : (operation list) * storage =
    ([] : operation list), storage

let main ( params, storage : params * storage) : (operation list) * storage =
    match params with
    | Action_1 p -> function_action1(p, storage)
    | CreateLand p -> createLand(p, storage)


// ligo compile-contract src/contract.mligo main

// ligo compile-storage src/contract.mligo main '{ lands = (Big_map.empty : (nat, land) big_map) }'

// ligo compile-parameter src/contract.mligo main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n } )'
// ligo compile-parameter src/contract.mligo main 'CreateLand( { name = "nom"; description = Some("description"); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n } )'

// ligo dry-run src/contract.mligo main 'CreateLand({ name = "nom"; description = Some("description"); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n })' '{ lands = (Big_map.empty : (nat, land) big_map) }'
