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

    def test_the_owner_of_a_land_can_put_on_sale_its_property(self):
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
        error_message = str(not_land_owner_error.exception.args[0]['with']['string'])
        self.assertEqual("Only the owner can sell its land", error_message)


if __name__ == '__main__':
    main()
