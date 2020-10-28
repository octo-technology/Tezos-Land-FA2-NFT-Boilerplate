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
        alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
        storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

        # WHEN
        result = self.nftContract.sellLand({"id": token_id_sold_by_alice, "price": alice_land_price}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertEqual({token_id_sold_by_alice: alice_land_price}, result.big_map_diff["market/to_sell"])
        self.assertEqual(False, (alice, bob, 1) in result.big_map_diff['operators'].keys())
        self.assertEqual(True, (alice, self.nftContract.address, 1) in result.big_map_diff['operators'].keys())

    def test_a_land_cannot_be_put_on_sale_by_someone_else_than_the_owner(self):
        with self.assertRaises(MichelsonRuntimeError) as not_land_owner_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

            # WHEN
            self.nftContract.sellLand({"id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_owning_a_land,
                source=bob
            )

        # THEN
        result_error_message = str(not_land_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner of a land can sell it", result_error_message)

    def test_a_land_cannot_be_put_on_sale_if_it_is_already_on_sale(self):
        with self.assertRaises(MichelsonRuntimeError) as already_on_sale_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
            storage_with_alice_selling_her_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                   to_sell={token_id_sold_by_alice: alice_land_price},
                                                                   operators={(alice, self.nftContract.address, 1): None})

            # WHEN
            self.nftContract.sellLand({"id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_selling_her_land,
                source=bob
            )

        # THEN
        result_error_message = str(already_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is already on sale", result_error_message)


if __name__ == '__main__':
    main()
