let convert_position_to_index(x,y, s: nat * nat * marketplace_storage) : nat =
    if (x < s.width && y < s.height) then
        y * s.width + x + 1n
    else
        (failwith("Coordinates out of range") : nat)

let convert_index_to_position(i, s: nat * marketplace_storage) : (nat * nat) =
  let fixed : nat = abs(i - 1n) in
  if i = 0n then (failwith("token 0 does not exist") : (nat * nat))
  else
  if s.width <> 0n then
  (fixed mod s.width, fixed / s.width)
  else
  (failwith("wrong Dimension") : (nat * nat))


let transfer_bought_token (token_id, token_owner, buyer, operators, ledger, owners, lands, emitter : token_id * address * address * operator_storage * ledger * owners * lands * address option ) : ledger * owners * lands =
    let token_transfer_transaction = [{from_=token_owner; txs=[{to_=buyer; token_id=token_id; amount=1n}]}] in
    let transfer_validator: operator_validator = default_operator_validator in
    let ledger_with_transferred_token, owners_with_transferred_token, lands_with_updated_land: ledger * owners * lands = transfer (token_transfer_transaction, transfer_validator, operators, ledger, owners, lands, emitter) in
    ledger_with_transferred_token, owners_with_transferred_token, lands_with_updated_land

