#if !FA2_TLD_TOKEN
#define FA2_TLD_TOKEN

#include "../src/tzip-12/fa2_interface.mligo"
#include "../src/domain_storage/storage_definition.mligo"
#include "../src/entrypoints/helpers/fa2_transfer_helpers.mligo"
#include "../src/entrypoints/helpers/land_transfer_helpers.mligo"


type test_storage = {
    check_consistency_ledger : ledger;
    check_consistency_owners : owners;
    check_consistency_result : bool;
}

type test_entrypoints =
    | TokenIdOwnedByOwnerInLedger of ownership
    | OwnerOwnsTokenIdInOwners of ownership
    | ConsistencyLedgerOwners of ownership

let check_token_id_is_owned_by_given_owner_interface(fa2, storage : ownership * test_storage) : (operation  list) * test_storage =
    let result : bool = check_token_id_is_owned_by_given_owner (fa2, storage.check_consistency_ledger) in
    ([] : operation list),  { storage with check_consistency_result = result; }

let check_owner_owns_a_given_token_id_interface (fa2, storage : ownership * test_storage) : (operation  list) * test_storage =
    let result : bool = check_owner_owns_a_given_token_id (fa2, storage.check_consistency_owners) in
    ([] : operation list),  { storage with check_consistency_result = result; }

let check_ownership_is_consistent_in_ledger_and_owners_interface_interface (fa2, storage : ownership * test_storage) : (operation  list) * test_storage =
    let result : bool = check_ownership_is_consistent_in_ledger_and_owners (fa2, storage.check_consistency_ledger,  storage.check_consistency_owners) in
    ([] : operation list),  { storage with check_consistency_result = result; }



let main (param, storage : test_entrypoints * test_storage )
      : (operation  list) * test_storage =
    match param with
    | TokenIdOwnedByOwnerInLedger p -> check_token_id_is_owned_by_given_owner_interface (p, storage)
    | OwnerOwnsTokenIdInOwners p -> check_owner_owns_a_given_token_id_interface (p, storage)
    | ConsistencyLedgerOwners p -> check_ownership_is_consistent_in_ledger_and_owners_interface_interface (p, storage)

#endif

