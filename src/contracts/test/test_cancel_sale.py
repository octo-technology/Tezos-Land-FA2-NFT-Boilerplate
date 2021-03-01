from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from test.tests_utils import *


class TestCancelSale(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_the_owner_of_a_land_on_sale_can_withdraw_its_land(self):
        # GIVEN
        token_id_sold_by_alice = 1
        alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
        name = "Land 1"
        description = ""
        position = [0, 0]
        isOwned = True
        onSale = False
        land = {"name": name,
                "description": description,
                "position": position,
                "isOwned": isOwned,
                "owner": alice,
                "onSale": onSale,
                "price": alice_land_price,
                "id": token_id_sold_by_alice}
        lands = {token_id_sold_by_alice: land}
        storage_with_alice_selling_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                             sales=[{"token_id": token_id_sold_by_alice,
                                                                     "price": alice_land_price}],
                                                             operators={(alice, self.nftContract.address, 1): None},
                                                             lands=lands)

        # WHEN
        result = self.nftContract.withdrawFromSale(
            {"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
            storage=storage_with_alice_selling_a_land,
            source=alice
        )
        # THEN
        self.assertEqual([], result.storage["market"]["sales"])
        self.assertFalse(result.big_map_diff['market/lands'][1]['onSale'])
        self.assertEqual({token_id_sold_by_alice: alice}, result.big_map_diff["ledger"])
        self.assertEqual(True, (alice, self.nftContract.address, 1) in result.big_map_diff['operators'].keys())

    def test_the_owner_of_a_land_on_sale_cannot_withdraw_its_land_if_it_is_not_in_lands(self):
        with self.assertRaises(MichelsonRuntimeError) as land_not_in_lands:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
            storage_with_alice_selling_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                 sales=[{"token_id": token_id_sold_by_alice,
                                                                         "price": alice_land_price}],
                                                                 operators={(alice, self.nftContract.address, 1): None},
                                                                 lands={})

            # WHEN
            self.nftContract.withdrawFromSale({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_selling_a_land,
                source=alice
            )
        # THEN
        result_error_message = str(land_not_in_lands.exception.args[0]['with']['string'])
        self.assertEqual("This land does not exist", result_error_message)

    def test_the_owner_of_a_land_cannot_cancel_a_sale_if_it_is_not_on_sale(self):
        with self.assertRaises(MichelsonRuntimeError) as not_on_sale_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
            storage_with_alice_owning_a_land = self.get_storage(ledger={token_id_sold_by_alice: alice})

            # WHEN
            self.nftContract.withdrawFromSale({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_owning_a_land,
                source=alice
            )

        # THEN
        result_error_message = str(not_on_sale_error.exception.args[0]['with']['string'])
        self.assertEqual("This land is not on sale", result_error_message)

    def test_a_land_on_sale_can_only_be_withdrawn_by_its_owner(self):
        with self.assertRaises(MichelsonRuntimeError) as not_owner_error:
            # GIVEN
            token_id_sold_by_alice = 1
            alice_land_price = Decimal(0.0003).quantize(Decimal("0.0003"))
            storage_with_alice_selling_her_land = self.get_storage(ledger={token_id_sold_by_alice: alice},
                                                                   sales=[{"token_id": token_id_sold_by_alice,
                                                                           "price": alice_land_price}],
                                                                   operators={
                                                                       (alice, self.nftContract.address, 1): None})

            # WHEN
            self.nftContract.withdrawFromSale({"token_id": token_id_sold_by_alice, "price": alice_land_price}).result(
                storage=storage_with_alice_selling_her_land,
                source=bob
            )

        # THEN
        result_error_message = str(not_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner of a land can withdraw it from sale", result_error_message)


if __name__ == '__main__':
    main()
