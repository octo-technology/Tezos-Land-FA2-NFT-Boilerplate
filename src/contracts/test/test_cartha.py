from unittest import TestCase, main, skip
from pytezos import MichelsonRuntimeError
from pytezos.rpc import delphinet, carthagenet
from pytezos import ContractInterface
from decimal import Decimal
from test.tests_utils import *


class TestBuyLand(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface('KT1MGawEz2AyLfEGgWaJ8kuNBKBnKVUxQsMN', shell='delphinet')
        # cls.nftContract.address = contract_address

    # get_storage = get_storage
    @skip("demonstrating skipping")
    def test_a_land_on_sale_can_be_bought_if_the_amount_is_matching_the_price_and_the_buyer_is_not_the_seller(self):
        # GIVEN
        # WHEN
        print(self.nftContract.storage())
        print(self.nftContract.big_map_get("ledger/1"))



        # THEN

if __name__ == '__main__':
    main()
