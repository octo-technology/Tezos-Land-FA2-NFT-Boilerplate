const TezosLand = artifacts.require("TezosLand");
const { MichelsonMap } = require("@taquito/taquito");

const metadata_bigmap = new MichelsonMap();
metadata_bigmap.set(
    {from_: 1, to_: 100}, {
        "token_id":
            1,
        "symbol":
            "TLD",
        "name":
            "TezosLand",
        "decimals":
            0,
        "extras":
           new MichelsonMap()
    }
);

const admin = "tz1ddb9NMYHZi5UzPdzTZMYQQZoMub195zgv"
const empty_lands = new MichelsonMap()
const empty_sales = []
const empty_ledger = new MichelsonMap()
const empty_owners = new MichelsonMap()
const empty_operators = new MichelsonMap()
const lands_grid_height = 10
const lands_grid_width = 10
const last_used_id = 1
const token_defs = [{"from_": 1, "to_": 100}]

const initial_storage = {
    "market": {
        "lands": empty_lands,
        "admin": admin,
        "height": lands_grid_height,
        "width": lands_grid_width,
        "sales": empty_sales,
        "owners": empty_owners
    },
    "ledger": empty_ledger,
    "operators":empty_operators,
    "metadata": {
        "last_used_id": last_used_id,
        "metadata": metadata_bigmap,
        "token_defs": token_defs
        }
};

module.exports = async(deployer, _network, accounts)  => {
    deployer.deploy(TezosLand, initial_storage, { last_completed_migration: 0, owner: accounts[0] });
};
