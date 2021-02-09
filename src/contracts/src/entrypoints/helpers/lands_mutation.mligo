let get_land_from_lands(token_id, lands: token_id * lands): land =
    let land : land = match Big_map.find_opt token_id lands with
        | Some(found_land) -> found_land
        | None -> (failwith("This land does not exist") : land)
    in
    land

let set_land_on_sale_flag(token_id, isOnSale, lands: token_id * bool * lands ) : lands =
    let land : land = get_land_from_lands(token_id, lands) in
    let updated_land : land = {land with onSale = isOnSale} in
    let lands_with_updated_land: lands = Big_map.update token_id (Some(updated_land)) lands in
    lands_with_updated_land

let update_price_on_sale_flag_for_a_land (token_id, isOnSale, price, lands: token_id * bool * price * lands ) : lands =
    let land : land =  get_land_from_lands(token_id, lands) in
    let updated_land : land = {land with onSale = isOnSale; price = Some(price)} in
    let lands_with_updated_land: lands = Big_map.update token_id (Some(updated_land)) lands in
    lands_with_updated_land