from os.path import dirname, join
from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from tests_utils import *


class TestBuyLand(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        print("projectdir", project_dir)
        cls.nftContract = ContractInterface.create_from(join(project_dir, 'src/land.tz'))

    get_storage = get_storage

    def test_a_land_on_sale_can_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_not_the_seller(self):
        # GIVEN
        amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
        price = 100
        token_id = 1
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice}, to_sell={token_id: price})
        # WHEN
        result = self.nftContract.buyLand(token_id).with_amount(amount_sent).result(
            storage=storage_with_alice_owning_a_land,
            source=bob
        )

        # THEN
        self.assertEqual({token_id: amount_sent}, result.big_map_diff['market/to_sell'])
        self.assertEqual({bob: amount_sent}, result.big_map_diff['market/fundsByOwner'])
        self.assertEqual({token_id: bob}, result.big_map_diff['market/buyers'])

    def test_anyone_can_buy_a_land_even_if_he_is_buying_another_land(self):
        # GIVEN
        amount_sent_by_bob = Decimal(0.000200).quantize(Decimal("0.0001"))
        token_id_sold_by_alice = 1
        alice_price = 100
        alice_price_decimal = Decimal(alice_price / 1000000).quantize(Decimal("0.0001"))
        token_id_sold_by_bartholome = 2
        bartholome_price = 200
        bartholome_price_decimal = Decimal(bartholome_price / 1000000).quantize(Decimal("0.0001"))
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice,
                                                                    token_id_sold_by_bartholome: bartholome},
                                                            to_sell={token_id_sold_by_alice: alice_price,
                                                                     token_id_sold_by_bartholome: bartholome_price},
                                                            buyers={token_id_sold_by_alice: bob},
                                                            funds_by_owner={bob: alice_price_decimal})

        # WHEN
        result = self.nftContract.buyLand(token_id_sold_by_bartholome).with_amount(amount_sent_by_bob).result(
            storage=storage_with_alice_owning_a_land,
            source=bob
        )

        # THEN
        expected_to_sell_map = {token_id_sold_by_alice: alice_price_decimal, token_id_sold_by_bartholome: bartholome_price_decimal}
        expected_buyers_map = {token_id_sold_by_alice: bob, token_id_sold_by_bartholome: bob}
        expected_funds_by_owner_map = {bob: bartholome_price_decimal + alice_price_decimal}
        self.assertEqual(expected_to_sell_map, result.big_map_diff['market/to_sell'])
        self.assertEqual(expected_funds_by_owner_map, result.big_map_diff['market/fundsByOwner'])
        self.assertEqual(expected_buyers_map, result.big_map_diff['market/buyers'])

    def test_a_land_on_sale_cannot_be_bought_if_the_amount_is_not_matching_the_price(
            self):
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
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice}, to_sell={token_id: price})
            # WHEN
            self.nftContract.buyLand(1).with_amount(amount_sent).result(
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
            storage_with_alice_owning_a_land = self.get_storage(ledger={}, to_sell={token_id: price})
            # WHEN
            self.nftContract.buyLand(1).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        error_message = str(no_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("This land has no owner", error_message)

    def test_a_land_on_sale_cannot_be_bought_if_there_is_already_a_buyer(self):
        with self.assertRaises(MichelsonRuntimeError) as has_already_a_buyer_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            price = 100
            token_id = 1
            storage_with_alice_owning_a_land = self.get_storage(buyers={token_id: bob}, ledger={token_id: alice}, to_sell={token_id: price})
            # WHEN
            self.nftContract.buyLand(1).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=frank
            )

        # THEN
        error_message = str(has_already_a_buyer_error.exception.args[0]['with']['string'])
        self.assertEqual("This land has already a buyer", error_message)

    def test_a_land_not_on_sale_cannot_be_bought(self):
        with self.assertRaises(MichelsonRuntimeError) as land_not_on_sale_error:
            # GIVEN
            amount_sent = Decimal(0.000100).quantize(Decimal("0.0001"))
            token_id = 1
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id: alice}, to_sell={})

            # WHEN
            self.nftContract.buyLand(1).with_amount(amount_sent).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        error_message = str(land_not_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is not on sale", error_message)

    def test_the_owner_of_a_land_can_sell_its_property(self):
        # GIVEN
        token_id_sold_by_alice = 1
        alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

        # WHEN
        result = self.nftContract.sellLand({"id": token_id_sold_by_alice, "price": alice_land_price}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertEqual({token_id_sold_by_alice: alice_land_price}, result.big_map_diff["market/to_sell"])


if __name__ == '__main__':
    main()
