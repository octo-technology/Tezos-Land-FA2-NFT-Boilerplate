let get_land_from_lands(tokenId, lands: token_id * lands): land =
    let land : land = match Big_map.find_opt tokenId lands with
        | Some(found_land) -> found_land
        | None -> (failwith("This land does not exist") : land)
    in
    land

let set_new_land_owner(tokenId, newOwner, lands: token_id * address * lands ) : lands =
    let land : land = get_land_from_lands(tokenId, lands) in
    let updated_land : land = {land with owner = newOwner} in
    let lands_with_updated_land: lands = Big_map.update tokenId (Some(updated_land)) lands in
    lands_with_updated_land


let set_land_on_sale_flag(tokenId, isOnSale, lands: token_id * bool * lands ) : lands =
    let land : land = get_land_from_lands(tokenId, lands) in
    let updated_land : land = {land with onSale = isOnSale} in
    let lands_with_updated_land: lands = Big_map.update tokenId (Some(updated_land)) lands in
    lands_with_updated_land

let set_land_sale_flag_and_new_owner (tokenId, isOnSale, newOwner, lands: token_id * bool * address * lands ) : lands =
    let land : land = get_land_from_lands(tokenId, lands) in
    let updated_land : land = {land with onSale = isOnSale; owner = newOwner} in
    let lands_with_updated_land: lands = Big_map.update tokenId (Some(updated_land)) lands in
    lands_with_updated_land

let update_price_on_sale_flag_for_a_land (tokenId, isOnSale, price, lands: token_id * bool * price * lands ) : lands =
    let land : land =  get_land_from_lands(tokenId, lands) in
    let updated_land : land = {land with onSale = isOnSale; price = Some(price)} in
    let lands_with_updated_land: lands = Big_map.update tokenId (Some(updated_land)) lands in
    lands_with_updated_land