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
        amountSent = Decimal(0.000100).quantize(Decimal("0.0001"))
        price = 100
        tokenId = 1
        result = self.nftContract.buyLand(1).with_amount(amountSent).result(
            storage={"market": {"fundsByOwner": {},
                                "buyers": {},
                                "lands": {},
                                "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                "height": 10, "width": 10,
                                "to_sell": {tokenId: price}},
                     "ledger": {tokenId: alice},
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
                     },
            source=bob
        )
        self.assertEqual({tokenId: amountSent}, result.big_map_diff['market/to_sell'])
        self.assertEqual({bob: amountSent}, result.big_map_diff['market/fundsByOwner'])
        self.assertEqual({tokenId: bob}, result.big_map_diff['market/buyers'])

    def test_a_land_on_sale_cannot_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_the_seller(self):
        with self.assertRaises(MichelsonRuntimeError):
            amountSent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 100
            tokenId = 1
            owner=alice
            buyer = alice
            result = self.nftContract.buyLand(1).with_amount(amountSent).result(
                storage={"market": {"fundsByOwner": {},
                                    "buyers": {},
                                    "lands": {},
                                    "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                    "height": 10, "width": 10,
                                    "to_sell": {tokenId: price}},
                         "ledger": {tokenId: alice},
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
                         },
                source=alice
            )

    def test_the_owner_of_a_land_can_sell_its_property(self):
        result = self.nftContract.sellLand({"id": 1, "price": 300}).result(
            storage={"market": {"fundsByOwner": {},
                                "buyers": {},
                                "lands": {},
                                "admin": "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z",
                                "height": 10, "width": 10,
                                "to_sell": {}},
                     "ledger": {1: alice},
                     "operators": {(alice, bob, 1): None},
                     "metadata": {"token_defs": [{"from_": 1, "to_": 100}],
                                  "last_used_id": 1,
                                  "metadata": {(1, 100): {"token_id": 1,
                                                          "symbol": "TLD",
                                                          "name": "TezosLand",
                                                          "decimals": 0,
                                                          "extras": {}
                                                          }
                                               }}
                     },
            source=alice
        )
        self.assertEqual({1: Decimal(0.0003).quantize(Decimal("0.0003"))}, result.big_map_diff["market/to_sell"])

if __name__ == '__main__':
    main()
