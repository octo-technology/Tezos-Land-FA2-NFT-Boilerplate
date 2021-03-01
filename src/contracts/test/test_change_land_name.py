from unittest import TestCase, main, skip
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from test.tests_utils import *
from decimal import Decimal


class TestChangeLandName(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_only_the_owner_of_a_land_can_update_its_name(self):
        with self.assertRaises(MichelsonRuntimeError) as not_owner_error:
            # GIVEN
            land_token_id = 1
            owner = alice
            land = {"name": "old name",
                    "description": "",
                    "position": [0, 0],
                    "isOwned": True,
                    "owner": alice,
                    "onSale": False,
                    "price": 200,
                    "id": land_token_id}
            lands = {land_token_id: land}
            storage = self.get_storage(lands=lands,
                                       ledger={land_token_id: owner})

            # WHEN
            self.nftContract.changeLandName({"token_id": land_token_id, "new_land_name": "new name"}).result(
                storage=storage,
                source=bob
            )

        # THEN
        result_error_message = str(not_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner of a land can change its name", result_error_message)

    def test_a_land_can_be_renamed_if_it_exists(self):
        with self.assertRaises(MichelsonRuntimeError) as does_not_exist_error:
            # GIVEN
            land_token_id = 1
            owner = alice
            lands = {}
            storage = self.get_storage(lands=lands,
                                       ledger={land_token_id: owner})

            # WHEN
            self.nftContract.changeLandName({"token_id": land_token_id, "new_land_name": "new name"}).result(
                storage=storage,
                source=owner
            )

        # THEN
        result_error_message = str(does_not_exist_error.exception.args[0]['with']['string'])
        self.assertEqual("This land does not exist", result_error_message)

    def test_the_owner_of_an_existing_land_can_rename_it(self):
        # GIVEN
        land_token_id = 1
        owner = alice
        previous_name = "old name"
        new_name = "new name"
        description = ""
        position = [0, 0]
        isOwned = True
        onSale = False
        price = Decimal(0.000100).quantize(Decimal("0.0001"))
        land = {"name": previous_name,
                "description": description,
                "position": position,
                "isOwned": isOwned,
                "owner": alice,
                "onSale": onSale,
                "price": price,
                "id": land_token_id}
        lands = {land_token_id: land}
        storage = self.get_storage(lands=lands,
                                   ledger={land_token_id: owner})

        # WHEN
        result = self.nftContract.changeLandName({"token_id": land_token_id, "new_land_name": new_name}).result(
            storage=storage,
            source=owner
        )

        # THEN
        modified_land = result.big_map_diff["market/lands"][land_token_id]
        self.assertEqual(modified_land["name"], new_name)
        self.assertEqual(modified_land["description"], description)
        self.assertEqual(modified_land["position"], position)
        self.assertEqual(modified_land["isOwned"], isOwned)
        self.assertEqual(modified_land["onSale"], onSale)
        self.assertEqual(modified_land["price"], price)
        self.assertEqual(modified_land["id"], land_token_id)


if __name__ == '__main__':
    main()
