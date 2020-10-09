from os.path import dirname, join
from unittest import TestCase, main
from pytezos import ContractInterface, MichelsonRuntimeError

from pytezos import pytezos, ContractInterface, Key
from pytezos.operation.result import OperationResult
from pytezos.rpc.errors import RpcError
from pytezos.operation import fees

from decimal import Decimal

admin = "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z"
alice = "tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf"
bob = "tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v"
frank = "tz1Qd971cetwNr5f4oKp9xno6jBvghZHRsDr"
pascal = "tz1TgK3oaBaqcCHankT97AUNMjcs87Tfj5vb"
jacob = "tz1VphG4Lgp39MfQ9rTUnsm7BBWyXeXnJSMZ"
lucina = "tz1ZAZo1xW4Veq5t7YqWy2SMbLdskmeBmzqs"
mark = "tz1ccWCuJqMxG4hoa1g5SKhgdTwXoJBM8kpc"
jean = "tz1hQzKQpprB5JhNxZZRowEDRBoieHRAL84b"
boby = "tz1hTic2GpaNumpTtYwqyPSBd9KcWifRMuEN"
bartholome = "tz1hv9CrgtaxiCayc567KUvCyWDQRF9sVNuf"
lucas = "tz1iWMsg4UNSSQNKYsiH5s2maUZ9xBwymXxR"


class buyTest(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        print("projectdir", project_dir)
        cls.nftContract = ContractInterface.create_from(join(project_dir, 'src/land.tz'))

    def test_a_land_on_sale_can_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_not_the_seller(self):
        # GIVEN
        amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
        price = 100
        token_id = 1
        storage_with_alice_owning_a_land = {"market": {"fundsByOwner": {},
                                                       "buyers": {},
                                                       "lands": {},
                                                       "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                                       "height": 10, "width": 10,
                                                       "to_sell": {token_id: price}},
                                            "ledger": {token_id: alice},
                                            "operators": {},
                                            "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                                                         "last_used_id": 1,
                                                         "metadata": {(1, 100): {"token_id": 1,
                                                                                 "symbol": "TLD",
                                                                                 "name": "TezosLand",
                                                                                 "decimals": 0,
                                                                                 "extras": {}
                                                                                 }
                                                                      }}
                                            }
        # WHEN
        result = self.nftContract.buyLand(1).with_amount(amount_sent).result(
            storage=storage_with_alice_owning_a_land,
            source=bob
        )

        # THEN
        self.assertEqual({token_id: amount_sent}, result.big_map_diff['market/to_sell'])
        self.assertEqual({bob: amount_sent}, result.big_map_diff['market/fundsByOwner'])
        self.assertEqual({token_id: bob}, result.big_map_diff['market/buyers'])

    def test_a_land_on_sale_cannot_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_the_seller(self):
        with self.assertRaises(MichelsonRuntimeError):
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 100
            token_id = 1
            storage_with_alice_owning_a_land = {"market": {"fundsByOwner": {},
                                                           "buyers": {},
                                                           "lands": {},
                                                           "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                                           "height": 10, "width": 10,
                                                           "to_sell": {token_id: price}},
                                                "ledger": {token_id: alice},
                                                "operators": {},
                                                "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                                                             "last_used_id": 1,
                                                             "metadata": {(1, 100): {"token_id": 1,
                                                                                     "symbol": "TLD",
                                                                                     "name": "TezosLand",
                                                                                     "decimals": 0,
                                                                                     "extras": {}
                                                                                     }
                                                                          }}
                                                }

            self.nftContract.buyLand(1).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

    def test_the_owner_of_a_land_can_sell_its_property(self):
        token_id_sold_by_alice = 1
        alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
        storage_with_alice_owning_a_land = {"market": {"fundsByOwner": {},
                                                       "buyers": {},
                                                       "lands": {},
                                                       "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                                       "height": 10, "width": 10,
                                                       "to_sell": {}},
                                            "ledger": {token_id_sold_by_alice: alice},
                                            "operators": {(alice, bob, token_id_sold_by_alice): None},
                                            "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                                                         "last_used_id": 1,
                                                         "metadata": {(1, 100): {"token_id": token_id_sold_by_alice,
                                                                                 "symbol": "TLD",
                                                                                 "name": "TezosLand",
                                                                                 "decimals": 0,
                                                                                 "extras": {}
                                                                                 }
                                                                      }}
                                            }
        result = self.nftContract.sellLand({"id": token_id_sold_by_alice, "price": alice_land_price}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        self.assertEqual({token_id_sold_by_alice: alice_land_price}, result.big_map_diff["market/to_sell"])


if __name__ == '__main__':
    main()
