type coordinates = ( nat * nat )

type name = string

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

type params =
| CreateLand of land
| ChangeLandName of (nat * name)

let createLand ( land, storage : land * storage) : (operation list) * storage =
    let newLand : land = land in
    let landsWithNewLand : lands = Big_map.add land.id newLand storage.lands in
    let newStorage : storage = { storage with lands = landsWithNewLand } in
    ([] : operation list), newStorage

let changeLandName (landId, name, storage : nat * name * storage) : (operation list) * storage =
    let landToBeChangedOption : land option = Big_map.find_opt landId storage.lands in
    match landToBeChangedOption with
        | None -> (failwith "Failure." : (operation list) * storage)
        | Some landToBeChanged ->
            let landChanged : land = { landToBeChanged with name = name } in
            let landsWithGivenLandNameChanged : lands = Big_map.update landId (Some(landChanged)) storage.lands  in
            let newStorage : storage = { storage with lands = landsWithGivenLandNameChanged } in
            ([] : operation list), newStorage

let main ( params, storage : params * storage) : (operation list) * storage =
    match params with
    | CreateLand p -> createLand(p, storage)
    | ChangeLandName p -> changeLandName(p.0, p.1, storage)


// ligo compile-contract src/contract.mligo main

// ligo compile-storage src/contract.mligo main '{ lands = (Big_map.empty : (nat, land) big_map) }'

// ligo compile-storage src/contract.mligo main '{ lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n })] }'

// ligo compile-parameter src/contract.mligo main 'CreateLand( { name = "nom"; description = (None : string option); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n } )'
// ligo compile-parameter src/contract.mligo main 'CreateLand( { name = "nom"; description = Some("description"); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n } )'
// ligo compile-parameter src/contract.mligo main 'ChangeLandName( (1n, "sdfxgjkljjhfgdgs"))'

// ligo dry-run src/contract.mligo main 'ChangeLandName( 1n, "sdfxgjkljjhfgdgs")' '{ lands = Big_map.literal [(1n, { name = "terrain_1"; description = Some("description_1"); position = (1n, 2n); isOwned = true; onSale = false; price = 200n; id = 1n })] }'