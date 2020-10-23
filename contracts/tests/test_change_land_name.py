from os.path import dirname, join
from unittest import TestCase, main, skip
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

    @skip("Storage not compiling because of lands structure")
    def test_only_the_owner_of_a_land_can_update_its_name(self):
        with self.assertRaises(MichelsonRuntimeError) as not_owner_error:
            # GIVEN
            land_token_id = 1
            owner = alice
            land = {"name": "old name",
                    "description": "",
                    "position": (0, 0),
                    "isOwned": True,
                    "onSale": False,
                    "price": 200,
                    "id": land_token_id}
            lands = {land_token_id : land}
            storage = self.get_storage(lands=lands, ledger={land_token_id: owner})

            # WHEN
            result = self.nftContract.changeLandName({"token_id": land_token_id, "new_land_name": "new name"}).result(
                storage=storage,
                source=bob
            )

        # THEN
        result_error_message = str(not_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner of a land can change its name", result_error_message)


if __name__ == '__main__':
    main()
