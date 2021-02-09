const TezosLand = artifacts.require("TezosLand");
const { MichelsonMap } = require("@taquito/taquito");
const web3 = require("web3");
const { pkh } = require("../faucet.json");


const admin = pkh
const empty_lands = new MichelsonMap()
const empty_sales = []
const empty_land_ids = []
const empty_owners = new MichelsonMap()
const lands_grid_height = 10
const lands_grid_width = 10

const market = {
    "lands": empty_lands,
    "landIds": empty_land_ids,
    "admin": admin,
    "height": lands_grid_height,
    "width": lands_grid_width,
    "sales": empty_sales,
    "owners": empty_owners
}

const metadata = new MichelsonMap();
const token_info = new MichelsonMap();
const token_metadata = new MichelsonMap();
const empty_ledger = new MichelsonMap()
const empty_operators = new MichelsonMap()

metadata.set("", "");
metadata.set("interfaces", web3.utils.asciiToHex("TZIP-012").slice(2));
token_info.set(
    "symbol", web3.utils.asciiToHex("TLD").slice(2)
);
token_info.set(
    "name", web3.utils.asciiToHex("TezosLand").slice(2)
);
token_info.set(
    "decimals", web3.utils.asciiToHex("0").slice(2)
);

token_metadata.set(
    1, {
    token_info: token_info,
    token_id: 1
}
);

const initial_storage = {
    "market": market,
    "ledger": empty_ledger,
    "operators": empty_operators,
    "metadata": metadata,
    "token_metadata": token_metadata
};

module.exports = async (deployer, _network, accounts) => {
    deployer.deploy(TezosLand, initial_storage, { last_completed_migration: 0, owner: accounts[0] });
};
