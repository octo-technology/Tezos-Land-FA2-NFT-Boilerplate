from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from test.tests_utils import *


class TestMint(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(path_to_michelson_contract)
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_a_land_can_only_be_minted_by_the_contract_administrator(self):
        with self.assertRaises(MichelsonRuntimeError) as not_administrator_error:
            # GIVEN
            storage = self.get_storage(admin=administrator)
            name = "My Land"
            description = "This is my land"
            coordinates = [1, 5]

            # WHEN
            self.nftContract.mint({"owner": alice,
                                   "name": name,
                                   "description": description,
                                   "coordinates": coordinates}).result(
                storage=storage,
                source=alice
            )

        # THEN
        result_error_message = str(not_administrator_error.exception.args[0]['with']['string'])
        self.assertEqual("A new token can only be minted by the administrator", result_error_message)

    def test_an_already_existing_token_cannot_be_minted(self):
        with self.assertRaises(MichelsonRuntimeError) as already_exist_error:
            # GIVEN
            bob_token_id = 1

            storage = self.get_storage(admin=administrator,
                                       ledger={bob_token_id: bob},
                                       land_ids=[bob_token_id])
            name = "My Land"
            description = "This is my land"
            coordinates = [0, 0]

            # WHEN
            self.nftContract.mint({"name": name,
                                   "description": description,
                                   "coordinates": coordinates,
                                   "owner": alice}).result(
                storage=storage,
                source=administrator
            )
        # THEN
        result_error_message = str(already_exist_error.exception.args[0]['with']['string'])
        self.assertEqual("This non-fungible token already exists", result_error_message)

    def test_an_out_of_range_token_cannot_be_minted_x_coordinates(self):
        with self.assertRaises(MichelsonRuntimeError) as not_in_range_error:
            # GIVEN
            map_height = 10
            map_width = 10
            x_coordinates = map_width
            y_coordinates = 5
            storage = self.get_storage(admin=administrator,
                                       height=map_height, width=map_width)
            name = "My Land"
            description = "This is my land"
            coordinates = [x_coordinates, y_coordinates]

            # WHEN
            self.nftContract.mint({"name": name,
                                   "description": description,
                                   "coordinates": coordinates,
                                   "owner": alice}).result(
                storage=storage,
                source=administrator
            )
        # THEN
        result_error_message = str(not_in_range_error.exception.args[0]['with']['string'])
        self.assertEqual("Coordinates out of range", result_error_message)

    def test_an_out_of_range_token_cannot_be_minted_y_coordinates(self):
        with self.assertRaises(MichelsonRuntimeError) as not_in_range_error:
            # GIVEN
            map_height = 10
            map_width = 10
            x_coordinates = 5
            y_coordinates = map_height
            storage = self.get_storage(admin=administrator,
                                       height=map_height, width=map_width)
            name = "My Land"
            description = "This is my land"
            coordinates = [x_coordinates, y_coordinates]

            # WHEN
            self.nftContract.mint({"name": name,
                                   "description": description,
                                   "coordinates": coordinates,
                                   "owner": alice}).result(
                storage=storage,
                source=administrator
            )
        # THEN
        result_error_message = str(not_in_range_error.exception.args[0]['with']['string'])
        self.assertEqual("Coordinates out of range", result_error_message)

    def test_a_new_land_can_be_minted_this_land_does_not_already_exist_and_token_is_in_range(self):
        # GIVEN
        map_height = 10
        map_width = 10
        x_coordinates = map_width - 1
        y_coordinates = map_height - 1
        expected_minted_token_id = 100
        name = "My Land"
        description = "This is my land"
        coordinates = [x_coordinates, y_coordinates]
        storage = self.get_storage(admin=administrator,
                                   ledger={},
                                   height=map_height,
                                   width=map_width
                                   )

        # WHEN
        result = self.nftContract.mint({"name": name,
                                        "description": description,
                                        "coordinates": coordinates,
                                        "owner": alice}).result(
            storage=storage,
            source=administrator
        )

        # THEN
        expected_minted_land = {'description': description,
                                'id': expected_minted_token_id,
                                'isOwned': True,
                                'owner': alice,
                                'name': name,
                                'onSale': False,
                                'position': coordinates,
                                'price': None}
        lands_with_minted_land = {expected_minted_token_id: expected_minted_land}
        self.assertEqual({expected_minted_token_id: alice}, result.big_map_diff['ledger'])
        self.assertEqual({alice: [expected_minted_token_id]}, result.big_map_diff['market/owners'])
        self.assertEqual([expected_minted_token_id], result.storage['market']['landIds'])
        self.assertEqual(lands_with_minted_land, result.big_map_diff["market/lands"])
        self.assertNotIn('operators', result.big_map_diff.keys())

    def test_a_new_land_can_be_minted_with_an_operator_if_200_mutez_are_paid_and_this_land_does_not_already_exist_and_an_operator_is_specified_and_token_is_in_range(
            self):
        # GIVEN
        map_height = 10
        map_width = 10
        x_coordinates = map_width - 1
        y_coordinates = map_height - 1
        expected_minted_token_id = 100
        name = "My Land"
        description = "This is my land"
        coordinates = [x_coordinates, y_coordinates]
        storage = self.get_storage(admin=administrator,
                                   ledger={},
                                   height=map_height,
                                   width=map_width
                                   )
        # WHEN
        result = self.nftContract.mint({"name": name,
                                        "description": description,
                                        "coordinates": coordinates,
                                        "owner": alice,
                                        "operator": bob}).result(
            storage=storage,
            source=administrator
        )

        # THEN
        expected_minted_land = {'description': description,
                                'id': expected_minted_token_id,
                                'isOwned': True,
                                'owner': alice,
                                'name': name,
                                'onSale': False,
                                'position': coordinates,
                                'price': None}
        lands_with_minted_land = {expected_minted_token_id: expected_minted_land}
        minted_land_operator = {('tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf', 'tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v',
                                 expected_minted_token_id): None}
        self.assertEqual({expected_minted_token_id: alice}, result.big_map_diff['ledger'])
        self.assertEqual({alice: [expected_minted_token_id]}, result.big_map_diff['market/owners'])
        self.assertEqual([expected_minted_token_id], result.storage['market']['landIds'])
        self.assertEqual(lands_with_minted_land, result.big_map_diff["market/lands"])
        self.assertEqual(minted_land_operator, result.big_map_diff["operators"])


if __name__ == '__main__':
    main()
