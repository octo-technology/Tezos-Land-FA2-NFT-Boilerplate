from os.path import dirname, join
from unittest import TestCase
from pytezos import ContractInterface, MichelsonRuntimeError

from pytezos import pytezos, ContractInterface, Key
from pytezos.operation.result import OperationResult
from pytezos.rpc.errors import RpcError
from pytezos.operation import fees

admin      = "tz1ibMpWS6n6MJn73nQHtK5f4ogyYC1z9T9z"
alice      = "tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf"
bob        = "tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v"
frank      = "tz1Qd971cetwNr5f4oKp9xno6jBvghZHRsDr"
pascal     = "tz1TgK3oaBaqcCHankT97AUNMjcs87Tfj5vb"
jacob      = "tz1VphG4Lgp39MfQ9rTUnsm7BBWyXeXnJSMZ"
lucina     = "tz1ZAZo1xW4Veq5t7YqWy2SMbLdskmeBmzqs"
mark       = "tz1ccWCuJqMxG4hoa1g5SKhgdTwXoJBM8kpc"
jean       = "tz1hQzKQpprB5JhNxZZRowEDRBoieHRAL84b"
boby       = "tz1hTic2GpaNumpTtYwqyPSBd9KcWifRMuEN"
bartholome = "tz1hv9CrgtaxiCayc567KUvCyWDQRF9sVNuf"
lucas      = "tz1iWMsg4UNSSQNKYsiH5s2maUZ9xBwymXxR"



class landContractTest(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        print("projectdir", project_dir)
        cls.nftContract = ContractInterface.create_from(join(project_dir, 'src/land.tz'))

    def test_add_operator(self):
        result = self.nftContract.update_operators([ { "add_operator": { "owner": alice, "operator": bob, "token_id": 1 } }]
        ).result(
            storage = {
            "ledger": { 1: alice },
            "operators": { },
            "metadata": {
                "token_defs" : [{ "from_": 1, "to_": 100 }],
                "last_used_id" : 1,
                "metadata" : { (1, 100): {"token_id" : 1,
                                        "symbol" : "TLD",
                                        "name" : "TezosLand",
                                        "decimals" : 0,
                                        "extras" : {}
                                        } 
                            }
                }
            },
            source = alice
        )
        self.assertEqual(1, len(result.big_map_diff['operators'].keys()))
        self.assertEqual (True, (alice, bob, 1) in result.big_map_diff['operators'].keys())

    def test_add_operator_2(self):
        result = self.nftContract.update_operators([ { "add_operator": { "owner": alice, "operator": bob, "token_id": 2 } }]
        ).result(
            storage = {
            "ledger": { 1: alice },
            "operators": { (alice, bob, 1): None },
            "metadata": {
                "token_defs" : [{ "from_": 1, "to_": 100 }],
                "last_used_id" : 1,
                "metadata" : { (1, 100): {"token_id" : 1,
                                        "symbol" : "TLD",
                                        "name" : "TezosLand",
                                        "decimals" : 0,
                                        "extras" : {}
                                        } 
                            }
                }
            },
            source = alice
        )
        self.assertEqual(2, len(result.big_map_diff['operators'].keys()))
        self.assertEqual (True, (alice, bob, 1) in result.big_map_diff['operators'].keys())
        self.assertEqual (True, (alice, bob, 2) in result.big_map_diff['operators'].keys())

    def test_add_operator_notowner(self):
        with self.assertRaises(MichelsonRuntimeError):
            self.nftContract.update_operators([ { "add_operator": { "owner": alice, "operator": bob, "token_id": 1 } }]).result(
                storage = {
                    "ledger": { 1: alice },
                    "operators": { }, 
                    "metadata": {
                        "token_defs" : [{ "from_": 1, "to_": 100 }],
                        "last_used_id" : 1,
                        "metadata" : { (1, 100): {"token_id" : 1,
                                                "symbol" : "TLD",
                                                "name" : "TezosLand",
                                                "decimals" : 0,
                                                "extras" : {}
                                                } 
                                    }
                        }
                },
                source = bob
            )

    def test_remove_operator(self):
        result = self.nftContract.update_operators([ { "remove_operator": { "own er": alice, "operator": bob, "token_id": 1 } }]
        ).result(
            storage = {
            "ledger": { 1: alice },
            "operators": { (alice, bob, 1): None },
            "metadata": {
                "token_defs" : [{ "from_": 1, "to_": 100 }],
                "last_used_id" : 1,
                "metadata" : { (1, 100): {"token_id" : 1,
                                        "symbol" : "TLD",
                                        "name" : "TezosLand",
                                        "decimals" : 0,
                                        "extras" : {}
                                        } 
                            }
                }
            },
            source = alice
        )
        # print(self.nftContract)
        print(result)
        print(result.parameters)
        print(result.storage)
        print(result.big_map_diff)
        print (result.big_map_diff['operators'])
        print (len(result.big_map_diff['operators'].keys()))
        self.assertEqual (0, len(result.operations))
        self.assertEqual (0, len(result.big_map_diff['operators'].keys()))

        
    # def test_remove_operator_unknown(self):
    #     result = self.nftContract.update_operators([ { "remove_operator": { "owner": alice, "operator": bob, "token_id": 2 } }]
    #     ).result(
    #         storage = {
    #         "ledger": { 1: alice, 2: frank },
    #         "operators": { (alice, bob, 1): None },
    #         "metadata": {
    #             "token_defs" : [{ "from_": 1, "to_": 100 }],
    #             "last_used_id" : 1,
    #             "metadata" : { (1, 100): {"token_id" : 1,
    #                                     "symbol" : "TLD",
    #                                     "name" : "TezosLand",
    #                                     "decimals" : 0,
    #                                     "extras" : {}
    #                                     } 
    #                         }
    #             }
    #         },
    #         source = alice
    #     )
    #     print (result.big_map_diff['operators'])
    #     print (len(result.big_map_diff['operators'].keys()))
    #     self.assertEqual (1, len(result.big_map_diff['operators'].keys()))

    # def test_remove_operator_notowner(self):
    #     with self.assertRaises(MichelsonRuntimeError):
    #         self.nftContract.update_operators([ { "remove_operator": { "owner": alice, "operator": bob, "token_id": 1 } }]).result(
    #             storage = {
    #                 "ledger": { 1: alice },
    #                 "operators": { (alice, bob, 1): None }, 
    #                 "metadata": {
    #                     "token_defs" : [{ "from_": 1, "to_": 100 }],
    #                     "last_used_id" : 1,
    #                     "metadata" : { (1, 100): {"token_id" : 1,
    #                                             "symbol" : "TLD",
    #                                             "name" : "TezosLand",
    #                                             "decimals" : 0,
    #                                             "extras" : {}
    #                                             } 
    #                                 }
    #                     }
    #             },
    #             source = bob
    #         )

    def test_transfer_owner(self):
        result = self.nftContract.transfer( [{ "from_": alice, "txs": [{ "to_": frank, "token_id": 1, "amount": 1 }] }]
        ).result(
            storage = {
            "ledger": { 1: alice },
            "operators": { },
            "metadata": {
                "token_defs" : [{ "from_": 1, "to_": 100 }],
                "last_used_id" : 1,
                "metadata" : { (1, 100): {"token_id" : 1,
                                        "symbol" : "TLD",
                                        "name" : "TezosLand",
                                        "decimals" : 0,
                                        "extras" : {}
                                        } 
                            }
                }
            },
            source = alice
        )
        print( result.big_map_diff['ledger'])
        self.assertEqual(1, len(result.big_map_diff['ledger'].keys()))
        self.assertEqual (frank, result.big_map_diff['ledger'][1])


    def test_transfer_operator(self):
        result = self.nftContract.transfer( [{ "from_": alice, "txs": [{ "to_": frank, "token_id": 1, "amount": 1 }] }]
        ).result(
            storage = {
            "ledger": { 1: alice },
            "operators": { (alice, bob, 1): None },
            "metadata": {
                "token_defs" : [{ "from_": 1, "to_": 100 }],
                "last_used_id" : 1,
                "metadata" : { (1, 100): {"token_id" : 1,
                                        "symbol" : "TLD",
                                        "name" : "TezosLand",
                                        "decimals" : 0,
                                        "extras" : {}
                                        } 
                            }
                }
            },
            source = bob
        )
        print( result.big_map_diff['ledger'])
        self.assertEqual(1, len(result.big_map_diff['ledger'].keys()))
        self.assertEqual (frank, result.big_map_diff['ledger'][1])

    def test_transfer_notowneroperator(self):
        with self.assertRaises(MichelsonRuntimeError):
            self.nftContract.transfer( [{ "from_": alice, "txs": [{ "to_": frank, "token_id": 1, "amount": 1 }] }]).result(
                storage = {
                    "ledger": { 1: alice },
                    "operators": { (alice, bob, 1): None }, 
                    "metadata": {
                        "token_defs" : [{ "from_": 1, "to_": 100 }],
                        "last_used_id" : 1,
                        "metadata" : { (1, 100): {"token_id" : 1,
                                                "symbol" : "TLD",
                                                "name" : "TezosLand",
                                                "decimals" : 0,
                                                "extras" : {}
                                                } 
                                    }
                        }
                },
                source = frank
            )