from os.path import dirname, join
from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from tests_utils import *


class TestSellLand(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        print("projectdir", project_dir)
        cls.nftContract = ContractInterface.create_from(join(project_dir, 'src/land.tz'))

    get_storage = get_storage

    def test_the_purchase_of_a_land_cannot_be_validated_if_there_are_no_buyer(self):
        with self.assertRaises(MichelsonRuntimeError) as no_buyer_error:
            # GIVEN
            token_id_sold_by_alice = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

            # WHEN
            self.nftContract.validateDeal(token_id_sold_by_alice).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(no_buyer_error.exception.args[0]['with']['string'])
        self.assertEqual("The purchase of this land cannot be validated because there is not any buyer", error_message)

    def test_the_purchase_of_a_land_not_on_sale_cannot_be_validated(self):
        with self.assertRaises(MichelsonRuntimeError) as not_on_sale:
            # GIVEN
            token_id_sold_by_alice = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                buyers={token_id_sold_by_alice: bob})

            # WHEN
            self.nftContract.validateDeal(token_id_sold_by_alice).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(not_on_sale.exception.args[0]['with']['string'])
        self.assertEqual("This land is not on sale", error_message)

    def test_the_purchase_of_a_land_cannot_be_validated_if_the_buyer_has_no_fund(self):
        with self.assertRaises(MichelsonRuntimeError) as no_fund_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = 100
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                buyers={token_id_sold_by_alice: bob},
                                                                to_sell={token_id_sold_by_alice: alice_land_price})

            # WHEN
            self.nftContract.validateDeal(token_id_sold_by_alice).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(no_fund_error.exception.args[0]['with']['string'])
        self.assertEqual("The buyer did not commit any fund", error_message)

    def test_the_purchase_of_a_land_cannot_be_validated_if_the_buyer_has_not_enough_fund(self):
        with self.assertRaises(MichelsonRuntimeError) as no_fund_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = 100
            fundsCommittedByBob = 50
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                buyers={token_id_sold_by_alice: bob},
                                                                to_sell={token_id_sold_by_alice: alice_land_price},
                                                                funds_by_owner={bob: fundsCommittedByBob})

            # WHEN
            self.nftContract.validateDeal(token_id_sold_by_alice).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(no_fund_error.exception.args[0]['with']['string'])
        self.assertEqual("The funds committed by the buyer are not enough", error_message)

    def test_the_purchase_of_a_land_cannot_only_be_validated_by_the_owner(self):
        with self.assertRaises(MichelsonRuntimeError) as not_owner_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = 100
            fundsCommittedByBob = 150
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                buyers={token_id_sold_by_alice: bob},
                                                                to_sell={token_id_sold_by_alice: alice_land_price},
                                                                funds_by_owner={bob: fundsCommittedByBob})

            # WHEN
            self.nftContract.validateDeal(token_id_sold_by_alice).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        error_message = str(not_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("The deal can only be validated by the owner", error_message)

    def test_the_purchase_of_a_land_can_be_validated_if_enough_funds_are_provided_by_the_buyer(self):
        # GIVEN
        alice_token_on_sale = 1
        alice_land_price = 100
        fundsCommittedByBob = 500
        storage_with_alice_owning_a_land = self.get_storage(ledger={alice_token_on_sale: alice},
                                                            buyers={alice_token_on_sale: bob},
                                                            to_sell={alice_token_on_sale: alice_land_price},
                                                            funds_by_owner={bob: fundsCommittedByBob})

        # WHEN
        result = self.nftContract.validateDeal(alice_token_on_sale).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )

        # THEN
        expected_bob_fund_decimal = Decimal((fundsCommittedByBob - alice_land_price) / 1000000).quantize(Decimal("0.0001"))
        expected_to_sell_map = {alice_token_on_sale: None}
        expected_buyers = {alice_token_on_sale: None}
        expected_ledger = {alice_token_on_sale: bob}
        expected_funds_by_owner = {bob: expected_bob_fund_decimal}
        expected_operations = {"source": 'KT1BEqzn5Wx8uJrZNvuS9DVHmLvG9td3fDLi', "destination": alice, "amount": "100",
                  "kind": 'transaction', "nonce": 0}
        self.assertEqual(expected_to_sell_map, result.big_map_diff['market/to_sell'])
        self.assertEqual(expected_funds_by_owner, result.big_map_diff['market/fundsByOwner'])
        self.assertEqual(expected_buyers, result.big_map_diff['market/buyers'])
        self.assertEqual(expected_ledger, result.big_map_diff['ledger'])
        self.assertEqual(expected_operations, result.operations[0])

if __name__ == '__main__':
    main()
