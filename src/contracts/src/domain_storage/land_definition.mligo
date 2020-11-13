type name = string
type coordinates = ( nat * nat )
type description = string option
type price = tez

type land = {
    name: name;
    description: description;
    position: coordinates;
    isOwned: bool;
    onSale: bool;
    price: price option;
    id: nat
}