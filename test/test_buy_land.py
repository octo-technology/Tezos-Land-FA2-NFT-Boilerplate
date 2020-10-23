from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from test.tests_utils import *


class TestBuyLand(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_a_land_on_sale_can_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_not_the_seller(self):
        # GIVEN
        amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
        price : int = 100
        token_id = 1
        to_sell = {token_id: price}
        storage_with_alice_selling_a_land = self.get_storage(ledger={token_id: alice},
                                                             to_sell=to_sell,
                                                             operators={(alice, self.nftContract.address, 1): None})
        # WHEN
        result = self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
            storage=storage_with_alice_selling_a_land,
            source=bob
        )

        # THEN

        self.assertEqual({1: None}, result.big_map_diff["market/to_sell"])
        self.assertEqual(bob, result.big_map_diff['ledger'][1])
        self.assertEqual({'source': self.nftContract.address, 'nonce': 0, 'kind': 'transaction', 'amount': str(price), 'destination': alice}, result.operations[0])
        self.assertEqual(False, (bob, self.nftContract.address, 1) in result.big_map_diff['operators'].keys())
        self.assertEqual(True, (alice, self.nftContract.address, 1) in result.big_map_diff['operators'].keys())

    def test_a_land_on_sale_cannot_be_bought_if_the_amount_is_not_matching_the_price(self):
        with self.assertRaises(MichelsonRuntimeError) as amount_not_matching_price_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 200
            token_id = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice}, to_sell={token_id: price})
            # WHEN
            result = self.nftContract.buyLand(1).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        error_message = str(amount_not_matching_price_error.exception.args[0]['with']['string'])
        self.assertEqual("The amount sent is not equal to the price of the land", error_message)

    def test_a_land_on_sale_cannot_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_the_seller(self):
        with self.assertRaises(MichelsonRuntimeError) as buyer_is_owner_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 100
            token_id = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice},
                                                                to_sell={token_id: price},
                                                                operators={(alice, self.nftContract.address, 1): None})
            # WHEN
            self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(buyer_is_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("The buyer is already the owner of this land", error_message)

    def test_a_land_must_be_owned_by_someone_to_be_bought(self):
        with self.assertRaises(MichelsonRuntimeError) as no_owner_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 100
            token_id = 1
            storage_with_a_land_not_owned_by_alice = self.get_storage(ledger={}, to_sell={token_id: price})
            # WHEN
            self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
                storage=storage_with_a_land_not_owned_by_alice,
                source=alice
            )

        # THEN
        error_message = str(no_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is not owned by anyone", error_message)

    def test_a_land_not_on_sale_cannot_be_bought(self):
        with self.assertRaises(MichelsonRuntimeError) as land_not_on_sale_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            token_id = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice}, to_sell={})

            # WHEN
            self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        error_message = str(land_not_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is not on sale", error_message)

    def test_the_land_of_alice_cannot_be_bought_if_the_contract_is_not_an_operator_for_her_land(self):
        with self.assertRaises(MichelsonRuntimeError) as not_an_operator_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            token_id = 1
            price = 100
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice},
                                                                to_sell={token_id: price},
                                                                operators={})

            # WHEN
            result = self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        error_message = str(not_an_operator_error.exception.args[0]['with']['string'])
        self.assertEqual("FA2_NOT_OPERATOR", error_message)

if __name__ == '__main__':
    main()
