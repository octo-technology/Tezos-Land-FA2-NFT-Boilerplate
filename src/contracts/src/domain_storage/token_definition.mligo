(* range of nft tokens *)
type token_def = {
  from_ : nat;
  to_ : nat;
}
type nft_meta = (token_def, token_metadata) big_map