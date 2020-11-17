from unittest import TestCase, main
from pytezos import MichelsonRuntimeError
from pytezos import ContractInterface
from decimal import Decimal
from test.tests_utils import *


class TestCheck(TestCase):

    @classmethod
    def setUpClass(cls):
        cls.nftContract = ContractInterface.create_from(join(dirname(dirname(__file__)), 'test/helpers.tz'))
        cls.nftContract.address = contract_address

    get_storage = get_test_storage

    def test_if_returns_true_when_the_token_id_is_owned_by_the_owner_in_the_ledger(self):
        # GIVEN
        token_id_owned_by_alice = 1
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_ledger={1: alice},
                                                             check_consistency_result=False)

        # WHEN
        result = self.nftContract.tokenIdOwnedByOwnerInLedger({"token_id": token_id_owned_by_alice, "owner": alice}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertTrue(result.storage["check_consistency_result"])

    def test_if_returns_false_when_the_token_id_is_owned_by_the_owner_not_in_the_ledger(self):
        # GIVEN
        token_id_owned_by_alice = 1
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_ledger={1: alice},
                                                             check_consistency_result=False)

        # WHEN
        result = self.nftContract.tokenIdOwnedByOwnerInLedger({"token_id": token_id_owned_by_alice, "owner": bob}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertFalse(result.storage["check_consistency_result"])

    def test_if_returns_true_when_the_token_id_is_owned_by_the_given_owner_in_owners(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {alice: [token_id_owned_by_alice]}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.ownerOwnsTokenIdInOwners({"token_id": token_id_owned_by_alice, "owner": alice}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertTrue(result.storage["check_consistency_result"])

    def test_if_returns_false_when_the_token_id_is_not_owned_by_the_given_owner_in_owners(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {alice: [token_id_owned_by_alice]}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.ownerOwnsTokenIdInOwners({"token_id": token_id_owned_by_alice, "owner": bob}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertFalse(result.storage["check_consistency_result"])

    def test_if_returns_true_when_the_token_id_is_owned_by_the_given_owner_in_owners_and_ledger(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {alice: [token_id_owned_by_alice]}
        ledger = {token_id_owned_by_alice: alice}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_ledger=ledger,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.consistencyLedgerOwners({"token_id": token_id_owned_by_alice, "owner": alice}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertTrue(result.storage["check_consistency_result"])

    def test_if_returns_false_when_the_token_id_is_owned_by_the_given_owner_in_owners_and_not_in_ledger(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {alice: [token_id_owned_by_alice]}
        ledger = {token_id_owned_by_alice: bob}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_ledger=ledger,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.consistencyLedgerOwners({"token_id": token_id_owned_by_alice, "owner": alice}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertFalse(result.storage["check_consistency_result"])

    def test_if_returns_false_when_the_token_id_is_owned_by_the_given_owner_in_ledger_and_not_in_owners(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {bob: [token_id_owned_by_alice]}
        ledger = {token_id_owned_by_alice: alice}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_ledger=ledger,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.consistencyLedgerOwners({"token_id": token_id_owned_by_alice, "owner": alice}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertFalse(result.storage["check_consistency_result"])

    def test_if_returns_false_when_the_token_id_is_no_owned_by_the_given_owner_in_ledger_and_in_owners(self):
        # GIVEN
        token_id_owned_by_alice = 1
        owners = {alice: [token_id_owned_by_alice]}
        ledger = {token_id_owned_by_alice: alice}
        storage_with_alice_owning_a_land = self.get_storage(check_consistency_owners=owners,
                                                            check_consistency_ledger=ledger,
                                                            check_consistency_result=False)

        # WHEN
        result = self.nftContract.consistencyLedgerOwners({"token_id": token_id_owned_by_alice, "owner": bob}).result(
            storage=storage_with_alice_owning_a_land,
            source=alice
        )
        # THEN
        self.assertFalse(result.storage["check_consistency_result"])


if __name__ == '__main__':
    main()
