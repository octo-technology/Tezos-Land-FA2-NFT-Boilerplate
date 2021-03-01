from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from test.tests_utils import *


class TestSellLand(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_the_owner_of_a_land_can_put_it_on_sale_and_the_contract_becomes_an_operator(self):
        # GIVEN
        token_id_sold_by_alice = 1
        alice_land_price = Decimal(0.0003).quantize(Decimal("0.0001"))
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
                "id": token_id_sold_by_alice}
        lands = {token_id_sold_by_alice: land}
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                            lands=lands)

        # WHEN
        result = self.nftContract.sellLand({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertEqual([{'price': alice_land_price, 'token_id': token_id_sold_by_alice}], result.storage["market"]["sales"])
        self.assertEqual(alice_land_price, result.big_map_diff['market/lands'][1]['price'])
        self.assertTrue(result.big_map_diff['market/lands'][1]['onSale'])
        self.assertFalse((alice, bob, token_id_sold_by_alice) in result.big_map_diff['operators'].keys())
        self.assertTrue((alice, self.nftContract.address, token_id_sold_by_alice) in result.big_map_diff['operators'].keys())

    def test_the_owner_of_a_land_cannot_put_it_on_sale_if_this_land_is_not_in_market_lands(self):
        with self.assertRaises(MichelsonRuntimeError) as land_not_in_lands:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0001"))
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                lands={})

            # WHEN
            self.nftContract.sellLand({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )
        # THEN
        result_error_message = str(land_not_in_lands.exception.args[0]['with']['string'])
        self.assertEqual("This land does not exist", result_error_message)

    def test_a_land_cannot_be_put_on_sale_by_someone_else_than_the_owner(self):
        with self.assertRaises(MichelsonRuntimeError) as not_land_owner_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0001"))
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

            # WHEN
            self.nftContract.sellLand({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        result_error_message = str(not_land_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner of a land can sell it", result_error_message)

    def test_a_land_cannot_be_put_on_sale_if_it_is_already_on_sale_with_the_same_price(self):
        with self.assertRaises(MichelsonRuntimeError) as already_on_sale_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0001"))
            name = "Land 1"
            description = ""
            position = [0, 0]
            isOwned = True
            onSale = True
            land = {"name": name,
                    "description": description,
                    "position": position,
                    "isOwned": isOwned,
                    'owner': alice,
                    "onSale": onSale,
                    "price": None,
                    "id": token_id_sold_by_alice}
            lands = {token_id_sold_by_alice: land}
            storage_with_alice_selling_her_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                   sales=[{"token_id": token_id_sold_by_alice, "price": alice_land_price}],
                                                                   operators={(alice, self.nftContract.address, 1): None},
                                                                   lands=lands)

            # WHEN
            self.nftContract.sellLand({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_selling_her_land,
                source=alice
            )

        # THEN
        result_error_message = str(already_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is already on sale", result_error_message)

    def test_a_land_cannot_be_put_on_sale_if_it_is_already_on_sale_with_a_different_price(self):
        with self.assertRaises(MichelsonRuntimeError) as already_on_sale_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0001"))
            alice_land_price_for_second_sale = Decimal(0.0004).quantize(Decimal("0.0001"))
            name = "Land 1"
            description = ""
            position = [0, 0]
            isOwned = True
            onSale = True
            land = {"name": name,
                    "description": description,
                    "position": position,
                    "isOwned": isOwned,
                    'owner': alice,
                    "onSale": onSale,
                    "price": None,
                    "id": token_id_sold_by_alice}
            lands = {token_id_sold_by_alice: land}
            storage_with_alice_selling_her_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                   sales=[{"token_id": token_id_sold_by_alice, "price": alice_land_price}],
                                                                   operators={(alice, self.nftContract.address, 1): None},
                                                                   lands=lands)

            # WHEN
            self.nftContract.sellLand({"token_id": token_id_sold_by_alice, "price": alice_land_price_for_second_sale}).result(
                storage=storage_with_alice_selling_her_land,
                source=alice
            )

        # THEN
        result_error_message = str(already_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is already on sale", result_error_message)


if __name__ == '__main__':
    main()
