from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from test.tests_utils import *


class TestTransfer(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_the_owner_of_a_token_can_transfer_his_token_to_someone_else(self):
        # GIVEN
        token_id_owned_by_alice = 1
        name = "Land 1"
        description = ""
        position = [0, 0]
        isOwned = True
        onSale = False
        land = {"name": name,
                "description": description,
                "position": position,
                "isOwned": isOwned,
                'owner': alice,
                "onSale": onSale,
                "price": None,
                "id": token_id_owned_by_alice}
        lands = {token_id_owned_by_alice: land}
        transfer_transaction = [{"from_": alice,
                                 "txs": [{"to_": frank,
                                          "token_id": token_id_owned_by_alice,
                                          "amount": 1}]}]
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                            lands=lands)

        # WHEN
        result = self.nftContract.transfer(transfer_transaction
                                           ).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertEqual(1, len(result.big_map_diff['ledger'].keys()))
        self.assertEqual(frank, result.big_map_diff['ledger'][1])
        self.assertFalse(alice in result.big_map_diff['ledger'].keys())

    def test_the_operator_of_a_token_can_transfer_it_to_someone_else(self):
        # GIVEN
        token_id_owned_by_alice = 1
        name = "Land 1"
        description = ""
        position = [0, 0]
        isOwned = True
        onSale = False
        land = {"name": name,
                "description": description,
                "position": position,
                "isOwned": isOwned,
                'owner': alice,
                "onSale": onSale,
                "price": None,
                "id": token_id_owned_by_alice}
        lands = {token_id_owned_by_alice: land}
        transfer_transaction = [{"from_": alice,
                                 "txs": [{"to_": frank,
                                          "token_id": token_id_owned_by_alice,
                                          "amount": 1}]}]
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                            operators={(alice, bob, 1): None},
                                                            lands=lands)
        # WHEN
        result = self.nftContract.transfer(transfer_transaction).result(
            storage=storage_with_alice_owning_a_land,
            source=bob
        )

        # THEN
        self.assertEqual(1, len(result.big_map_diff['ledger'].keys()))
        self.assertEqual(frank, result.big_map_diff['ledger'][1])
        self.assertFalse(alice in result.big_map_diff['ledger'].keys())

    def test_a_token_cannot_be_transferred_if_it_does_not_exist(self):
        with self.assertRaises(MichelsonRuntimeError) as unexisting_token_error:
            # GIVEN
            token_id_owned_by_alice = 1
            unexisting_token_id = 6789
            transfer_transaction = [{"from_": alice,
                                     "txs": [{"to_": frank,
                                              "token_id": unexisting_token_id,
                                              "amount": 1}]}]
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                                operators={(alice, bob, 1): None})
            # WHEN
            result = self.nftContract.transfer(transfer_transaction).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        result_error_message = str(unexisting_token_error.exception.args[0]['with']['string'])
        self.assertEqual("FA2_TOKEN_UNDEFINED", result_error_message)

    def test_two_nft_tokens_cannot_be_transferred(self):
        with self.assertRaises(MichelsonRuntimeError) as insufficient_balance_error:
            # GIVEN
            token_id_owned_by_alice = 1
            amount_of_tokens_to_transfer = 2
            transfer_transaction = [{"from_": alice,
                                     "txs": [{"to_": frank,
                                              "token_id": token_id_owned_by_alice,
                                              "amount": amount_of_tokens_to_transfer}]}]
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                                operators={(alice, bob, 1): None})
            # WHEN
            result = self.nftContract.transfer(transfer_transaction).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        result_error_message = str(insufficient_balance_error.exception.args[0]['with']['string'])
        self.assertEqual("FA2_INSUFFICIENT_BALANCE", result_error_message)

    def test_a_token_cannot_be_transferred_if_it_is_owned_by_from_address(self):
        with self.assertRaises(MichelsonRuntimeError) as not_owned_error:
            # GIVEN
            token_id_owned_by_alice = 1
            transfer_transaction = [{"from_": pascal,
                                     "txs": [{"to_": frank,
                                              "token_id": token_id_owned_by_alice,
                                              "amount": 1}]}]
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                                operators={(alice, bob, 1): None})
            # WHEN
            result = self.nftContract.transfer(transfer_transaction).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        result_error_message = str(not_owned_error.exception.args[0]['with']['string'])
        self.assertEqual("FA2_INSUFFICIENT_BALANCE", result_error_message)

    def test_a_token_can_only_be_transferred_by_its_owner_or_an_operator(self):
        with self.assertRaises(MichelsonRuntimeError) as not_operator_error:
            # GIVEN
            token_id_owned_by_alice = 1
            transfer_transaction = [{"from_": alice,
                                     "txs": [{"to_": frank,
                                              "token_id": token_id_owned_by_alice,
                                              "amount": 1}]}]
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                                operators={(alice, bob, 1): None})
            # WHEN
            self.nftContract.transfer(transfer_transaction).result(
                storage=storage_with_alice_owning_a_land,
                source=frank
            )

        # THEN
        result_error_message = str(not_operator_error.exception.args[0]['with']['string'])
        self.assertEqual("FA2_NOT_OPERATOR", result_error_message)

    def test_the_call_to_transfer_entrypoint_with_0_token_to_transfer_leaves_the_ledger_unchanged(self):
        # GIVEN
        token_id_owned_by_alice = 1
        number_of_tokens_to_transfer = 0
        transfer_transaction = [{"from_": alice,
                                 "txs": [{"to_": frank,
                                          "token_id": token_id_owned_by_alice,
                                          "amount": number_of_tokens_to_transfer}]}]
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_owned_by_alice: alice},
                                                            operators={(alice, bob, 1): None})
        # WHEN
        result = self.nftContract.transfer(transfer_transaction).result(
            storage=storage_with_alice_owning_a_land,
            source=frank
        )

        # THEN
        self.assertEqual(1, len(result.big_map_diff['ledger'].keys()))
        self.assertEqual({token_id_owned_by_alice: alice}, result.big_map_diff['ledger'])
        self.assertEqual({(alice, bob, 1): None}, result.big_map_diff['operators'])


if __name__ == '__main__':
    main()
