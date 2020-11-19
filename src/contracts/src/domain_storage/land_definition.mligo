type name = string
type coordinates = ( nat * nat )
type description = string option
type price = tez
type land_type = Road | Water | Land | District | Plaza

type land = {
    name: name;
    description: description;
    position: coordinates;
    landType: land_type;
    isOwned: bool;
    onSale: bool;
    price: price option;
    id: nat
}