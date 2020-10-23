from os.path import dirname, join
from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from tests_utils import *


class TestTransfer(TestCase):

    @classmethod
    def setUpClass(cls):
        project_dir = dirname(dirname(__file__))
        print("projectdir", project_dir)
        cls.nftContract = ContractInterface.create_from(join(project_dir, 'src/land.tz'))
        cls.nftContract.address = contract_address

    get_storage = get_storage

    def test_the_future_owner_of_a_minted_land_must_pay_200_mutez(self):
        with self.assertRaises(MichelsonRuntimeError) as default_price_error:
            # GIVEN
            storage = self.get_storage()

            # WHEN
            result = self.nftContract.mint({"token_id": 1, "owner": alice}).result(
                storage=storage,
                source=alice
            )

        # THEN
        result_error_message = str(default_price_error.exception.args[0]['with']['string'])
        self.assertEqual("Default mint price is 200mutez", result_error_message)

    def test_an_already_existing_token_cannot_be_minted(self):
        with self.assertRaises(MichelsonRuntimeError) as already_exist_error:
            # GIVEN
            bob_token_id = 1
            storage = self.get_storage(ledger={bob_token_id: bob})
            amount_sent = Decimal(0.000200).quantize(Decimal("0.0001"))
            minted_token_id = 1
            # WHEN
            result = self.nftContract.mint({"token_id": minted_token_id, "owner": alice}).with_amount(
                amount_sent).result(
                storage=storage,
                source=alice
            )
        # THEN
        result_error_message = str(already_exist_error.exception.args[0]['with']['string'])
        self.assertEqual("This non-fungible token already exists", result_error_message)

    def test_a_new_land_can_be_minted_if_200_mutez_are_paid_and_this_land_does_not_already_exist(self):
        # GIVEN
        storage = self.get_storage()
        amount_sent = Decimal(0.000200).quantize(Decimal("0.0001"))
        minted_token_id = 1
        # WHEN
        result = self.nftContract.mint({"token_id": minted_token_id, "owner": alice}).with_amount(amount_sent).result(
            storage=storage,
            source=alice
        )

        # THEN
        expected_minted_land = {'description': None, 'id': 1, 'isOwned': True, 'name': '', 'onSale': False, 'position': [0, 0], 'price': Decimal('0.0002')}
        lands_with_minted_land = {minted_token_id: expected_minted_land}
        self.assertEqual({minted_token_id: alice}, result.big_map_diff['ledger'])
        self.assertEqual(lands_with_minted_land, result.big_map_diff["market/lands"])
        self.assertNotIn('operators', result.big_map_diff.keys())

    def test_a_new_land_can_be_minted_with_an_operator_if_200_mutez_are_paid_and_this_land_does_not_already_exist_and_an_operator_is_specified(self):
        # GIVEN
        storage = self.get_storage()
        amount_sent = Decimal(0.000200).quantize(Decimal("0.0001"))
        minted_token_id = 1
        # WHEN
        result = self.nftContract.mint({"token_id": minted_token_id, "owner": alice, "operator": bob}).with_amount(amount_sent).result(
            storage=storage,
            source=alice
        )

        # THEN
        expected_minted_land = {'description': None, 'id': 1, 'isOwned': True, 'name': '', 'onSale': False, 'position': [0, 0], 'price': Decimal('0.0002')}
        lands_with_minted_land = {minted_token_id: expected_minted_land}
        minted_land_operator = {('tz1L738ifd66ah69PrmKAZzckvvHnbcSeqjf', 'tz1LFuHW4Z9zsCwg1cgGTKU12WZAs27ZD14v', 1): None}
        self.assertEqual({minted_token_id: alice}, result.big_map_diff['ledger'])
        self.assertEqual(lands_with_minted_land, result.big_map_diff["market/lands"])
        self.assertEqual(minted_land_operator, result.big_map_diff["operators"])



if __name__ == '__main__':
    main()
